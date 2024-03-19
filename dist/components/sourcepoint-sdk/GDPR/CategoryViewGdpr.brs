sub init()
    m.top.observeField("view", "renderView")
    m.top.observeField("viewDataExtra", "renderRightCol")
    m.navButtons = [
        "button_on",
        "button_off"
    ]
    m.descriptionScrollPoster = invalid
end sub

sub observeNav(event as object)
    selectedButton = m.nav.getChild(event.getData())
    categoryActionMap = {
        "categories": {
            accept: "acceptCategory",
            reject: "rejectCategory"
        },
        "legInt": {
            accept: "acceptLiCategory",
            reject: "rejectLiCategory"
        },
        "specialFeatures": {
            accept: "acceptSpecialFeature",
            reject: "rejectSpecialFeature"
        }
    }
    categoryType = m.categoryData.categoryType
    if selectedButton.id = "button_on" then
        m.top.userConsentNode[categoryActionMap[categoryType]["accept"]] = m.categoryData._id
    else if selectedButton.id = "button_off" then
        m.top.userConsentNode[categoryActionMap[categoryType]["reject"]] = m.categoryData._id
    end if
    changeView("_go_back_")
end sub

sub renderRightCol(event as object)
    m.categoryData = event.getData()
    ' no buttons if it's not toggleable
    if m.categoryData.disclosureOnly = true or (m.categoryData.categoryType <> "categories" and m.categoryData.categoryType <> "legInt" and m.categoryData.categoryType <> "specialFeatures") then
        renderNav([])
    else
        renderNav(m.navButtons)
        enabled = m.categoryData.enabled
        for i = 0 to m.navButtons.count() step 1
            if (enabled = true and m.navButtons[i] = "button_on") or (enabled = false and m.navButtons[i] = "button_off") then
                m.nav.focusButton = i
                exit for
            end if
        end for
    end if
    setFocus(m.nav)
    m.screenTitle.text = m.categoryData.name
    if m.categoryData.description <> invalid then
        description = createObject("roSGNode", "SpNativeText")
        description.id = "category_description"
        description.componentName = "ScrollableText"
        settings = {}
        if m.components.text_category_description <> invalid then
            settings.append(m.components.text_category_description.settings)
        end if
        settings.text = m.categoryData.description
        description.settings = settings
        description.textComponent.height = 250
        description.textComponent.width = m.colRightWidth
        m.colRight.appendChild(description)
        ' find a scrollbar poster so we can determine if the element scrolls
        scrollTextChildren = description.textComponent.getChildren(- 1, 0)
        for each c in scrollTextChildren
            if c.subType() = "Poster" then
                m.descriptionScrollPoster = c
                exit for
            end if
        end for
        m.description = description.textComponent
    end if
    ' figure out which type of vendor this is
    if m.categoryData.categoryType = "categories" then
        vendors = m.categoryData.requiringConsentVendors
    else if m.categoryData.categoryType = "legInt" then
        vendors = m.categoryData.legIntVendors
    else
        if m.categoryData.disclosureOnly = true then
            vendors = m.categoryData.disclosureOnlyVendors
        else if m.categoryData.vendors <> invalid then
            vendors = m.categoryData.vendors
        else
            vendors = []
        end if
    end if
    ' render vendor header with count
    if m.components.text_vendor_header <> invalid then
        vendorsHeader = createObject("roSGNode", "SpNativeText")
        settings = {}
        settings.append(m.components.text_vendor_header.settings)
        settings.text = settings.text + " (" + vendors.count().toStr() + ")"
        vendorsHeader.settings = settings
        m.colRight.appendChild(vendorsHeader)
    end if
    ' render vendors
    buttons = []
    for each vendor in vendors
        buttonSettings = {
            carat: "",
            settings: {}
        }
        if m.components.button_vendor <> invalid then
            buttonSettings.settings.append(m.components.button_vendor.settings)
        end if
        buttonSettings.id = vendor._id
        buttonSettings.settings.text = vendor.name
        buttons.push(buttonSettings)
    end for
    if buttons.count() > 0 then
        m.vendorList = createObject("roSGNode", "SpButtonList")
        m.vendorList.id = "vendor_list"
        m.vendorList.width = m.colRightWidth
        m.vendorList.buttonComponents = buttons
        m.colRight.appendChild(m.vendorList)
    end if
end sub

sub renderView(event as object)
    view = event.getData()
    mapComponents(view)
    renderLogo()
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if key = "left" and press = true and m.nav <> invalid and m.nav.isInFocusChain() = false then
        if m.back_button = invalid or m.back_button.isInFocusChain() = false then
            ' if we're focused on the back button leave it there
            m.nav.setFocus(true)
            m.previouslyFocusedChild = m.nav
        end if
        return true
    else if key = "right" and press = true and (m.nav = invalid or m.nav.isInFocusChain() = true) then
        ' for the right key, we first see if the category text is overflowing
        ' if it is we go there,
        ' if not we will go to the vendor list
        if m.descriptionScrollPoster <> invalid and m.descriptionScrollPoster.visible = true then
            m.description.setFocus(true)
            m.previouslyFocusedChild = m.description
            return true
        else if m.vendorList <> invalid then
            m.vendorList.setFocus(true)
            m.previouslyFocusedChild = m.vendorList
            return true
        end if
    else if key = "down" and press = true and m.description.hasFocus() = true and m.vendorList <> invalid then
        ' for the down key, if we're in the category description we know we want to go to the partner list
        m.vendorList.setFocus(true)
        m.previouslyFocusedChild = m.vendorList
        return false
    end if
    return _onKeyEvent(key, press)
end function