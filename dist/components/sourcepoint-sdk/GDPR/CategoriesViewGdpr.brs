sub init()
    m.top.observeField("view", "renderView")
    m.top.observeField("privacyManagerViewData", "renderRightCol")
    m.categoryLists = {}
end sub

sub changeCategories(event as object)
    buttonSide = event.getData()
    if buttonSide = "left" then
        m.categoryLists["right"].visible = false
        m.categoryLists["left"].visible = true
        m.rightColFocus = m.categoryLists["left"]
    else
        m.categoryLists["left"].visible = false
        m.categoryLists["right"].visible = true
        m.rightColFocus = m.categoryLists["right"]
    end if
end sub

sub clearCategoryDesc(event as object)
    focusedChild = event.getData()
    if focusedChild = invalid then
        updateCategoryDesc(invalid)
    end if
end sub

sub observeCategoryList(event as object)
    showCategory(m.categoryList.focusedContentNode)
end sub

sub observeCategoryListFocus(event as object)
    updateCategoryDesc(m.categoryList.focusedContentNode)
end sub

sub observeCategoryListLi(event as object)
    showCategory(m.categoryListLi.focusedContentNode)
end sub

sub observeCategoryListLiFocus(event as object)
    updateCategoryDesc(m.categoryListLi.focusedContentNode)
end sub

sub updateCategoryDesc(listItem as object)
    if listItem = invalid then
        text = ""
    else
        cType = "categories"
        if listItem.categoryType <> invalid then
            ' legInt categories are pulled from same "categories" list
            cType = (function(__bsCondition, listItem)
                    if __bsCondition then
                        return "categories"
                    else
                        return listItem.categoryType
                    end if
                end function)(listItem.categoryType = "legInt", listItem)
        end if
        if m.top.privacyManagerViewData[cType] <> invalid and m.top.privacyManagerViewData[cType][listItem.id] <> invalid then
            text = m.top.privacyManagerViewData[cType][listItem.id].friendlyDescription
        end if
    end if
    m.categoryDescription.text = text
end sub

sub showCategory(listItem as object)
    cType = "categories"
    viewData = {}
    if listItem.categoryType <> invalid then
        viewData["categoryType"] = listItem.categoryType
        ' legInt categories are pulled from same "categories" list
        cType = (function(__bsCondition, listItem)
                if __bsCondition then
                    return "categories"
                else
                    return listItem.categoryType
                end if
            end function)(listItem.categoryType = "legInt", listItem)
    end if
    viewData.append(m.top.privacyManagerViewData[cType][listItem.id])
    changeView("CategoryDetailsView", viewData)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if key = "up" and m.nav <> invalid and m.nav.isInFocusChain() = true and m.categorySlider <> invalid then
        ' ButtonGroup intercepts the press = true events if it moves focus
        ' if we get a press = true event on up that means we're trying to escape the ButtonGroup
        if press = true then
            m.categorySlider.setFocus(true)
        end if
        return true
    else if key = "down" and m.categorySlider <> invalid and m.categorySlider.isInFocusChain() = true then
        m.nav.setFocus(true)
        return true
    end if
    return _onKeyEvent(key, press)
end function

sub renderCategoryDescription()
    if m.categoryDescription = invalid and m.components.text_category_description <> invalid then
        m.categoryDescription = createObject("roSGNode", "SpNativeText")
        m.categoryDescription.settings = m.components.text_category_description.settings
        m.categoryDescription.textComponent.horizAlign = "center"
        m.categoryDescription.textComponent.wrap = true
        m.categoryDescription.textComponent.width = m.colLeftWidth * .8
        m.categoryDescription.textComponent.maxLines = 3
        m.colLeft.appendChild(m.categoryDescription)
    end if
end sub

sub renderRightCol()
    hideRightColLoader()
    categoryTypes = {
        "categories": {
            headerComponent: m.components.text_purposes_header,
            defComponent: m.components.text_purposes_def
        },
        "specialPurposes": {
            headerComponent: m.components.text_special_purposes_header,
            defComponent: m.components.text_special_purposes_def
        },
        "specialFeatures": {
            headerComponent: m.components.text_features_header,
            defComponent: m.components.text_features_def
        }
    }
    buttonCategorySettings = {}
    if m.components.button_category <> invalid and m.components.button_category.settings <> invalid then
        buttonCategorySettings.append(m.components.button_category.settings)
    end if
    buttonsLi = []
    if m.top.privacyManagerViewData.legIntCategories <> invalid then
        for each id in m.top.privacyManagerViewData.legIntCategories
            buttonSettings = {
                categoryType: "legInt",
                on: m.top.privacyManagerViewData.legIntCategories[id].enabled,
                settings: {},
                showCustom: m.top.privacyManagerViewData.legIntCategories[id].type = "CUSTOM"
            }
            buttonSettings.settings.append(buttonCategorySettings)
            buttonSettings.id = id
            buttonSettings.settings.text = m.top.privacyManagerViewData.legIntCategories[id].name
            buttonsLi.push(buttonSettings)
        end for
    end if
    categoryTypeOrder = [
        "categories",
        "specialPurposes",
        "specialFeatures"
    ]
    sections = []
    for each cType in categoryTypeOrder
        buttons = []
        if m.top.privacyManagerViewData[cType] <> invalid then
            for each id in m.top.privacyManagerViewData[cType]
                listItem = m.top.privacyManagerViewData[cType][id]
                if (listItem.vendors <> invalid and listItem.vendors.count() > 0) or (listItem.requiringConsentVendors <> invalid and listItem.requiringConsentVendors.count() > 0) then
                    buttonSettings = {
                        categoryType: cType,
                        on: m.top.privacyManagerViewData[cType][id].enabled,
                        settings: {},
                        showCustom: m.top.privacyManagerViewData[cType][id].type = "CUSTOM"
                    }
                    buttonSettings.settings.append(buttonCategorySettings)
                    buttonSettings.id = id
                    buttonSettings.settings.text = m.top.privacyManagerViewData[cType][id].name
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
                section.settings = categoryTypes[cType].defComponent.settings
            end if
            sections.push(section)
        end if
    end for
    m.categoryListTarget = createObject("roSGNode", "Group")
    m.colRight.appendChild(m.categoryListTarget)
    ' Create category list
    if sections.count() > 0 then
        if m.categoryList = invalid then
            m.categoryList = createObject("roSGNode", "SpHeaderButtonList")
            m.categoryList.id = "category_list"
            m.categoryList.width = m.colRightWidth
            m.categoryListTarget.appendChild(m.categoryList)
            m.rightColFocus = m.categoryList
            m.categoryList.observeField("itemSelected", "observeCategoryList")
            m.categoryList.observeField("itemFocused", "observeCategoryListFocus")
            m.categoryList.observeField("focusedChild", "clearCategoryDesc")
            m.categoryList.sectionSettings = sections[0].settings
            m.categoryList.sectionDescSettings = sections[0].settingsDesc
            m.categoryLists["left"] = m.categoryList
        end if
        m.categoryList.buttonComponents = sections
    end if
    ' Create LI category list if needed
    ' TODO what if there are only LI categories
    if buttonsLi.count() > 0 then
        if m.categoryListLi = invalid then
            m.categoryListLi = createObject("roSGNode", "SpHeaderButtonList")
            m.categoryListLi.id = "category_list_li"
            m.categoryListLi.width = m.colRightWidth
            m.categoryListLi.visible = false
            m.categoryListTarget.appendChild(m.categoryListLi)
            m.categoryListLi.observeField("itemSelected", "observeCategoryListLi")
            m.categoryListLi.observeField("itemFocused", "observeCategoryListLiFocus")
            m.categoryListLi.observeField("focusedChild", "clearCategoryDesc")
            m.categoryLists["right"] = m.categoryListLi
            renderSlider()
        end if
        m.categoryListLi.buttonComponents = buttonsLi
    end if
end sub

sub renderSlider()
    if m.categorySlider = invalid then
        categorySlider = createObject("roSGNode", "SpSlider")
        categorySlider.id = "category_slider"
        if m.components.slider_categories <> invalid then
            categorySlider.settings = m.components.slider_categories.settings
        end if
        titleHolder = m.top.findNode("title-holder")
        titleHolder.appendChild(categorySlider)
        m.categorySlider = categorySlider
        m.categorySlider.observeField("buttonSelected", "changeCategories")
    end if
end sub

sub renderView(event as object)
    hasPmvData = getPrivacyManagerViewData(1)
    if hasPmvData = false then
        renderRightColLoader()
    end if
    view = event.getData()
    mapComponents(view)
    renderLogo()
    renderCategoryDescription()
    renderNav([
        "accept_all",
        "save_and_exit"
    ])
    setFocus(m.nav)
end sub