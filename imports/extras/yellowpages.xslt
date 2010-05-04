<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text"/>

<xsl:template match="/">
   <xsl:apply-templates select="//tr"/>
</xsl:template>

<xsl:template match="tr">
  "<xsl:value-of select="td/span/a/span"/>","<xsl:value-of select="td[position()=2]/span"/>","<xsl:value-of select="td[position()=3]/span/span[position()=1]"/>"
</xsl:template>

</xsl:stylesheet>

