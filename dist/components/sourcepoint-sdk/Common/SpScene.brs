sub init()
    m.top.observeField("activeCampaign", "showMessage")
    m.top.observeField("campaigns", "incrementCampaign")
    m.userConsent = {}
end sub

sub addError(error as string)
    errors = m.top.errors
    errors.push(error)
    m.top.errors = errors
end sub

sub closeMessage()
    if m.currentMessage <> invalid then
        m.top.removeChild(m.currentMessage)
        m.currentMessage.unobserveField("done")
        if m.currentMessage.error <> "" then
            addError(m.currentMessage.error)
        end if
        m.userConsent[m.currentMessage.messageCategory] = m.currentMessage.userConsent
        m.currentMessage = invalid
    end if
    incrementCampaign()
end sub

sub incrementCampaign()
    activeCampaign = m.top.activeCampaign
    if activeCampaign = invalid then
        activeCampaign = 0
    else
        activeCampaign = activeCampaign + 1
    end if
    m.top.activeCampaign = activeCampaign
end sub

sub showMessage()
    m.currentMessage = CreateObject("roSGNode", "SpMessage")
    campaigns = m.top.campaigns
    campaign = campaigns[m.top.activeCampaign]
    if campaign <> invalid then
        try
            m.currentMessage.observeField("done", "closeMessage")
            m.currentMessage.userConsent = campaign.userConsent
            m.currentMessage.message = campaign
            m.top.appendChild(m.currentMessage)
            m.currentMessage.setFocus(true)
        catch e
            addError(e.message)
            closeMessage()
        end try
    else ' signal that we're done, return consent
        m.top.userConsent = m.userConsent
    end if
end sub