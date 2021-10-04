'import "pkg:/source/sourcepoint-sdk/Helpers.bs"

sub init()
    leftRightPadding = 180
    usableWidth = scalePixelDimension(1280 - leftRightPadding)
    m.colLeftWidth = usableWidth / 2
    m.colRightWidth = usableWidth / 2
    m.colLeft = m.top.findNode("col-left")
    m.colRight = m.top.findNode("col-right")
    m.screenTitle = m.top.findNode("screen-title")
    translationMap = {
        "col-left-width-holder": [
            0,
            0,
            m.colLeftWidth,
            0
        ],
        "col-right-width-holder": [
            0,
            0,
            m.colRightWidth,
            0
        ],
        "title-holder-width-holder": [
            0,
            0,
            usableWidth,
            0
        ]
        ' "title-holder": [usableWidth/2, 0],
        ' "screen-title": function(node, sWidth, sHeight) as Object
        '     return [1180/2, 0] 
        ' end function,
    }
    scalePixelDimensions(m.top, translationMap)
    m.componentIdMap = {
        "AcceptAllButton": "accept_all",
        "Body": "privacy_policy_body",
        "BackButton": "button_nav_back",
        "CategoriesDescriptionText": "text_category_description",
        "CategoriesSlider": "slider_categories",
        "CategoriesHeader": "text_categories_header",
        "CategoriesSubDescriptionText": "text_category_sub_description",
        "CategoryButton": "button_category",
        "CategoryButtons": "button_categories",
        "CategoryDescription": "text_category_description",
        "DoNotSellButton": "button_do_not_sell",
        "FeaturesHeader": "text_features_header",
        "FeaturesDefinition": "text_features_def",
        "Header": "text_header",
        "LogoImage": "image_logo",
        "OnButton": "button_on",
        "OffButton": "button_off",
        "NavCategoriesButton": "button_nav_categories",
        "NavCustomButton": "button_nav_custom",
        "NavPrivacyPolicyButton": "button_nav_privacy_policy",
        "NavVendorsButton": "button_nav_vendors",
        "PublisherDescription": "text_publisher_description",
        "PurposesDefinition": "text_purposes_definition",
        "PurposesHeader": "text_purposes_header",
        "PurposesDefinition": "text_purposes_def",
        "RejectAllButton": "reject_all",
        "SaveAndExitButton": "save_and_exit",
        "SaveButton": "save_and_exit",
        "SpecialPurposesHeader": "text_special_purposes_header",
        "SpecialPurposesDefinition": "text_special_purposes_def",
        "VendorButton": "button_vendor",
        "VendorsHeader": "text_vendor_header",
        "VendorLongButton": "button_vendor",
        "VendorsSlider": "slider_vendors"
    }
    m.components = {}
    m.currentlyFocusedChild = invalid
    ' m.navViewMap : maps nav button IDs to views they should link to
    ' m.componentIdMap : fills in m.components mapping JSON id to our IDs
    ' m.rightColFocus : what should focus in the right column when the right arrow is pressed
    m.top.translation = [
        scalePixelDimension(leftRightPadding / 2),
        50
    ]
    m.top.observeField("focusedChild", "trackFocusedChild")
end sub

sub changeView(viewName as string, viewData = invalid as object)
    spMessage = m.top.getParent()
    spMessage.changeViewDataExtra = viewData
    spMessage.changeView = viewName
end sub

function getPrivacyManagerViewData(messageCategoryId) as boolean
    m.privacyManagerViewTask = m.top.privacyManagerViewTask
    m.privacyManagerViewTask.messageCategory = messageCategoryId
    m.privacyManagerViewTask.propertyId = m.global.config.propertyId
    m.privacyManagerViewTask.control = "RUN"
    m.privacyManagerViewTask.observeField("state", "setPmvData")
    m.privacyManagerViewTask.observeField("data", "setPmvData")
    return bslib_ternary(m.top.privacyManagerViewTask.data = invalid, false, true)
end function

sub mapComponents(view as object)
    if view <> invalid then
        m.components.view = view
        for each component in view.children
            if m.componentIdMap[component.id] <> invalid then
                m.components[m.componentIdMap[component.id]] = component
            end if
        end for
    end if
end sub

sub observeBackButton()
    changeView("_go_back_")
end sub

sub observeNav(event as object)
    selectedButton = m.nav.getChild(event.getData())
    if selectedButton = invalid then
        return
    end if
    if m.navViewMap <> invalid and m.navViewMap[selectedButton.id] <> invalid then
        changeView(m.navViewMap[selectedButton.id])
    else if selectedButton.id = "button_nav_back" then
        changeView("_go_back_")
    else
        consentTask = createObject("roSGNode", "ConsentTask")
        consentTask.messageCategory = m.top.messageMetadata.categoryId
        if selectedButton.id = "accept_all" then
            consentTask.action = "accept"
        else if selectedButton.id = "reject_all" then
            consentTask.action = "reject"
        else if selectedButton.id = "save_and_exit" then
            if m.top.messageMetadata.categoryId = 2 then
                ' for ccpa look at do not sell
                ' we can remove this logic if we want to allow toggline of categories and vendors
                if m.top.userConsentNode.doNotSell = true then
                    consentTask.action = "reject"
                else
                    consentTask.action = "accept"
                end if
            else ' for gdpr get save and exit vars
                consentTask.action = "save_and_exit"
                consentTask.saveAndExitVariables = m.top.userConsentNode.callFunc("getSaveAndExitVariables")
            end if
        end if
        consentTask.control = "RUN"
        consentTask.observeField("userConsent", "setConsent")
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    return _onKeyEvent(key, press)
end function

function _onKeyEvent(key as string, press as boolean) as boolean
    newFocus = invalid
    if key = "left" and press = true then
        if m.nav = invalid or m.nav.isInFocusChain() = true then
            ' if we're focused on the nav go to the back button
            newFocus = m.back_button
        else ' else we're focused on the right col go to the nav
            newFocus = m.nav
        end if
    else if key = "right" and press = true then
        if m.back_button <> invalid and m.back_button.isInFocusChain() then
            ' if we're focused on the back button, go to nav
            newFocus = m.nav
        end if
        if newFocus = invalid then
            ' if the back button doesn't exist, we're focused on the nav - go to right col
            ' if the nav doesn't exist, go to right col
            newFocus = m.rightColFocus
        end if
    end if
    if newFocus <> invalid then
        newFocus.setFocus(true)
        m.previouslyFocusedChild = newFocus
        return true
    end if
    return false
end function

sub renderBackButton()
    if m.back_button = invalid and m.components.button_nav_back <> invalid then
        m.back_button = createObject("roSGNode", "SpNativeButton")
        m.back_button.settings = m.components.button_nav_back.settings
        m.back_button.id = "button_nav_back"
        m.back_button.observeField("buttonSelected", "observeBackButton")
        m.back_button.minWidth = 50
        m.top.appendChild(m.back_button)
    end if
end sub

sub renderHeader()
    if m.components.text_header <> invalid then
        m.screenTitle.settings = m.components.text_header.settings
    end if
end sub

sub renderLogo()
    renderHeader()
    if m.components.image_logo <> invalid then
        component = createObject("roSGNode", "Poster")
        component.id = "image_logo"
        component.loadDisplayMode = "limitSize"
        component.loadHeight = 540
        if m.components.image_logo.settings.style.width <> invalid and m.components.image_logo.settings.style.width.value then
            component.loadWidth = m.components.image_logo.settings.style.width.value
        else
            component.loadWidth = 200
        end if
        component.loadingBitmapUri = "pkg:/images/sourcepoint-sdk/busyspinner_hd.png"
        component.uri = m.components.image_logo.settings.src
        m.colLeft.appendChild(component)
    end if
end sub

sub renderNav(buttonIds)
    renderBackButton()
    if buttonIds.count() > 0 then
        buttons = []
        for each buttonId in buttonIds
            if m.components[buttonId] <> invalid then
                button = m.components[buttonId]
                button.id = buttonId
                buttons.push(button)
            end if
        end for
        if buttons.count() > 0 then
            buttonGroup = createObject("roSGNode", "SpButtonGroup")
            buttonGroup.buttonComponents = buttons
            m.colLeft.appendChild(buttonGroup)
            m.nav = buttonGroup
            m.nav.observeField("buttonSelected", "observeNav")
            m.previouslyFocusedChild = m.nav
        else
            m.previouslyFocusedChild = m.back_button
        end if
    else
        m.previouslyFocusedChild = m.back_button
    end if
end sub

sub renderRightColLoader()
    if m.loader = invalid then
        m.loader = createObject("roSGNode", "BusySpinner")
        m.loader.poster.uri = "pkg:/images/sourcepoint-sdk/busyspinner_hd.png"
        m.loader.translation = [
            scalePixelDimension(960 - 64),
            scalePixelDimension(360 - 64)
        ]
        m.loader.inheritParentTransform = false
        m.top.appendChild(m.loader)
    end if
    m.loader.control = "start"
    m.loader.visible = true
end sub

sub hideRightColLoader()
    if m.loader <> invalid then
        m.loader.control = "stop"
        m.loader.visible = false
    end if
end sub

' Sets focus if none has been set yet
' allows startFocus to be respected
sub setFocus(node as object)
    if m.currentlyFocusedChild = invalid then
        if node <> invalid then
            node.setFocus(true)
        end if
    end if
end sub

sub setPmvData(event = invalid as object)
    if event = invalid or m.privacyManagerViewTask.state = "stop" then
        m.top.privacyManagerViewData = m.privacyManagerViewTask.data
    end if
end sub

sub setConsent(event as object)
    spMessage = m.top.getParent()
    spMessage.userConsent = event.getData()
    spMessage.done = true
    ' TODO add any errors?
end sub

' Enables us to refocus the correct element when we move between existing screens
sub trackFocusedChild(event as object)
    focusedChild = event.getData()
    ' Focus previously focused element if this view was just focused
    if focusedChild <> invalid and m.previouslyFocusedChild <> invalid then
        if m.top.hasFocus() = true then
            m.previouslyFocusedChild.setFocus(true)
        end if
    end if
    ' Track currently focused element
    if focusedChild <> invalid and m.top.hasFocus() = false then
        m.currentlyFocusedChild = focusedChild
    end if
end sub