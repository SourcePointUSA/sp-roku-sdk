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
    if m.buttonTask = invalid then
        m.buttonTask = createObject("roSGNode", "VendorsButtonTaskCCPA")
        m.buttonTask.privacyManagerViewData = m.top.privacyManagerViewData
        m.buttonTask.buttonVendorSettings = m.components.button_vendor.settings
        m.buttonTask.observeField("buttons", "renderButtonLists")
        m.buttonTask.observeField("error", "onError")
        m.buttonTask.control = "RUN"
    else
        renderButtonLists()
    end if
end sub

sub renderButtonLists()
    buttons = m.buttonTask.buttons
    hideRightColLoader()
    if m.vendorsHeader = invalid and m.components.text_vendor_header <> invalid then
        m.vendorsHeader = createObject("roSGNode", "SpNativeText")
        m.vendorsHeader.settings = m.components.text_vendor_header.settings
        m.colRight.appendChild(m.vendorsHeader)
    end if
    if buttons <> invalid and buttons.count() > 0 then
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
    renderRightColLoader()
    view = event.getData()
    mapComponents(view)
    renderLogo()
    renderNav([])
    setFocus(m.back_button)
end sub