<!-- Fix suggested for htmltoword in https://github.com/karnov/htmltoword/issues/73.
We applied it to a copy of numbering.xslt gem htmltoword-1.1.0 in folder lib/htmltoword/xslt
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:o="urn:schemas-microsoft-com:office:office"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:WX="http://schemas.microsoft.com/office/word/2003/auxHint"
                xmlns:aml="http://schemas.microsoft.com/aml/2001/core"
                xmlns:w10="urn:schemas-microsoft-com:office:word"
                xmlns:pkg="http://schemas.microsoft.com/office/2006/xmlPackage"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:ext="http://www.xmllab.net/wordml2html/ext"
                xmlns:java="http://xml.apache.org/xalan/java"
                xmlns:str="http://exslt.org/strings"
                xmlns:func="http://exslt.org/functions"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                version="1.0"
                exclude-result-prefixes="java msxsl ext w o v WX aml w10"
                extension-element-prefixes="func">
  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" indent="yes" />
  <xsl:include href="./functions.xslt"/>

  <func:function name="func:list-type">
    <xsl:param name="tag_name"/>
    <xsl:param name="style"/>
    <xsl:param name="class"/>
    <func:result>
      <xsl:choose>
        <xsl:when test="contains($style, 'list-style-type:') or string-length(normalize-space($class)) > 0">
          <xsl:variable name="lstyle" select="func:substring-before-if-contains(substring-after($style, 'list-style-type:'), ';')"/>
          <xsl:choose>
            <xsl:when test="contains($lstyle, 'lower-alpha') or contains($lstyle, 'lower-latin') or contains($class, 'alfalower')">lowerLetter</xsl:when>
            <xsl:when test="contains($lstyle, 'upper-alpha') or contains($lstyle, 'upper-latin') or contains($class, 'alfaupper')">upperLetter</xsl:when>
            <xsl:when test="contains($lstyle, 'lower-roman') or contains($class, 'romanlower')">lowerRoman</xsl:when>
            <xsl:when test="contains($lstyle, 'upper-roman') or contains($class, 'romanupper')">upperRoman</xsl:when>
            <xsl:when test="contains($lstyle, 'none') or contains($class, 'manuell')">none</xsl:when>
            <xsl:when test="contains($lstyle, 'decimal') or contains($class, 'num') or contains($class, 'token')">decimal</xsl:when>
            <xsl:when test="contains($lstyle, 'disc')">bullet,●</xsl:when>
            <xsl:when test="contains($lstyle, 'circle')">bullet,o</xsl:when>
            <xsl:when test="contains($lstyle, 'square')">bullet,■</xsl:when>
            <xsl:otherwise>none</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$tag_name = 'ol'">decimal</xsl:when>
            <xsl:otherwise>bullet,●</xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </func:result>
  </func:function>

  <xsl:template match="/">
    <w:numbering xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
                 xmlns:mo="http://schemas.microsoft.com/office/mac/office/2008/main"
                 xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
                 xmlns:mv="urn:schemas-microsoft-com:mac:vml" xmlns:o="urn:schemas-microsoft-com:office:office"
                 xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                 xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                 xmlns:v="urn:schemas-microsoft-com:vml"
                 xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
                 xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
                 xmlns:w10="urn:schemas-microsoft-com:office:word"
                 xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                 xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
                 xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
                 xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
                 xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
                 xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape">
      <xsl:apply-templates />
      <xsl:variable name="nlists" select="count(//ol[not(ancestor::ol) and not(ancestor::ul)]) + count(//ul[not(ancestor::ol) and not(ancestor::ul)])"/>
      <xsl:call-template name="define-abstractNum"/>
    </w:numbering>
  </xsl:template>

  <xsl:template name="container" match="ol|ul">
    <xsl:variable name="global_level" select="count(preceding::ol[not(ancestor::ol or ancestor::ul)]) + count(preceding::ul[not(ancestor::ol or ancestor::ul)]) + 1"/>
    <xsl:variable name="style" select="func:list-type(name(.), concat(' ', @style, ' '), concat(' ', @class, ' '))"/>
    <xsl:choose>
      <xsl:when test="not(ancestor::ol or ancestor::ul)">
        <w:abstractNum w:abstractNumId="{$global_level - 1}">
          <w:nsid w:val="{concat('099A08C', $global_level)}"/>
          <w:multiLevelType w:val="hybridMultilevel"/>
          <xsl:call-template name="numbering_level">
            <xsl:with-param name="ilvl" select="0"/>
            <xsl:with-param name="style" select="$style"/>
          </xsl:call-template>
          <xsl:call-template name="item"/>
          <xsl:if test="count(.//ol|.//ul) &lt; 6">
            <xsl:call-template name="autocomplete">
              <xsl:with-param name="ilvl" select="count(.//ol) + count(.//ul)"/>
              <xsl:with-param name="style" select="$style"/>
            </xsl:call-template>
          </xsl:if>
        </w:abstractNum>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="numbering_level">
          <xsl:with-param name="ilvl" select="count(ancestor::ol) + count(ancestor::ul)"/>
          <xsl:with-param name="style" select="$style"/>
        </xsl:call-template>
        <xsl:call-template name="item"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="item">
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test="self::ol|self::ul">
          <xsl:call-template name="container"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="item"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="text()"/>

  <xsl:template name="numbering_level">
    <xsl:param name="style" />
    <xsl:param name="ilvl" />
    <w:lvl w:ilvl="{$ilvl}">
      <w:start w:val="1"/>
      <w:numFmt w:val="{func:substring-before-if-contains($style, ',')}"/>
      <xsl:choose>
        <xsl:when test="contains($style, 'bullet')">
          <xsl:variable name="list-symbol" select="substring-after($style, ',')"/>
          <w:lvlText w:val="{$list-symbol}"/>
        </xsl:when>
        <xsl:when test="$style = 'none'">
          <w:lvlText w:val=""/>
        </xsl:when>
        <xsl:otherwise>
          <w:lvlText w:val="%{$ilvl + 1}."/>
        </xsl:otherwise>
      </xsl:choose>
      <w:lvlJc w:val="left"/>
      <w:pPr>
        <w:ind w:left="{720 * ($ilvl + 1)}" w:hanging="360"/>
      </w:pPr>
      <!--
       Fix for "List item bullets corrupted in Microsoft Word"
       https://github.com/karnov/htmltoword/issues/73
       required removing this:
      <xsl:if test="contains($style, 'bullet')">
        <w:rPr>
          <w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/>
        </w:rPr>
      </xsl:if>
    -->
    </w:lvl>
  </xsl:template>

  <xsl:template name="autocomplete">
    <xsl:param name="ilvl"/>
    <xsl:param name="style" />
    <xsl:variable name="current_level">
      <xsl:choose>
        <xsl:when test="$ilvl &lt; 1">1</xsl:when>
        <xsl:otherwise><xsl:value-of select="$ilvl"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$current_level &lt; 6">
      <xsl:call-template name="numbering_level">
        <xsl:with-param name="ilvl" select="$current_level"/>
        <xsl:with-param name="style" select="$style"/>
      </xsl:call-template>
      <xsl:call-template name="autocomplete">
        <xsl:with-param name="ilvl" select="$current_level + 1"/>
        <xsl:with-param name="style" select="$style"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="define-abstractNum">
    <xsl:param name="current" select="0"/>
    <xsl:param name="max" select="count(//ol[not(ancestor::ol) and not(ancestor::ul)]) + count(//ul[not(ancestor::ol) and not(ancestor::ul)])"/>
    <xsl:if test="$current &lt; $max">
      <w:num w:numId="{$current + 1}">
        <w:abstractNumId w:val="{$current}"/>
      </w:num>
      <xsl:call-template name="define-abstractNum">
        <xsl:with-param name="current" select="$current + 1"/>
        <xsl:with-param name="max" select="$max"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
