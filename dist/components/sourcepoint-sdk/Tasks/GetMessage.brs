sub init()
    m.top.functionName = "getMessage"
end sub

sub getMessage()
    url = m.global.config.baseEndpoint + "/wrapper/v2/message/" + m.top.legislation
    queryParams = {
        "env": m.global.config.env,
        "messageId": m.top.messageId,
        "propertyId": m.global.config.propertyId,
        "includeData": FormatJson({
            "categories": {
                "type": "RecordString"
            }
        })
    }
    response = makeRequest(addQueryParams(url, queryParams), "GET")
    if response <> invalid then
        m.top.message = response
    end if
end sub