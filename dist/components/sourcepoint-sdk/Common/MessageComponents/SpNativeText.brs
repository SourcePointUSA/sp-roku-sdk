'import "pkg:/source/sourcepoint-sdk/Helpers.bs"

sub init()
    m.top.observeField("settings", "render")
    m.top.observeField("text", "renderText")
    m.top.observeField("focusedChild", "maybeSetFocus")
    m.textColor = "0x000000FF"
end sub

sub render(event as object)
    componentName = m.top.componentName
    settings = event.getData()
    if m.top.textComponent = invalid then
        textComponent = createObject("roSGNode", componentName)
        m.top.textComponent = textComponent
    else
        textComponent = m.top.textComponent
    end if
    if settings.text <> invalid then
        m.top.text = stripHtmlTags(settings.text)
    end if
    if settings.style <> invalid and settings.style.font <> invalid then
        if settings.style.font.color <> invalid then
            m.textColor = colorConvert(settings.style.font.color)
        end if
        if componentName = "Label" or componentName = "ScrollingLabel" or componentName = "ScrollableText" then
            font = createFont(settings.style.font)
            textComponent.font = font
        else if componentName = "SimpleLabel" then
            if settings.style.font.fontWeight <> invalid and settings.style.font.fontWeight = "700" then
                textComponent.fontUri = "font:BoldSystemFontFile"
            else
                textComponent.fontUri = "font:SystemFontFile"
            end if
            fontSize = 14
            if settings.style.font.fontSize <> invalid then
                fontSize = settings.style.font.fontSize
            end if
            textComponent.fontSize = scalePixelDimension(fontSize)
        end if
    end if
    textComponent.color = m.textColor
    m.top.appendChild(textComponent)
end sub

sub renderText(event as object)
    if m.top.textComponent = invalid then
        return
    end if
    text = event.getData()
    if text <> invalid then
        m.top.textComponent.text = stripHtmlTags(text)
    else
        m.top.textComponent.text = ""
    end if
end sub

sub maybeSetFocus()
    if m.top.componentName = "ScrollableText" and m.top.hasFocus() then
        m.top.textComponent.setFocus(true)
    end if
end sub