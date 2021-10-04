sub init()
    m.top.observeField("view", "renderView")
    m.top.observeField("privacyManagerViewData", "renderRightCol")
end sub

sub clearCategoryDesc(event as object)
    focusedChild = event.getData()
    if focusedChild = invalid then
        updateCategoryDesc(invalid)
    end if
end sub

function getCategory(id) as object
    if id <> invalid and m.top.privacyManagerViewData <> invalid and m.top.privacyManagerViewData.categories <> invalid then
        return m.top.privacyManagerViewData.categories[id]
    end if
    return invalid
end function

sub observeCategoryList(event as object)
    index = event.getData()
    if m.categoryList <> invalid and m.categoryList.content <> invalid then
        item = m.categoryList.content.getChild(event.getData())
        category = getCategory(item.id)
        if category <> invalid then
            changeView("CategoryDetailsView", category)
        end if
    end if
end sub

sub observeCategoryListFocus(event as object)
    if m.categoryList <> invalid then
        updateCategoryDesc(m.categoryList.focusedContentNode)
    end if
end sub

sub updateCategoryDesc(listItem as object)
    text = ""
    if listItem <> invalid then
        category = getCategory(listItem.id)
        if category <> invalid then
            text = category.description
        end if
    end if
    m.categoryDescription.text = text
end sub

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
    if m.components.text_categories_header <> invalid then
        categoriesHeader = createObject("roSGNode", "SpNativeText")
        categoriesHeader.settings = m.components.text_categories_header.settings
        m.colRight.appendChild(categoriesHeader)
    end if
    if m.components.text_purposes_definition <> invalid then
        purposesDefinition = createObject("roSGNode", "SpNativeText")
        purposesDefinition.settings = m.components.text_purposes_definition.settings
        m.colRight.appendChild(purposesDefinition)
    end if
    buttons = []
    if m.top.privacyManagerViewData <> invalid and m.top.privacyManagerViewData.categories <> invalid and m.components.button_category <> invalid then
        for each categoryId in m.top.privacyManagerViewData.categories
            buttonSettings = {
                ' on: m.top.privacyManagerViewData.categories[categoryId].enabled
                settings: {}
            }
            buttonSettings.settings.append(m.components.button_category.settings)
            buttonSettings.id = categoryId
            buttonSettings.settings.text = m.top.privacyManagerViewData.categories[categoryId].name
            buttons.push(buttonSettings)
        end for
    end if
    if m.categoryList = invalid and buttons.count() > 0 then
        m.categoryList = createObject("roSGNode", "SpButtonList")
        m.categoryList.id = "category_list"
        m.categoryList.width = m.colRightWidth
        m.colRight.appendChild(m.categoryList)
        m.rightColFocus = m.categoryList
        m.categoryList.observeField("itemSelected", "observeCategoryList")
        m.categoryList.observeField("itemFocused", "observeCategoryListFocus")
        m.categoryList.observeField("focusedChild", "clearCategoryDesc")
    end if
    if m.categoryList <> invalid then
        m.categoryList.buttonComponents = buttons
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
    renderCategoryDescription()
    renderNav([])
    setFocus(m.back_button)
end sub