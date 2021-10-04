sub init()
    m.top.observeField("viewDataExtra", "renderView")
    m.navButtons = [
        "button_on",
        "button_off"
    ]
end sub

sub observeNav(event as object)
    selectedButton = m.nav.getChild(event.getData())
    if selectedButton <> invalid then
        if selectedButton.id = "button_on" then
            m.top.userConsentNode.acceptVendor = m.vendorData.vendorId
        else if selectedButton.id = "button_off" then
            m.top.userConsentNode.rejectVendor = m.vendorData.vendorId
        end if
    end if
    changeView("_go_back_")
end sub

sub renderPrivacyPolicyUrl()
    if m.vendorData.policyUrl = invalid then
        return
    end if
    screenTitle = m.screenTitle
    textColor = "0x000000FF"
    if screenTitle <> invalid then
        textColor = screenTitle.textComponent.color
    end if
    ppHeader = createObject("roSGNode", "SimpleLabel")
    ppHeader.text = "Privacy Policy Url:"
    ppHeader.color = textColor
    ppUrl = createObject("roSGNode", "Label")
    ppUrl.id = "privacy_policy_url"
    ppUrl.text = m.vendorData.policyUrl
    ppUrl.wrap = true
    ppUrl.color = textColor
    ppUrl.width = m.colLeftWidth * .8
    m.colLeft.appendChild(ppHeader)
    m.colLeft.appendChild(ppUrl)
end sub

sub renderRightCol()
    m.screenTitle.text = m.vendorData.name
    for i = 0 to m.navButtons.count() step 1
        if (m.vendorData.enabled = true and m.navButtons[i] = "button_on") or (m.vendorData.enabled = false and m.navButtons[i] = "button_off") then
            m.nav.focusButton = i
            exit for
        end if
    end for
    setFocus(m.nav)
    categories = []
    if m.vendorData.isLi = true then
        categories = m.vendorData.legIntCategories
    else
        categories = m.vendorData.consentCategories
    end if
    if categories <> invalid and categories.count() > 0 then
        m.categoryList = createObject("roSGNode", "SpButtonList")
        m.categoryList.id = "category_list"
        m.categoryList.width = m.colRightWidth
        buttons = []
        for each purpose in categories
            if purpose <> invalid then
                buttonSettings = {
                    carat: "",
                    settings: {}
                }
                if m.components.button_vendor <> invalid then
                    buttonSettings.settings.append(m.components.button_vendor.settings)
                end if
                buttonSettings.settings.text = purpose.name
                buttons.push(buttonSettings)
            end if
        end for
        m.categoryList.buttonComponents = buttons
        if buttons.count() > 0 then
            m.colRight.appendChild(m.categoryList)
            m.rightColFocus = m.categoryList
        end if
    end if
end sub

sub renderView(event as object)
    m.vendorData = event.getData()
    if m.vendorData.disclosureOnly = true then
        m.navButtons = []
    end if
    view = m.top.view
    mapComponents(view)
    renderHeader()
    renderPrivacyPolicyUrl()
    renderNav(m.navButtons)
    renderRightCol()
end sub