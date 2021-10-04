sub init()
    m.top.functionName = "getMessage"
end sub

sub getMessage()
    requestBody = {
        "accountId": m.top.accountId,
        "authId": m.top.authId,
        "campaignEnv": m.top.campaignEnv,
        "campaigns": {},
        "clientMMSOrigin": m.top.clientMMSOrigin,
        "consentLanguage": m.top.consentLanguage,
        "hasCSP": true,
        "includeData": {
            "localState": {
                "type": "string"
            },
            "customVendorsResponse": {
                "type": "string"
            }
        },
        "localState": m.top.localState,
        "propertyHref": m.top.propertyHref,
        "pubData": m.top.pubData,
        "requestUUID": m.top.requestUUID
    }
    for each l in m.top.legislationsEnabled
        requestBody.campaigns[l] = m.top.legislationsEnabled[l]
    end for
    response = makeRequest(m.top.url, "POST", requestBody)
    if response <> invalid then
        m.top.propertyId = response.propertyId
        campaigns = []
        for each c in response.campaigns
            if c.message <> invalid then
                campaigns.push(c)
            end if
        end for
        m.top.campaigns = campaigns
        ' parse and set user consent
        userConsent = {}
        for each c in response.campaigns
            if c.userConsent <> invalid then
                userConsent[c.type] = c.userConsent
            end if
        end for
        m.top.userConsent = userConsent
    end if
end sub