<?xml version="1.0" encoding="UTF-8"?>
<!--
    Exercise 3: Existence checks.
    Handles missing, empty and whitespace-only values, applies defaults, and creates
    DeliveryAddress only when all of its required fields are present.
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="urn:training:functions"
    exclude-result-prefixes="xs local">

    <xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>

    <!-- Existence check: false when the element is missing, empty or only whitespace. -->
    <xsl:function name="local:has-value" as="xs:boolean">
        <xsl:param name="node"/>
        <xsl:sequence select="normalize-space(string-join($node, '')) != ''"/>
    </xsl:function>

    <!-- Returns the trimmed value, or the default when the value does not exist. -->
    <xsl:function name="local:value-or-default" as="xs:string">
        <xsl:param name="node"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:sequence select="if (local:has-value($node)) then normalize-space($node) else $default"/>
    </xsl:function>

    <xsl:template match="/PurchaseOrder">
        <xsl:variable name="address" select="ShippingAddress"/>

        <CustomerProfile>
            <OrderId><xsl:value-of select="OrderId"/></OrderId>
            <FullName><xsl:value-of select="concat(normalize-space(Customer/FirstName), ' ', normalize-space(Customer/LastName))"/></FullName>

            <!-- Optional element: created only when the source has a value -->
            <xsl:if test="local:has-value(Customer/MiddleName)">
                <MiddleName><xsl:value-of select="normalize-space(Customer/MiddleName)"/></MiddleName>
            </xsl:if>

            <!-- Default values -->
            <Email><xsl:value-of select="local:value-or-default(Customer/Email, 'NOT PROVIDED')"/></Email>
            <Phone><xsl:value-of select="local:value-or-default(Customer/Phone, 'NOT PROVIDED')"/></Phone>

            <!-- Existence flags -->
            <EmailProvided><xsl:value-of select="local:has-value(Customer/Email)"/></EmailProvided>
            <PhoneProvided><xsl:value-of select="local:has-value(Customer/Phone)"/></PhoneProvided>

            <!-- Conditional node: created only when ALL required fields are present.
                 Check each field explicitly. "every $f in (Street, PostalCode) satisfies ..." would
                 wrongly return true when PostalCode is missing, because a missing element is
                 simply not in the sequence. -->
            <xsl:if test="local:has-value($address/Street) and local:has-value($address/City)
                          and local:has-value($address/PostalCode) and local:has-value($address/Country)">
                <DeliveryAddress>
                    <Street><xsl:value-of select="normalize-space($address/Street)"/></Street>
                    <City><xsl:value-of select="normalize-space($address/City)"/></City>
                    <PostalCode><xsl:value-of select="normalize-space($address/PostalCode)"/></PostalCode>
                    <Country><xsl:value-of select="normalize-space($address/Country)"/></Country>
                </DeliveryAddress>
            </xsl:if>

            <ProfileStatus>
                <xsl:value-of select="if (local:has-value(Customer/Email) and local:has-value(Customer/Phone)
                                          and local:has-value($address/PostalCode)) then 'COMPLETE' else 'INCOMPLETE'"/>
            </ProfileStatus>
        </CustomerProfile>
    </xsl:template>

</xsl:stylesheet>
