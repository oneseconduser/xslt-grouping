<?xml version="1.0" encoding="UTF-8"?>
<!-- Преобразование XML (orgs/item) в HTML. XSLT 1.0, группировка методом Мюнха (xsl:key) -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!-- Ключ 1: все товары города. Нужен для группировки "компании по городам" -->
  <xsl:key name="items-by-city" match="item" use="@city"/>

  <!-- Ключ 2: все товары компании. Ключ составной: город + | + компания,
       чтобы "ООО Светлана" из Москвы и Петербурга не слились в одну -->
  <xsl:key name="items-by-org" match="item" use="concat(@city, '|', @org)"/>

  <!-- Корневой шаблон: рисуем каркас страницы -->
  <xsl:template match="/orgs">
    <html>
      <head>
        <title>Города</title>
      </head>
      <body>
        <h1>Города и компании</h1>
        <ul>
          <!-- Берём только первый item каждого города - так получаем уникальные города -->
          <xsl:for-each select="item[generate-id() = generate-id(key('items-by-city', @city)[1])]">
            <!-- Запоминаем город в переменную, чтобы использовать внутри вложенных циклов -->
            <xsl:variable name="city" select="@city"/>
            <li>
              <h3><xsl:value-of select="$city"/></h3>
              <p>Всего товаров: <xsl:value-of select="count(key('items-by-city', $city))"/></p>

              <!-- Внутри города берём только первый item каждой компании (уникальные компании) -->
              <xsl:for-each select="key('items-by-city', $city)[generate-id() = generate-id(key('items-by-org', concat(@city, '|', @org))[1])]">
                <!-- Составной ключ текущей компании -->
                <xsl:variable name="orgKey" select="concat(@city, '|', @org)"/>
                <ul>
                  <li>
                    <h4><xsl:value-of select="@org"/></h4>
                    <p>Всего товаров: <xsl:value-of select="count(key('items-by-org', $orgKey))"/></p>
                    <ul>
                      <!-- Все товары этой компании, отсортированные по названию -->
                      <xsl:for-each select="key('items-by-org', $orgKey)">
                        <xsl:sort select="@title"/>
                        <li><xsl:value-of select="@title"/></li>
                      </xsl:for-each>
                    </ul>
                  </li>
                </ul>
              </xsl:for-each>
            </li>
          </xsl:for-each>
        </ul>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
