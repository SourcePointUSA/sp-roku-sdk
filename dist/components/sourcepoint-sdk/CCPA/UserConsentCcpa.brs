sub init()
    m.top.observeField("userConsent", "ingestConsent")
    m.top.observeField("acceptCategory", "acceptCategory")
    m.top.observeField("acceptVendor", "acceptVendor")
    m.top.observeField("rejectCategory", "rejectCategory")
    m.top.observeField("rejectVendor", "rejectVendor")
    m.top.observeField("doNotSell", "fireConsentChange")
    m.rejectedCategories = []
    m.rejectedVendors = []
    m.newUser = invalid
end sub

sub acceptCategory(event as object)
    acceptedCategory = event.getData()
    for i = 0 to (m.rejectedCategories.count() - 1) step 1
        if m.rejectedCategories[i] = acceptedCategory then
            m.rejectedCategories.delete(i)
            exit for
        end if
    end for
    fireConsentChange()
end sub

sub acceptVendor(event as object)
    acceptedVendor = event.getData()
    for i = 0 to (m.rejectedVendors.count() - 1) step 1
        if m.rejectedVendors[i] = acceptedVendor then
            m.rejectedVendors.delete(i)
            exit for
        end if
    end for
    fireConsentChange()
end sub

function addConsentToPmvData(privacyManagerViewData as object) as object
    if privacyManagerViewData = invalid then
        return {}
    end if
    for each categoryId in privacyManagerViewData.categories
        ' for existing users, turn all on, we will turn off rejected below
        ' for new users, look at defaultOptedIn flag
        privacyManagerViewData.categories[categoryId].enabled = (function(__bsCondition, categoryId, privacyManagerViewData)
                if __bsCondition then
                    return privacyManagerViewData.categories[categoryId].defaultOptedIn
                else
                    return true
                end if
            end function)(m.newUser = true, categoryId, privacyManagerViewData)
    end for
    for each vendorId in privacyManagerViewData.vendors
        ' same for vendors
        privacyManagerViewData.vendors[vendorId].enabled = (function(__bsCondition, privacyManagerViewData, vendorId)
                if __bsCondition then
                    return privacyManagerViewData.vendors[vendorId].defaultOptedIn
                else
                    return true
                end if
            end function)(m.newUser = true, privacyManagerViewData, vendorId)
    end for
    for each categoryId in m.rejectedCategories
        if privacyManagerViewData.categories[categoryId] <> invalid then
            privacyManagerViewData.categories[categoryId].enabled = false
        end if
    end for
    for each vendorId in m.rejectedVendors
        if privacyManagerViewData.vendors[vendorId] <> invalid then
            privacyManagerViewData.vendors[vendorId].enabled = false
        end if
    end for
    return privacyManagerViewData
end function

sub ingestConsent(event as object)
    userConsent = event.getData()
    if userConsent.status <> "consentedAll" and userConsent.status <> "rejectedNone" then
        m.top.doNotSell = true
    end if
    if userConsent.rejectedCategories <> invalid then
        m.rejectedCategories = userConsent.rejectedCategories
    end if
    if userConsent.rejectedVendors <> invalid then
        m.rejectedVendors = userConsent.rejectedVendors
    end if
    m.newUser = userConsent.newUser
end sub

sub rejectCategory(event as object)
    found = false
    rejectedCategory = event.getData()
    for each cat in m.rejectedCategories
        if rejectedCategory = cat then
            found = true
        end if
    end for
    if found = false then
        m.rejectedCategories.push(rejectedCategory)
    end if
    fireConsentChange()
end sub

sub rejectVendor(event as object)
    found = false
    rejectedVendor = event.getData()
    for each vendor in m.rejectedVendors
        if rejectedVendor = vendor then
            found = true
        end if
    end for
    if found = false then
        m.rejectedVendors.push(rejectedVendor)
    end if
    fireConsentChange()
end sub

sub fireConsentChange()
    m.top.consentChanged = getSaveAndExitVariables()
end sub

function getSaveAndExitVariables() as object
    return {
        "lan": m.global.config.consentLanguage,
        "privacyManagerId": m.top.messageId.toStr(),
        "rejectedCategories": m.rejectedCategories,
        "rejectedVendors": m.rejectedVendors
    }
end function