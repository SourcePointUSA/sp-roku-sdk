'import "pkg:/source/sourcepoint-sdk/Helpers.bs"

sub init()
    m.top.itemSpacings = [
        scalePixelDimension(10)
    ]
    m.top.observeField("buttonComponents", "render")
    m.buttonNodes = []
end sub

sub render(event as object)
    buttons = event.getData()
    maxWidth = 0
    if buttons = invalid or buttons.count() = 0 then
        return
    end if
    i = 0
    focusIndex = invalid
    buttonComponents = []
    for each button in buttons
        buttonComponent = createObject("roSGNode", m.top.buttonComponentName)
        buttonComponents.push(buttonComponent)
        buttonComponent.settings = button.settings
        buttonComponent.id = button.id
        m.top.appendChild(buttonComponent)
        m.buttonNodes.push(buttonComponent)
        if buttonComponent.boundingRect().width > maxWidth then
            maxWidth = buttonComponent.boundingRect().width
        end if
        if button.settings <> invalid and button.settings.startFocus = true then
            m.top.setFocus(true)
            focusIndex = i
        end if
        i = i + 1
    end for
    ' adjust button background widths
    for each button in m.buttonNodes
        button.width = maxWidth
    end for
    ' make all buttons the same width
    m.top.minWidth = maxWidth
    ' This is kind of a hack, we need to set button focuses to false
    ' and then set m.top.focusButton or we will have two focused for some reason...
    for each bc in buttonComponents
        bc.setFocus(false)
    end for
    if focusIndex <> invalid then
        m.top.focusButton = focusIndex
    end if
end sub