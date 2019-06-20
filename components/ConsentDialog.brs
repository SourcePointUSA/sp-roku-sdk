function setUpDialogVars()
  m.readLogicTask = createObject("roSGNode","LogicGetter")
  m.readLogicTask.siteId = m.global.site_id
  m.readLogicTask.control = "RUN"
  m.readLogicTask.observeField("consentData", "getMessage")
end function

function getMessage()
  ' Here we will parse the respnose from logic and send it to mms.
  consentData = m.readLogicTask.consentData
  m.readDialogTask = createObject("roSGNode","MessageGetter")
  m.readDialogTask.consentData = consentData
  m.readDialogTask.observeField("message", "showdialog")
  m.readDialogTask.control = "RUN"
end function

sub showdialog()
  ' Parsing out the relevant message from the MMS service.
  startingID = Instr(1, m.readDialogTask.message, "var msg = ") + 10
  endingID = Instr(1, m.readDialogTask.message, "; var html")
  n = endingID - startingID
  messageJSON = mid(m.readDialogTask.message, startingID, n)
  
  if Len(messageJSON) = 0
    ' SP-TODO : Handle message fetch failure here.
  else 
    message = ParseJson(messageJSON)
    m.msgId = message.msg_id

    ' Parsing out message data.

    contentData = message["data"]["msgContent"]["contentData"]
    title = contentData["title"]
    body = contentData["body"]

    ' Parsing out choice buttons

    choices = message["data"]["choice"]["options"]
    buttons = createObject("roArray", 2, true)

    ' Creating button hashmap for quick lookups.
    
    m.messageButtonsMap = createObject("roAssociativeArray")
    for each choice in choices
      m.messageButtonsMap.AddReplace(choice["button_text"], choice["type"])
      buttons.Push(choice["button_text"])
    End For

    ' Setting the dialog attributes.

    dialog = createObject("roSGNode", "Dialog")
    dialog.backgroundUri = m.global.dialog_background_image
    dialog.optionsDialog = true
    dialog.title = title
    dialog.message = body
    dialog.buttons = buttons
    dialog.ObserveField("buttonSelected","checkSelect")
    m.top.dialog = dialog
  end if
end sub

function checkSelect()
  selectedButtonText = m.top.dialog.buttons.getEntry(m.top.dialog.buttonSelected)
  choiceType = m.messageButtonsMap.lookup(selectedButtonText)

  if choiceType = 2 
    m.top.dialog.close = true
    
    ' SP-TODO : handle case here to navigate back to a panel.
  
  else if choiceType = 11 then
    m.readDialogConsentSetterTask = createObject("roSGNode", "ConsentSetter")
    m.readDialogConsentSetterTask.messageId = m.msgId
    m.readDialogConsentSetterTask.consent_type = "all"
    m.readDialogConsentSetterTask.siteId = m.global.site_id
    m.readDialogConsentSetterTask.control = "RUN"
    m.top.dialog.close = true
    
    ' SP-TODO : handle case here to navigate back to a panel

  else if choiceType = 13 then
    m.readDialogConsentSetterTask = createObject("roSGNode", "ConsentSetter")
    m.readDialogConsentSetterTask.messageId = m.msgId
    m.readDialogConsentSetterTask.consent_type = "none"
    m.readDialogConsentSetterTask.siteId = m.global.site_id
    m.readDialogConsentSetterTask.control = "RUN"
    m.top.dialog.close = true
  
    ' SP-TODO : handle case here to navigate back to a panel

  else if choiceType = 12 then
    m.top.dialog.close = true
    setupPMPanel()
  end if
end function

' SP-TODO : This function will need to be invoked for the privacy manager panel to be rendered.

sub setupPMPanel()
  m.panelset = createObject("roSGNode", "PanelSet")
  m.top.appendChild(m.panelset)

  ' Read user consent data
  m.readUserConsentData = createObject("roSGNode", "UserConsentReader")
  m.readUserConsentData.observeField("userconsentData", "setuserconsentData")
  m.readUserConsentData.control = "RUN"
end sub

sub setuserconsentData()
  ' Read the privacy manager data
  m.readPrivacyManagerContentTask = createObject("roSGNode", "PrivacyManagerDataReader")
  m.readPrivacyManagerContentTask.observeField("privacyManagerData", "setPrivacyManagerContent")
  m.readPrivacyManagerContentTask.control = "RUN"
end sub

sub setPrivacyManagerContent()
  ' Read the purposes from the privacy manager api.
  m.readContentTask = createObject("roSGNode", "PurposeReader")
  m.readContentTask.observeField("content", "setpanels")
  m.readContentTask.control = "RUN"
end sub

sub setpanels()
  m.privacyManagerData = ParseJSON(m.readPrivacyManagerContentTask.privacyManagerData)
  userConsentData = ParseJSON(m.readUserConsentData.userconsentData)
  userCategoriesMap = createObject("roAssociativeArray")
  if not userConsentData.DoesExist("hasConsentData")
    for each category in userConsentData.categories
      userCategoriesMap.AddReplace(category, true)
    end for
  end if
  
  m.listpanel = m.panelset.createChild("PurposeListPanel")
  m.listpanel.observeField("categoriesToConsent", "fireUserPurposesConsent")
  m.listpanel.observeField("appendVendorPanel", "appendVendorsPanel")
  numOfChildren = m.readContentTask.content.getChildCount()
  newCheckedState = createObject("roArray", numOfChildren, false)

  if userConsentData.DoesExist("hasConsentData")
    if m.privacyManagerData.defaultOptedIn
      for i = 0 to numOfChildren - 1
        newCheckedState.SetEntry(i, true)
      end for
      m.listpanel.list.checkedState = newCheckedState
    end if
  else 
    for i = 0 to numOfChildren - 1
      userContentNode = m.readContentTask.content.getChild(i)
      if userCategoriesMap.DoesExist(userContentNode.id)
        newCheckedState.SetEntry(i, true)
      end if
    end for

    m.listpanel.list.checkedState = newCheckedState
  end if
  m.listpanel.list.content = m.readContentTask.content
  m.listpanel.savebuttontext = m.privacyManagerData.saveAndExitText
  m.panel = m.panelset.createChild("VendorPanel")
  m.listpanel.list.observeField("itemFocused", "showpanelinfo")
  m.panel.observeField("focusedChild", "slidepanels")
  m.listpanel.setFocus(true)
end sub

sub appendVendorsPanel()
  m.vendorsCheckList = m.panelset.createChild("VendorsCheckList")
  m.vendorsCheckList.setFocus(true)
  m.vendorsCheckList.observeField("vendorsString", "fireUserVendorsConsent")
  m.vendorsCheckList.list.observeField("itemFocused", "showVendorDesccription")
  m.vendorDescriptionPanel = m.panelset.createChild("VendorDescriptionPanel")
end sub

sub showVendorDesccription()
  purpose = m.vendorsCheckList.list.content.getChild(m.vendorsCheckList.list.itemFocused)
  m.vendorDescriptionPanel.description = purpose.description
end sub

sub fireUserVendorsConsent()
  categories = ParseJSON(m.readUserConsentData.userconsentData).categories
  categoriesString = ""
  if not type(categories) = "Invalid" and categories.count() > 0
    for each category in categories
      categoriesString = categoriesString + Chr(34) + category + Chr(34) + ","
    end for
    categoriesStringLength = Len(categoriesString)
    categoriesString = Left(categoriesString, categoriesStringLength - 1)
    categoriesString = "[" + categoriesString + "]"
  else 
    categoriesString = "[]"
  end if

  vendors = m.vendorsCheckList.vendorsString
  categories = Chr(34) + "categories" + Chr(34) + ":" + categoriesString
  privacyManager = Chr(34) + "privacyManagerId" + Chr(34) + ":" + Chr(34) + m.global.privacy_manager_id + Chr(34)
  userConsentJSONBody = "{" + categories + "," + vendors + "," + privacyManager + "}"
  m.UserConsentSetter = createObject("roSGNode", "UserConsentSetter")
  m.UserConsentSetter.userConsentJSONBody = userConsentJSONBody
  m.UserConsentSetter.control = "RUN"
  m.top.removeChild(m.panelset)
  
  ' SP-TODO : handle case here to navigate back to a panel

end sub

sub fireUserPurposesConsent()
  vendorsString = ""
  
  purposeVendorMap = m.readContentTask.purposeVendorMap
  consentedCategories = m.listpanel.categoriesToConsent.categoriesArray

  if not type(consentedCategories) = "Invalid" and consentedCategories.count() > 0
    for each categoryId in consentedCategories
      reqVendors = purposeVendorMap.lookup(categoryId)
      for each reqVendor in reqVendors
        vendorsString = vendorsString + Chr(34) + reqVendor._id + Chr(34) + ","
      end for
    end for
    vendorsStringLength = Len(vendorsString)
    vendorsString = Left(vendorsString, vendorsStringLength - 1)
    vendorsString = "[" + vendorsString + "]"
  else 
    vendorsString = "[]"
  end if

  categories = m.listpanel.categoriesToConsent.categoriesString
  vendors = Chr(34) + "vendors" + Chr(34) + ":" + vendorsString
  privacyManager = Chr(34) + "privacyManagerId" + Chr(34) + ":" + Chr(34) + m.global.privacy_manager_id + Chr(34)
  userConsentJSONBody = "{" + categories + "," + vendors + "," + privacyManager + "}"
  m.UserConsentSetter = createObject("roSGNode", "UserConsentSetter")
  m.UserConsentSetter.userConsentJSONBody = userConsentJSONBody
  m.UserConsentSetter.control = "RUN"
  showpanelinfo()
  m.top.removeChild(m.panelset)
  
  ' SP-TODO : handle case here to navigate back to a panel

end sub

sub showpanelinfo()
  panelcontent = m.listpanel.list.content.getChild(m.listpanel.list.itemFocused)
  m.panel.description = panelcontent.description
  m.checkList = createObject("roSGNode", "VendorLabelList")
  m.checkList.savebuttontext = m.privacyManagerData.saveAndExitText
  m.checkList.currentCategory = panelcontent.title
end sub

sub slidepanels()
  if not m.panelset.isGoingBack
    m.panelset.appendChild(m.checkList)
    m.checkList.setFocus(true)
  else
    m.listpanel.setFocus(true)
  end if 
end sub

