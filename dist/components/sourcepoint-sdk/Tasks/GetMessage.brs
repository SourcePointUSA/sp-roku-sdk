sub init()
    m.top.functionName = "getMessage"
end sub

sub getMessage()
    url = m.global.config.baseEndpoint + "/wrapper/v2/message/" + m.top.legislation
    queryParams = {
        "env": m.global.config.env,
        "messageId": m.top.messageId,
        "propertyId": m.global.config.propertyId,
        "consentLanguage": m.global.config.consentLanguage,
        "includeData": FormatJson({
            "categories": {
                "type": "RecordString"
            },
            "translateMessage": true
        })
    }
    response = makeRequest(addQueryParams(url, queryParams), "GET")
    if response <> invalid and response.messageMetaData <> invalid then
        if (response.messageMetaData.categoryId = 1 or response.messageMetaData.categoryId = 2) and response.messageMetaData.subCategoryId = 14 then
            m.top.message = response
        else
            print "WARNING: invalid message type for message " + m.top.messageId.toStr() + ", ignoring"
        end if
    end if
end sub