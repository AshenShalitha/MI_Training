<?xml version="1.0" encoding="UTF-8"?>
<!--
    Exercise 2: Logical functoids (AND, OR, NOT, Equal, Greater Than) and conditional mapping.
    India (IN) is the domestic country. Orders over 1000 are high value.
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>

    <!-- Value mapping table: country code to currency. Unlisted countries default to USD. -->
    <xsl:variable name="currencyTable">
        <entry code="IN">INR</entry>
        <entry code="LK">LKR</entry>
        <entry code="GB">GBP</entry>
        <entry code="US">USD</entry>
        <entry code="FR">EUR</entry>
        <entry code="DE">EUR</entry>
    </xsl:variable>

    <xsl:template match="/PurchaseOrder">
        <xsl:variable name="country" select="string(ShippingAddress/Country)"/>
        <xsl:variable name="tier" select="string(Customer/Tier)"/>
        <xsl:variable name="subTotal" select="xs:decimal(SubTotal)"/>

        <!-- Logical functoids: each variable is true or false. -->
        <xsl:variable name="isDomestic" select="$country = 'IN'"/>
        <xsl:variable name="isHighValue" select="$subTotal &gt; 1000"/>
        <xsl:variable name="isExpress" select="$tier = 'GOLD' or $isHighValue"/>

        <ShipmentInstruction>
            <OrderId><xsl:value-of select="OrderId"/></OrderId>
            <DestinationCountry><xsl:value-of select="$country"/></DestinationCountry>

            <!-- Conditional mapping by country -->
            <Warehouse>
                <xsl:choose>
                    <xsl:when test="$country = 'IN'">BLR-WH01</xsl:when>
                    <xsl:when test="$country = 'LK'">CMB-WH01</xsl:when>
                    <xsl:when test="$country = ('GB', 'FR', 'DE')">LON-WH02</xsl:when>
                    <xsl:otherwise>SIN-WH03</xsl:otherwise>
                </xsl:choose>
            </Warehouse>

            <!-- Value mapping with a lookup table and a default -->
            <Currency><xsl:value-of select="($currencyTable/entry[@code = $country], 'USD')[1]"/></Currency>

            <!-- Conditional mapping by tier, as an XPath if-then-else expression -->
            <LoyaltyDiscountPercent><xsl:value-of select="if ($tier = 'GOLD') then 10 else if ($tier = 'SILVER') then 5 else 0"/></LoyaltyDiscountPercent>

            <IsDomestic><xsl:value-of select="$isDomestic"/></IsDomestic>                                           <!-- Equal -->
            <IsHighValue><xsl:value-of select="$isHighValue"/></IsHighValue>                                        <!-- Greater Than -->
            <ExpressShipping><xsl:value-of select="$isExpress"/></ExpressShipping>                                  <!-- OR -->
            <CustomsDeclarationRequired><xsl:value-of select="not($isDomestic)"/></CustomsDeclarationRequired>      <!-- NOT -->
            <ManagerApprovalRequired><xsl:value-of select="$isHighValue and not($isDomestic)"/></ManagerApprovalRequired> <!-- AND + NOT -->

            <!-- Nested conditions -->
            <ShippingMethod>
                <xsl:choose>
                    <xsl:when test="$isDomestic and $tier = 'GOLD'">DOMESTIC-EXPRESS</xsl:when>
                    <xsl:when test="$isDomestic">DOMESTIC-STANDARD</xsl:when>
                    <xsl:when test="$isExpress">INTERNATIONAL-EXPRESS</xsl:when>
                    <xsl:otherwise>INTERNATIONAL-STANDARD</xsl:otherwise>
                </xsl:choose>
            </ShippingMethod>
        </ShipmentInstruction>
    </xsl:template>

</xsl:stylesheet>
