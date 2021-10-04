'import "pkg:/source/sourcepoint-sdk/Helpers.bs"

sub init()
    m.top.focusable = true
    m.top.observeField("focusedChild", "setFocus")
    m.top.observeField("settings", "render")
    m.background = m.top.findNode("slider-background")
    m.buttonGroup = m.top.findNode("button-group")
    m.top.buttonLeft = m.top.findNode("button-left")
    m.top.buttonRight = m.top.findNode("button-right")
    m.top.buttonSelected = "left"
    m.padding = scalePixelDimension(20)
    m.buttonGroup.translation = [
        m.padding / 2,
        m.padding / 2
    ]
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if key = "right" then
        m.top.buttonSelected = "right"
        m.top.buttonRight.setFocus(true)
        return true
    else if key = "left" then
        m.top.buttonSelected = "left"
        m.top.buttonLeft.setFocus(true)
        return true
    else if key = "OK" then
        return true
    end if
    return false
end function

sub setFocus(event as object)
    focusedChild = event.getData()
    if focusedChild = invalid then
        if m.top.buttonSelected = "left" then
            m.top.buttonLeft.showFocusFootprint = true
        else
            m.top.buttonRight.showFocusFootprint = true
        end if
    else if m.top.isSameNode(focusedChild) then
        m.top.buttonLeft.showFocusFootprint = false
        m.top.buttonRight.showFocusFootprint = false
        if m.top.buttonSelected = "left" then
            m.top.buttonLeft.setFocus(true)
        else
            m.top.buttonRight.setFocus(true)
        end if
    end if
end sub

sub render(event as object)
    settings = event.getData()
    ' normalize settings for buttons
    focusFootprintColor = invalid
    if settings <> invalid and settings.style <> invalid then
        if settings.style.activeBackgroundColor <> invalid then
            settings.style.onFocusBackgroundColor = settings.style.activeBackgroundColor
            focusFootprintColor = settings.style.activeBackgroundColor
        end if
        if settings.style.font <> invalid then
            settings.style.onUnfocusTextColor = settings.style.font.color
        end if
        if settings.style.activeFont <> invalid then
            settings.style.onFocusTextColor = settings.style.activeFont.color
        end if
    end if
    m.top.buttonLeft.settings = settings
    m.top.buttonRight.settings = settings
    ' set focus footprint colour to what it should be
    if focusFootprintColor <> invalid then
        m.top.buttonLeft.focusFootprintColor = colorConvert(focusFootprintColor)
        m.top.buttonRight.focusFootprintColor = colorConvert(focusFootprintColor)
    end if
    ' set correct default
    if m.top.buttonSelected = "left" then
        m.top.buttonLeft.showFocusFootprint = true
        m.top.buttonRight.showFocusFootprint = false
    else
        m.top.buttonLeft.showFocusFootprint = false
        m.top.buttonRight.showFocusFootprint = true
    end if
    if settings <> invalid then
        ' set button text
        if settings.leftText <> invalid then
            m.top.buttonLeft.text = settings.leftText
        end if
        if settings.rightText <> invalid then
            m.top.buttonRight.text = settings.rightText
        end if
        if settings.backgroundColor <> invalid then
            m.background.blendColor = colorConvert(settings.backgroundColor)
        end if
    end if
    boundingRect = m.top.boundingRect()
    m.background.width = boundingRect.width + m.padding - m.buttonGroup.itemSpacings[0]
    m.background.height = boundingRect.height + m.padding - m.buttonGroup.itemSpacings[0]
end sub