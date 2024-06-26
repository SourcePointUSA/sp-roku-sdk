sub init()
    m.top.functionName = "createButtonSections"
end sub

sub createButtonSections()
    buttons = []
    buttonVendorSettings = m.top.buttonVendorSettings
    try
        vendors = m.top.privacyManagerViewData.vendors
        for each vendorId in vendors
            buttonSettings = {
                ' on: m.top.privacyManagerViewData.vendors[vendorId].enabled
                settings: {},
                showCustom: vendors[vendorId].vendorType = "CUSTOM"
            }
            buttonSettings.settings.append(buttonVendorSettings)
            buttonSettings.id = vendorId
            buttonSettings.settings.text = vendors[vendorId].name
            buttons.push(buttonSettings)
        end for
    catch e
        m.top.error = e.message
    end try
    m.top.buttons = buttons
end sub