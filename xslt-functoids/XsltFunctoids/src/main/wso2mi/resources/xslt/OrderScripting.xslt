<?xml version="1.0" encoding="UTF-8"?>
<!--
    Exercise 1: Scripting functoid (string manipulation, date conversion, calculation).
    Custom logic is written as xsl:function, the XSLT equivalent of a BizTalk Scripting functoid.
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:training:functions"
    exclude-result-prefixes="xs local">

    <xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>

    <!-- Converts "  jOHN " to "John". -->
    <xsl:function name="local:title-case" as="xs:string">
        <xsl:param name="value"/>
        <xsl:variable name="text" select="lower-case(normalize-space($value))"/>
        <xsl:sequence select="concat(upper-case(substring($text, 1, 1)), substring($text, 2))"/>
    </xsl:function>

    <!-- Rounds a number to two decimal places. -->
    <xsl:function name="local:round2" as="xs:decimal">
        <xsl:param name="value" as="xs:decimal"/>
        <xsl:sequence select="round($value * 100) div 100"/>
    </xsl:function>

    <xsl:template match="/PurchaseOrder">
        <xsl:variable name="subTotal" select="xs:decimal(SubTotal)"/>
        <xsl:variable name="taxAmount" select="$subTotal * xs:decimal(TaxRate) div 100"/>
        <xsl:variable name="orderDate" select="xs:date(OrderDate)"/>

        <CustomerInvoice>
            <InvoiceNumber><xsl:value-of select="concat('INV-', upper-case(OrderId))"/></InvoiceNumber>
            <CustomerName><xsl:value-of select="concat(local:title-case(Customer/FirstName), ' ', local:title-case(Customer/LastName))"/></CustomerName>
            <CustomerInitials><xsl:value-of select="upper-case(concat(substring(normalize-space(Customer/FirstName), 1, 1), substring(normalize-space(Customer/LastName), 1, 1)))"/></CustomerInitials>
            <Email><xsl:value-of select="lower-case(normalize-space(Customer/Email))"/></Email>
            <InvoiceDate><xsl:value-of select="format-date($orderDate, '[D01]/[M01]/[Y0001]')"/></InvoiceDate>
            <DueDate><xsl:value-of select="format-date($orderDate + xs:dayTimeDuration('P30D'), '[D01]/[M01]/[Y0001]')"/></DueDate>
            <SubTotal><xsl:value-of select="SubTotal"/></SubTotal>
            <TaxAmount><xsl:value-of select="local:round2($taxAmount)"/></TaxAmount>
            <ShippingCharge><xsl:value-of select="ShippingCharge"/></ShippingCharge>
            <GrandTotal><xsl:value-of select="local:round2($subTotal + $taxAmount + xs:decimal(ShippingCharge))"/></GrandTotal>
        </CustomerInvoice>
    </xsl:template>

</xsl:stylesheet>
