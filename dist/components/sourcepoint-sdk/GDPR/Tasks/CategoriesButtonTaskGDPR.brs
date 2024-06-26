sub init()
    m.top.functionName = "createButtonSections"
end sub

sub createButtonSections()
    buttonsLi = []
    sections = []
    try
        buttonCategorySettings = m.top.buttonCategorySettings
        categoryTypes = m.top.categoryTypes
        categoryTypeOrder = [
            "categories",
            "features",
            "specialPurposes",
            "specialFeatures"
        ]
        if m.top.privacyManagerViewData.legIntCategories <> invalid then
            categories = m.top.privacyManagerViewData.legIntCategories
            for each id in categories
                buttonSettings = {
                    categoryType: "legInt",
                    on: categories[id].enabled,
                    settings: {},
                    showCustom: categories[id].type = "CUSTOM"
                }
                buttonSettings.settings.append(buttonCategorySettings)
                buttonSettings.id = id
                buttonSettings.settings.text = categories[id].name
                buttonsLi.push(buttonSettings)
            end for
        end if
        categoryTypeOrder = [
            "categories",
            "features",
            "specialPurposes",
            "specialFeatures"
        ]
        sections = []
        for each cType in categoryTypeOrder
            buttons = []
            if m.top.privacyManagerViewData[cType] <> invalid then
                categories = m.top.privacyManagerViewData[cType]
                for each id in categories
                    listItem = categories[id]
                    if (listItem.vendors <> invalid and listItem.vendors.count() > 0) or (listItem.disclosureOnly = true) or (listItem.requiringConsentVendors <> invalid and listItem.requiringConsentVendors.count() > 0) then
                        buttonSettings = {
                            categoryType: cType,
                            on: listItem.enabled,
                            settings: {},
                            showCustom: listItem.type = "CUSTOM"
                        }
                        buttonSettings.settings.append(buttonCategorySettings)
                        buttonSettings.id = id
                        buttonSettings.settings.text = listItem.name
                        buttons.push(buttonSettings)
                    end if
                end for
            end if
            if buttons.count() > 0 then
                section = {
                    children: buttons
                }
                if categoryTypes[cType].headerComponent <> invalid then
                    section.settings = categoryTypes[cType].headerComponent.settings
                end if
                if categoryTypes[cType].defComponent <> invalid then
                    section.settingsDesc = categoryTypes[cType].defComponent.settings
                end if
                sections.push(section)
            end if
        end for
    catch e
        m.top.error = e.message
    end try
    m.top.buttons = {
        "buttonsLi": buttonsLi,
        "sections": sections
    }
end sub