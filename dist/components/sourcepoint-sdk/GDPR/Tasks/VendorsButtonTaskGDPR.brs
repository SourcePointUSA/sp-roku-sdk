sub init()
    m.top.functionName = "createButtonSections"
end sub

sub createButtonSections()
    buttons = []
    buttonsLi = []
    try
        buttonSettingsSettings = m.top.buttonSettings
        if m.top.privacyManagerViewData.vendors <> invalid then
            vendors = m.top.privacyManagerViewData.vendors
            for each vendorId in vendors
                buttonSettings = {
                    on: vendors[vendorId].enabled,
                    settings: {},
                    showCustom: vendors[vendorId].vendorType = "CUSTOM"
                }
                buttonSettings.settings.append(buttonSettingsSettings)
                buttonSettings.id = vendorId
                buttonSettings.settings.text = vendors[vendorId].name
                buttons.push(buttonSettings)
            end for
        end if
        if m.top.privacyManagerViewData.legIntVendors <> invalid and m.top.privacyManagerViewData.legIntVendors.count() > 0 then
            vendors = m.top.privacyManagerViewData.legIntVendors
            for each vendorId in vendors
                buttonSettings = {
                    on: vendors[vendorId].enabled,
                    settings: {}
                }
                buttonSettings.settings.append(buttonSettingsSettings)
                buttonSettings.id = vendorId
                buttonSettings.settings.text = vendors[vendorId].name
                buttonsLi.push(buttonSettings)
            end for
        end if
    catch e
        m.top.error = e.message
    end try
    m.top.buttons = {
        buttons: buttons,
        buttonsLi: buttonsLi
    }
end sub