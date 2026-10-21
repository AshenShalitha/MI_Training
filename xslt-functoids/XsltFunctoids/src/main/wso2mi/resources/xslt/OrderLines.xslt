<?xml version="1.0" encoding="UTF-8"?>
<!--
    Exercise 4: Loops and repeating records.
    Maps each Items/Item with Quantity > 0 to a Lines/Line, and adds a record count and a cumulative sum.
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:training:functions"
    exclude-result-prefixes="xs local">

    <xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>

    <!-- Quantity x unit price, less the discount percentage, rounded to two decimals. -->
    <xsl:function name="local:line-total" as="xs:decimal">
        <xsl:param name="item"/>
        <xsl:sequence select="round(xs:decimal($item/Quantity) * xs:decimal($item/UnitPrice)
                                    * (100 - xs:decimal($item/Discount))) div 100"/>
    </xsl:function>

    <xsl:template match="/PurchaseOrder">
        <!-- Looping + Logical functoid: only items with a quantity greater than zero -->
        <xsl:variable name="lines" select="Items/Item[xs:decimal(Quantity) gt 0]"/>

        <SalesOrder>
            <OrderId><xsl:value-of select="upper-case(OrderId)"/></OrderId>

            <!-- Record Count functoid -->
            <LineCount><xsl:value-of select="count($lines)"/></LineCount>

            <!-- Cumulative Sum functoid -->
            <OrderTotal><xsl:value-of select="sum(for $item in $lines return local:line-total($item))"/></OrderTotal>

            <!-- Looping functoid: one Line per matching Item -->
            <Lines>
                <xsl:for-each select="$lines">
                    <Line>
                        <ProductCode><xsl:value-of select="upper-case(Sku)"/></ProductCode>
                        <Description><xsl:value-of select="Name"/></Description>
                        <Quantity><xsl:value-of select="Quantity"/></Quantity>
                        <UnitPrice><xsl:value-of select="UnitPrice"/></UnitPrice>
                        <DiscountPercent><xsl:value-of select="Discount"/></DiscountPercent>
                        <LineTotal><xsl:value-of select="local:line-total(.)"/></LineTotal>
                    </Line>
                </xsl:for-each>
            </Lines>
        </SalesOrder>
    </xsl:template>

</xsl:stylesheet>
