'import "pkg:/source/sourcepoint-sdk/Helpers.bs"

sub init()
    m.navViewMap = {
        "button_nav_back": "HomeView"
    }
    m.top.observeField("view", "renderView")
end sub

sub renderView(event as object)
    view = event.getData()
    mapComponents(view)
    renderLogo()
    renderNav([])
    if m.components.privacy_policy_body <> invalid then
        description = createObject("roSGNode", "SpNativeText")
        description.componentName = "ScrollableText"
        description.settings = m.components.privacy_policy_body.settings
        description.textComponent.width = m.colRightWidth
        description.textComponent.height = scalePixelDimension(530)
        m.colRight.appendChild(description)
        setFocus(description.textComponent)
        m.rightColFocus = description.textComponent
    end if
end sub