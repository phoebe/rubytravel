//*[@class="vcard"]
//*[contains(@class,"vcard")]
<xsl:for-each select="//*[contains(concat(" ",@class," "), " vcard ")]">
<xsl:text>BEGIN:VCARD</xsl:text>
<xsl:apply-templates />
	<xsl:text>END:VCARD</xsl:text>
</xsl:for-each>
<xsl:for-each select="//*[contains(concat(" ",@class," "), " vcard ")]">
	<xsl:text>BEGIN:VCARD</xsl:text>
	<xsl:apply-templates />
	<xsl:text>END:VCARD</xsl:text>
</xsl:for-each>

<xsl:template match="//*[contains(concat(" ",@class," "), " url ")]">
	<xsl:text>URL:</xsl:text>
	<xsl:choose>
		<xsl:when test="local-name() = 'a'">
			<vxsl:alue-of select="@href"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="."/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

