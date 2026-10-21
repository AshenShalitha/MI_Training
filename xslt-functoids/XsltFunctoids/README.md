# XsltFunctoids

Reference solution for the XSLT hands-on practical. It shows how common BizTalk mapper functoids are implemented with the XSLT mediator in WSO2 Integrator: MI 4.6.

One API, `OrderXsltAPI` (context `/xslt/orders`), has four `POST` resources. Each resource applies one XSLT 2.0 stylesheet from `src/main/wso2mi/resources/xslt`:

| Resource | Stylesheet | Covers |
|---|---|---|
| `/xslt/orders/scripting` | `OrderScripting.xslt` | String manipulation, date conversion (`format-date`, date arithmetic), calculations, `xsl:function` |
| `/xslt/orders/logical` | `OrderRouting.xslt` | `and`, `or`, `not()`, `=`, `>`, `xsl:choose`, a value-mapping lookup table |
| `/xslt/orders/existence` | `CustomerProfile.xslt` | Existence checks, null/empty/whitespace handling, defaults, conditional output nodes |
| `/xslt/orders/loops` | `OrderLines.xslt` | `xsl:for-each` over a filtered repeating record, `count()`, `sum()` |

MI 4.6.0 ships Saxon-HE 10.9, so XSLT 2.0 features such as `xsl:function`, `format-date` and `if … then … else` work in the XSLT mediator. This was verified on MI 4.6.0.

## Samples

- `samples/input/purchase-order.xml`: a complete order with three items, one of which has quantity 0.
- `samples/input/purchase-order-incomplete.xml`: a whitespace-only email, an empty phone, no middle name, no postal code and a single item.
- `samples/expected-output/*.xml`: verified responses from MI 4.6.0 for both inputs.

## Build and test

```
mvn clean install -Dmaven.test.skip=true
curl -X POST -H "Content-Type: application/xml" --data-binary @samples/input/purchase-order.xml http://localhost:8290/xslt/orders/scripting
```
