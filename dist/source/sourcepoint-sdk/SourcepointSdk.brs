function __SourcepointSdk_builder()
    instance = {}
    instance.new = sub(accountId as integer, propertyHref as string, legislationsEnabled = {} as object, optional = {} as object, showMessages = true as boolean)
        m.accountId = invalid
        m.authId = invalid
        m.env = "prod"
        m.errors = []
        m.campaignEnv = "prod"
        m.consentLanguage = invalid
        m.legislationsEnabled = invalid
        m.propertyHref = invalid
        m.propertyId = invalid
        m.scene = invalid
        m.screen = invalid
        m.userConsent = invalid
        m.constants = {
            baseEndpoint: "https://cdn.privacy-mgmt.com",
            pathGET: "/wrapper/v2/get_messages"
        }
        m.accountId = accountId
        m.propertyHref = propertyHref
        m.legislationsEnabled = legislationsEnabled
        validOptionalProperties = [
            "authId",
            "campaignEnv",
            "consentLanguage"
        ]
        for each k in validOptionalProperties
            if optional[k] <> invalid then
                m[k] = optional[k]
            end if
        end for
        if optional.baseEndpoint <> invalid then
            m.constants.baseEndpoint = optional.baseEndpoint
        end if
        m.globalConfig = {
            "accountId": m.accountId,
            "authId": m.authId,
            "baseEndpoint": m.constants.baseEndpoint,
            "consentLanguage": m.consentLanguage,
            "env": m.env,
            "requestUUID": m.makeRequestUUID()
        }
        ' fetch messages and user consent, and messages
        if showMessages = true then
            m.getUserConsent()
        end if
    end sub
    instance.createScreen = sub()
        ' create screen
        m.screen = CreateObject("roSGScreen")
        m.port = CreateObject("roMessagePort")
        m.screen.setMessagePort(m.port)
        m.scene = m.screen.CreateScene("SpScene")
        m.global = m.screen.getGlobalNode()
        m.global.addField("config", "assocarray", true)
        m.global.config = m.globalConfig
    end sub
    instance.closeScreen = sub()
        m.screen.close()
    end sub
    instance.formatUserConsent = function(userConsent as object) as object
        formattedConsent = {}
        if userConsent.ccpa <> invalid then
            formattedConsent["ccpa"] = {
                uspstring: userConsent.ccpa.uspstring
            }
        endif
        if userConsent.gdpr <> invalid then
            formattedConsent["gdpr"] = {
                grants: userConsent.gdpr.grants
            }
        endif
        return formattedConsent
    end function
    instance.getErrors = function() as object
        return m.errors
    end function
    instance.getUserConsent = function() as dynamic
        if m.userConsent <> invalid then
            return m.userConsent
        endif
        ' create screen before we make our task
        m.createScreen()
        getMessageTask = createObject("roSGNode", "GetMessages")
        getMessageTask.url = addQueryParams(m.constants.baseEndpoint + m.constants.pathGET, {
            "env": m.env,
            "consentLanguage": m.consentLanguage
        })
        getMessageTask.clientMMSOrigin = m.constants.baseEndpoint
        taskKeys = [
            "accountId",
            "authId",
            "campaignEnv",
            "consentLanguage",
            "legislationsEnabled",
            "propertyHref",
            "pubData",
            "requestUUID"
        ]
        for each k in taskKeys
            getMessageTask[k] = m[k]
        end for
        getMessageTask.localState = getLocalState()
        getMessageTask.control = "RUN"
        port = CreateObject("roMessagePort")
        getMessageTask.observeFieldScoped("state", port)
        while true
            msg = wait(1000, port)
            if type(msg) = "roSGNodeEvent" and msg.getField() = "state" and msg.getData() = "stop" then
                if getMessageTask.error <> "" then
                    m.errors.push(getMessageTask.error)
                    return invalid
                end if
                m.userConsent = getMessageTask.userConsent
                m.setPropertyId(getMessageTask.propertyId)
                exit while
            end if
        end while
        getMessageTask.unobserveFieldScoped("state")
        ' always call show messages, it will show or close our screen
        m.showMessages(getMessageTask.campaigns)
        return m.formatUserConsent(m.userConsent)
    end function
    instance.openPrivacyManager = sub(legislation as string, messageId as integer)
        if m.userConsent = invalid then
            throw "Run the user campaign by calling getUserConsent() before calling openPrivacyManager()"
        end if
        ' create screen before we make our task
        m.createScreen()
        port = CreateObject("roMessagePort")
        getMessageTask = createObject("roSGNode", "GetMessage")
        getMessageTask.legislation = legislation
        getMessageTask.messageId = messageId
        getMessageTask.observeFieldScoped("state", port)
        getMessageTask.control = "RUN"
        while true
            msg = wait(1000, port)
            if type(msg) = "roSGNodeEvent" and msg.getField() = "state" and msg.getData() = "stop" then
                message = getMessageTask.message
                ' set user consent if we have it (which we should)
                if m.userConsent <> invalid and m.userConsent[legislation] <> invalid then
                    message.userConsent = m.userConsent[legislation]
                end if
                m.showMessages([
                    message
                ])
                exit while
            end if
        end while
        getMessageTask.unobserveFieldScoped("state")
    end sub
    instance.makeRequestUUID = function() as string
        di = CreateObject("roDeviceInfo")
        return di.getRandomUUID()
    end function
    instance.runCampaignLogic = function(legislationsEnabled = invalid as object)
        m.userConsent = invalid
        if legislationsEnabled <> invalid then
            m.legislationsEnabled = legislationsEnabled
        end if
        return m.getUserConsent()
    end function
    instance.showMessages = sub(campaigns as object)
        ' close screen and return if we have no messages
        if campaigns = invalid or campaigns.Count() = 0 then
            m.closeScreen()
            return
        end if
        m.scene.campaigns = campaigns
        m.screen.show()
        m.scene.observeFieldScoped("userConsent", m.port)
        while (true)
            msg = wait(0, m.port)
            msgType = type(msg)
            if msgType = "roSGNodeEvent" and msg.getField() = "userConsent" then
                m.userConsent = msg.getData()
                m.errors = m.scene.errors
                m.screen.close()
            end if
            if msgType = "roSGScreenEvent" then
                if msg.isScreenClosed() then
                    return
                end if
            end if
        end while
    end sub
    instance.setPropertyId = sub(propertyId as integer)
        m.propertyId = propertyId
        m.globalConfig.propertyId = propertyId
        ' update global config if it has been created
        if m.global.config <> invalid then
            m.global.config = m.globalConfig
        end if
    end sub
    return instance
end function
function SourcepointSdk(accountId as integer, propertyHref as string, legislationsEnabled = {} as object, optional = {} as object, showMessages = true as boolean)
    instance = __SourcepointSdk_builder()
    instance.new(accountId, propertyHref, legislationsEnabled, optional, showMessages)
    return instance
end function