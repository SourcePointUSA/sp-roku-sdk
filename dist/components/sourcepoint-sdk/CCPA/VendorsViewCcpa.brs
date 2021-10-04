sub init()
    m.top.observeField("view", "renderView")
    m.top.observeField("privacyManagerViewData", "renderRightCol")
end sub

sub observeVendorList(event as object)
    index = event.getData()
    if index <> invalid then
        item = m.vendorList.buttonComponents[index]
        changeView("VendorDetailsView", m.top.privacyManagerViewData.vendors[item.id])
    end if
end sub

sub renderRightCol()
    hideRightColLoader()
    if m.components.text_vendor_header <> invalid then
        vendorsHeader = createObject("roSGNode", "SpNativeText")
        vendorsHeader.settings = m.components.text_vendor_header.settings
        m.colRight.appendChild(vendorsHeader)
    end if
    buttons = []
    for each vendorId in m.top.privacyManagerViewData.vendors
        buttonSettings = {
            ' on: m.top.privacyManagerViewData.vendors[vendorId].enabled
            settings: {}
        }
        buttonSettings.settings.append(m.components.button_vendor.settings)
        buttonSettings.id = vendorId
        buttonSettings.settings.text = m.top.privacyManagerViewData.vendors[vendorId].name
        buttons.push(buttonSettings)
    end for
    if buttons.count() > 0 then
        if m.vendorList = invalid then
            m.vendorList = createObject("roSGNode", "SpButtonList")
            m.vendorList.id = "vendor_list"
            m.vendorList.width = m.colRightWidth
            m.colRight.appendChild(m.vendorList)
            m.rightColFocus = m.vendorList
            m.vendorList.observeField("itemSelected", "observeVendorList")
        end if
        m.vendorList.buttonComponents = buttons
    end if
end sub

sub renderView(event as object)
    hasPmvData = getPrivacyManagerViewData(2)
    if hasPmvData = false then
        renderRightColLoader()
    end if
    view = event.getData()
    mapComponents(view)
    renderLogo()
    renderNav([])
    setFocus(m.back_button)
end sub