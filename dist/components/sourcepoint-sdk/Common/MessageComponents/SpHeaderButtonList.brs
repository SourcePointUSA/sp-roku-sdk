sub init()
    m.top.observeField("focusedChild", "setFocus")
    m.top.observeField("sectionSettings", "renderSectionHeader")
    m.top.observeField("sectionSettingsRight", "renderSectionHeaderRight")
    m.top.observeField("sectionDescSettings", "renderSectionDesc")
    m.headerTitleLabel = m.top.findNode("header-title")
    m.headerTitleLabelRight = m.top.findNode("header-title-right")
    m.headerDescriptionLabel = m.top.findNode("header-description")
    m.buttonList = m.top.findNode("button-list")
    m.buttonList.observeField("focusedSectionNode", "updateHeader")
end sub

sub renderSectionHeader()
    settings = {}
    settings.append(m.top.sectionSettings)
    settings.text = invalid
    m.headerTitleLabel.settings = settings
end sub

sub renderSectionHeaderRight()
    settings = {}
    settings.append(m.top.sectionSettingsRight)
    m.headerTitleLabelRight.settings = settings
    m.headerTitleLabelRight.translation = [
        m.top.width - m.headerTitleLabelRight.boundingRect().width,
        0
    ]
end sub

sub renderSectionDesc()
    settings = {}
    settings.append(m.top.sectionDescSettings)
    settings.text = invalid
    m.headerDescriptionLabel.settings = settings
    m.headerDescriptionLabel.textComponent.width = m.top.width
    m.headerDescriptionLabel.textComponent.wrap = true
end sub

sub setFocus(event as object)
    focusedChild = event.getData()
    if focusedChild <> invalid and focusedChild.isSameNode(m.top) then
        m.buttonList.setFocus(true)
    end if
end sub

sub updateHeader(event as object)
    headerContentNode = event.getData()
    if headerContentNode <> invalid then
        m.headerTitleLabel.text = headerContentNode.title
        if headerContentNode.description <> invalid and headerContentNode.description <> "" then
            m.headerDescriptionLabel.text = headerContentNode.description
        end if
    end if
end sub