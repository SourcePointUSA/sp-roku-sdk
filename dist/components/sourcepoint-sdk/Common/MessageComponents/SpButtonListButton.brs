'import "pkg:/source/sourcepoint-sdk/Helpers.bs"

sub init()
    m.top.observeField("itemContent", "render")
    m.buttonPadding = scalePixelDimension(24)
    m.buttonTextSpacing = scalePixelDimension(15)
    m.button_background = m.top.findNode("button_background")
    m.button_label = m.top.findNode("button_label")
    m.button_label.translation = [
        m.buttonPadding,
        0
    ]
    m.rendered = false
    ' defaults
    m.textColor = "0x000000FF"
    m.focusedTextColor = "0x000000FF"
    m.unFocusBackgroundColor = "0xFFFFFFFF"
end sub

sub render(event as object)
    content = event.getData()
    settings = content.settings
    if m.rendered = true then
        renderUpdate(content)
        return
    else
        m.rendered = true
    end if
    if settings <> invalid and settings.style <> invalid then
        if settings.style.onUnfocusTextColor <> invalid then
            m.textColor = colorConvert(settings.style.onUnfocusTextColor)
        end if
        if settings.style.onFocusTextColor <> invalid then
            m.focusedTextColor = colorConvert(settings.style.onFocusTextColor)
        end if
        if settings.style.onUnfocusBackgroundColor <> invalid then
            m.unFocusBackgroundColor = colorConvert(settings.style.onUnfocusBackgroundColor)
        end if
    end if
    m.top.id = content.id
    ' set this before continuing, other labels will pull font settings from here
    m.button_label.settings = settings
    addBackground(content)
    if content.carat <> "" and m.caratNode = invalid then
        addCarat(content)
    end if
    if m.onOffNode = invalid and (content.on = true or content.off = true) and settings.onText <> invalid and settings.offText <> invalid then
        addOnOff(content, settings)
    end if
    if settings.customText <> invalid and content.showCustom = true then
        addCustomText(content, settings)
    end if
    m.button_label.textComponent.vertAlign = "center"
    m.button_label.textComponent.height = content.height
    m.button_label.textComponent.width = content.width * .6
    content.focused = false
    renderUpdate(content)
end sub

sub renderUpdate(content as object)
    focused = content.focused
    if focused = true then
        textColor = m.focusedTextColor
    else
        textColor = m.textColor
    end if
    m.button_label.textComponent.color = textColor
    if m.caratNode <> invalid then
        m.caratNode.color = textColor
    end if
    if m.customText <> invalid then
        m.customText.color = textColor
    end if
    if focused = true then
        m.background.visible = false
    else
        m.background.visible = true
    end if
    if m.onOffNode <> invalid then
        if content.on = true then
            m.onOffNode.text = content.settings.onText
        else if content.off = true then
            m.onOffNode.text = content.settings.offText
        endif
    end if
end sub

sub addCarat(content as object)
    m.caratNode = createObject("roSGNode", "SimpleLabel")
    m.caratNode.fontUri = "font:SystemFontFile"
    if m.button_label.textComponent <> invalid and m.button_label.textComponent.font <> invalid then
        m.caratNode.fontSize = m.button_label.textComponent.font.size
    end if
    m.caratNode.text = content.carat
    m.caratNode.horizOrigin = "right"
    m.caratNode.vertOrigin = "center"
    m.caratNode.translation = [
        content.width - m.buttonPadding,
        content.height / 2
    ]
    m.top.appendChild(m.caratNode)
end sub

sub addBackground(content as object)
    m.background = createObject("roSGNode", "Poster")
    m.background.height = content.height
    m.background.width = content.width
    m.background.uri = "pkg:/images/sourcepoint-sdk/unfocus_button_sq.9.png"
    m.background.blendColor = m.unFocusBackgroundColor
    m.background.visible = false
    m.top.insertChild(m.background, 0)
end sub

sub addCustomText(content as object, settings as object)
    m.customText = createObject("roSGNode", "SimpleLabel")
    m.customText.text = settings.customText
    m.customText.fontUri = "font:SystemFontFile"
    if m.button_label.textComponent <> invalid and m.button_label.textComponent.font <> invalid then
        m.customText.fontSize = m.button_label.textComponent.font.size
    end if
    rightOffset = 0
    if m.onOffNode <> invalid then
        rightOffset = m.onOffNode.boundingRect().x - m.buttonTextSpacing
    end if
    m.customText.horizOrigin = "right"
    m.customText.vertOrigin = "center"
    m.customText.translation = [
        rightOffset,
        content.height / 2
    ]
    m.top.appendChild(m.customText)
end sub

sub addOnOff(content as object, settings as object)
    m.onOffNode = createObject("roSGNode", "SpNativeText")
    m.onOffNode.id = "on_off_toggle"
    m.onOffNode.componentName = "SimpleLabel"
    settings = {
        style: {}
    }
    settings.append(m.button_label.settings)
    settings.style.font = settings.style.onOffFont
    m.onOffNode.settings = settings
    if content.on = true then
        m.onOffNode.text = settings.onText
    else if content.off = true then
        m.onOffNode.text = settings.offText
    endif
    rightOffset = content.width - m.buttonPadding
    if m.caratNode <> invalid then
        rightOffset = m.caratNode.boundingRect().x - m.buttonTextSpacing
    end if
    m.onOffNode.textComponent.horizOrigin = "right"
    m.onOffNode.textComponent.vertOrigin = "center"
    m.onOffNode.textComponent.translation = [
        rightOffset,
        content.height / 2
    ]
    m.top.appendChild(m.onOffNode)
end sub