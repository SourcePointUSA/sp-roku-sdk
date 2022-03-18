sub init()
    m.top.observeField("view", "renderView")
    m.top.observeField("privacyManagerViewData", "renderRightCol")
    m.vendorLists = {}
end sub

sub changeVendors(event as object)
    buttonSide = event.getData()
    if buttonSide = "left" then
        m.vendorLists["right"].visible = false
        m.vendorLists["left"].visible = true
        m.rightColFocus = m.vendorLists["left"]
    else
        m.vendorLists["left"].visible = false
        m.vendorLists["right"].visible = true
        m.rightColFocus = m.vendorLists["right"]
    end if
end sub

sub observeVendorList(event as object)
    showVendor(m.vendorList.focusedContentNode)
end sub

sub observeVendorListLi(event as object)
    showVendor(m.vendorListLi.focusedContentNode, true)
end sub

sub showVendor(item as object, isLi = false as boolean)
    if item <> invalid then
        data = (function(__bsCondition, item, m)
                if __bsCondition then
                    return m.top.privacyManagerViewData.legIntVendors[item.id]
                else
                    return m.top.privacyManagerViewData.vendors[item.id]
                end if
            end function)(isLi = true, item, m)
        data.isLi = isLi
        changeView("VendorDetailsView", data)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if key = "up" and m.nav <> invalid and m.nav.isInFocusChain() = true and m.vendorSlider <> invalid then
        ' ButtonGroup intercepts the press = true events if it moves focus
        ' if we get a press = true event on up that means we're trying to escape the ButtonGroup
        if press = true then
            m.vendorSlider.setFocus(true)
        end if
        return true
    else if key = "down" and m.vendorSlider <> invalid and m.vendorSlider.isInFocusChain() = true then
        m.nav.setFocus(true)
        return true
    else if key = "left" and m.vendorSlider <> invalid and m.vendorSlider.isInFocusChain() = true then
        if m.back_button <> invalid then
            m.back_button.setFocus(true)
            return true
        end if
    end if
    return _onKeyEvent(key, press)
end function

sub renderRightCol()
    if m.vendorListTarget = invalid then
        m.vendorListTarget = createObject("roSGNode", "Group")
        m.colRight.appendChild(m.vendorListTarget)
    end if
    if m.buttonTask = invalid then
        m.buttonTask = createObject("roSGNode", "VendorsButtonTaskGDPR")
        m.buttonTask.privacyManagerViewData = m.top.privacyManagerViewData
        m.buttonTask.buttonSettings = m.components.button_vendor.settings
        m.buttonTask.observeField("buttons", "renderButtonLists")
        m.buttonTask.observeField("error", "onError")
        m.buttonTask.control = "RUN"
    else
        renderButtonLists()
    end if
end sub

sub renderButtonLists()
    hideRightColLoader()
    buttons = m.buttonTask.buttons.buttons
    buttonsLi = m.buttonTask.buttons.buttonsLi
    if m.vendorList = invalid then
        m.vendorList = createObject("roSGNode", "SpButtonList")
        m.vendorList.id = "vendor_list"
        m.vendorList.width = m.colRightWidth
        m.vendorListTarget.appendChild(m.vendorList)
        m.rightColFocus = m.vendorList
        m.vendorLists["left"] = m.vendorList
        m.vendorList.observeField("itemSelected", "observeVendorList")
    end if
    m.vendorList.buttonComponents = buttons
    if buttonsLi <> invalid and buttonsLi.count() > 0 then
        if m.vendorListLi = invalid then
            m.vendorListLi = createObject("roSGNode", "SpButtonList")
            m.vendorListLi.id = "vendor_list_li"
            m.vendorListLi.width = m.colRightWidth
            m.vendorListLi.visible = false
            m.vendorListTarget.appendChild(m.vendorListLi)
            m.vendorLists["right"] = m.vendorListLi
            m.vendorListLi.observeField("itemSelected", "observeVendorListLi")
            renderSlider()
        end if
        m.vendorListLi.buttonComponents = buttonsLi
    end if
end sub

sub renderSlider()
    if m.vendorSlider = invalid and m.components.slider_vendors <> invalid then
        vendorSlider = createObject("roSGNode", "SpSlider")
        vendorSlider.id = "vendor_slider"
        vendorSlider.settings = m.components.slider_vendors.settings
        titleHolder = m.top.findNode("title-holder")
        titleHolder.appendChild(vendorSlider)
        m.vendorSlider = vendorSlider
        m.vendorSlider.observeField("buttonSelected", "changeVendors")
    end if
end sub

sub renderView(event as object)
    hasPmvData = getPrivacyManagerViewData(1)
    renderRightColLoader()
    view = event.getData()
    mapComponents(view)
    renderLogo()
    renderNav([
        "accept_all",
        "save_and_exit"
    ])
    setFocus(m.nav)
end sub