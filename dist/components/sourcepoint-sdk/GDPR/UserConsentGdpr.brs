sub init()
    m.top.observeField("acceptCategory", "acceptCategory")
    m.top.observeField("acceptLiCategory", "acceptLiCategory")
    m.top.observeField("acceptVendor", "acceptVendor")
    m.top.observeField("acceptLiVendor", "acceptLiVendor")
    m.top.observeField("acceptSpecialFeature", "acceptSpecialFeature")
    m.top.observeField("rejectCategory", "rejectCategory")
    m.top.observeField("rejectLiCategory", "rejectLiCategory")
    m.top.observeField("rejectVendor", "rejectVendor")
    m.top.observeField("rejectLiVendor", "rejectLiVendor")
    m.top.observeField("rejectSpecialFeature", "rejectSpecialFeature")
    m.top.observeField("userConsent", "ingestConsent")
    m.legIntCategories = []
end sub

sub acceptCategory(event as object)
    updatePmvConsent("categories", event.getData(), true)
    fireConsentChange()
end sub

sub acceptLiCategory(event as object)
    updatePmvConsent("legIntCategories", event.getData(), true)
    fireConsentChange()
end sub

sub acceptVendor(event as object)
    updatePmvConsent("vendors", event.getData(), true)
    fireConsentChange()
end sub

sub acceptLiVendor(event as object)
    updatePmvConsent("legIntVendors", event.getData(), true)
    fireConsentChange()
end sub

sub acceptSpecialFeature(event as object)
    updatePmvConsent("specialFeatures", event.getData(), true)
    fireConsentChange()
end sub

sub rejectCategory(event as object)
    updatePmvConsent("categories", event.getData(), false)
    fireConsentChange()
end sub

sub rejectLiCategory(event as object)
    updatePmvConsent("legIntCategories", event.getData(), false)
    fireConsentChange()
end sub

sub rejectVendor(event as object)
    updatePmvConsent("vendors", event.getData(), false)
    fireConsentChange()
end sub

sub rejectLiVendor(event as object)
    updatePmvConsent("legIntVendors", event.getData(), false)
    fireConsentChange()
end sub

sub rejectSpecialFeature(event as object)
    updatePmvConsent("specialFeatures", event.getData(), false)
    fireConsentChange()
end sub

function addConsentToPmvData(privacyManagerViewData as object) as object
    ' this is a no-op for GDPR, "enabled" comes with the data
    ' we do want to ingest this data so we can update it
    if m.top.privacyManagerViewConsent = invalid then
        m.top.privacyManagerViewConsent = privacyManagerViewData
        return privacyManagerViewData
    else
        return m.top.privacyManagerViewConsent
    end if
end function

sub ingestConsent(event as object)
    userConsent = event.getData()
    m.grants = {}
    if userConsent.grants <> invalid then
        m.grants = userConsent.grants
    end if
end sub

sub fireConsentChange()
    m.top.consentChanged = m.top.privacyManagerViewConsent
end sub

function getConsentedCategories() as object
    consentedCategories = []
    if m.top.privacyManagerViewConsent <> invalid then
        categories = m.top.privacyManagerViewConsent.categories
        legIntCategories = m.top.privacyManagerViewConsent.legIntCategories
        ' iterate through categories to find enabled cats
        if categories <> invalid then
            for each categoryId in categories
                consentedCat = {
                    consent: categories[categoryId].enabled,
                    "legInt": false,
                    "iabId": categories[categoryId].iabId,
                    "type": categories[categoryId]["type"],
                    "_id": categories[categoryId]["_id"]
                }
                ' if this category is also leg int enabled, say so
                if legIntCategories[categoryId] <> invalid and legIntCategories[categoryId].enabled = true then
                    consentedCat["legInt"] = true
                end if
                consentedCategories.push(consentedCat)
            end for
        end if
        ' iterate through leg int categories to find enabled cats
        if legIntCategories <> invalid then
            for each categoryId in legIntCategories
                if categories[categoryId] = invalid then
                    ' this category is not in regular categories it is legInt only so we did not cover it above
                    consentedCat = {
                        consent: false,
                        "legInt": legIntCategories[categoryId].enabled,
                        "iabId": legIntCategories[categoryId].iabId,
                        "type": legIntCategories[categoryId]["type"],
                        "_id": legIntCategories[categoryId]["_id"]
                    }
                    consentedCategories.push(consentedCat)
                end if
            end for
        end if
    end if
    return consentedCategories
end function

function getConsentedVendors() as object
    consentedVendors = []
    if m.top.privacyManagerViewConsent <> invalid then
        vendors = m.top.privacyManagerViewConsent.vendors
        legIntVendors = m.top.privacyManagerViewConsent.legIntVendors
        ' iterate through categories to find enabled cats
        if vendors <> invalid then
            for each vendorId in vendors
                consentedVendor = {
                    consent: vendors[vendorId].enabled,
                    "legInt": false,
                    "iabId": vendors[vendorId].iabId,
                    "vendorType": vendors[vendorId].vendorType,
                    "_id": vendors[vendorId].vendorId
                }
                if legIntVendors[vendorId] <> invalid and legIntVendors[vendorId].enabled = true then
                    consentedVendor["legInt"] = true
                end if
                consentedVendors.push(consentedVendor)
            end for
        end if
        ' iterate through leg int categories to find enabled cats
        if legIntVendors <> invalid then
            for each vendorId in legIntVendors
                if vendors[vendorId] = invalid then
                    ' this vendor is not in regular vendors it is legInt only so we did not cover it above
                    consentedVendor = {
                        consent: false,
                        "legInt": legIntVendors[vendorId].enabled,
                        "iabId": legIntVendors[vendorId].iabId,
                        "vendorType": legIntVendors[vendorId].vendorType,
                        "_id": legIntVendors[vendorId].vendorId
                    }
                    consentedVendors.push(consentedVendor)
                end if
            end for
        end if
    end if
    return consentedVendors
end function

function getSaveAndExitVariables() as object
    return {
        "lan": m.global.sourcepointConfig.consentLanguage,
        "privacyManagerId": m.top.messageId.toStr(),
        "categories": getConsentedCategories(),
        "specialFeatures": [], ' TODO - what is this?
        "vendors": getConsentedVendors()
    }
end function

sub updatePmvConsent(categoryType as string, categoryId as string, enabled as boolean)
    pmvConsent = m.top.privacyManagerViewConsent
    grants = m.grants
    if pmvConsent[categoryType] <> invalid and pmvConsent[categoryType][categoryId] <> invalid then
        pmvConsent[categoryType][categoryId].enabled = enabled
        if categoryType = "categories" or categoryType = "legIntCategories" then
            ' Toggle on or off vendors 
            cat = pmvConsent[categoryType][categoryId]
            ' get correct vendors
            vendors = (function(__bsCondition, cat)
                    if __bsCondition then
                        return cat.requiringConsentVendors
                    else
                        return cat.legIntVendors
                    end if
                end function)(categoryType = "categories", cat)
            vendorType = bslib_ternary(categoryType = "categories", "vendors", "legIntVendors")
            ' for each vendor update their category data in grants
            ' update their vendorGrant based on that
            ' update their enabled based on the vendorGrant
            for each v in vendors
                if v.vendorId <> invalid then
                    if grants[v.vendorId] = invalid then
                        ' create grant data if it doesn't exist
                        grants[v.vendorId] = {
                            vendorGrant: false,
                            purposeGrants: {}
                        }
                    end if
                    ' update purpose grant for this category
                    grants[v.vendorId].purposeGrants[categoryId] = enabled
                    ' update vendorGrant based on whether any categories are enabled
                    vendorGrant = true
                    vendorEnabled = false
                    for each c in grants[v.vendorId].purposeGrants
                        purposeGrant = grants[v.vendorId].purposeGrants[c]
                        ' if the purposeGrant is enabled for this vendor
                        ' AND that category is enabled in this category type (consent or LI)
                        ' then this vendor is enabled
                        if purposeGrant = true and pmvConsent[categoryType] <> invalid and pmvConsent[categoryType][c] <> invalid and pmvConsent[categoryType][c].enabled = true then
                            vendorEnabled = true
                        end if
                        ' if any purposeGrant is false, then the vendorGrant is false
                        if purposeGrant = false then
                            vendorGrant = false
                        end if
                    end for
                    grants[v.vendorId].vendorGrant = vendorGrant
                    pmvConsent[vendorType][v.vendorId].enabled = vendorEnabled
                end if
            end for
        end if
        m.grants = grants
        m.top.privacyManagerViewConsent = pmvConsent
    end if
end sub