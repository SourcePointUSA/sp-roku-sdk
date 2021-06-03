'********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub Main()
  showChannelSGScreen()
end sub

sub showChannelSGScreen()
  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)

  LoadConfig()
  m.global = screen.getGlobalNode()
  m.global.addField("site_id", "string", true)
  m.global.site_id = m.site_id
  m.global.addField("privacy_manager_id", "string", true)
  m.global.privacy_manager_id = m.privacy_manager_id
  m.global.addField("dialog_background_image", "string", true)
  m.global.dialog_background_image = m.dialog_background_image

  scene = screen.CreateScene("Main")
  screen.show()

  while(true)
    msg = wait(0, m.port)
    msgType = type(msg)

    if msgType = "roSGScreenEvent"
      if msg.isScreenClosed() then return
    end if
  end while

end sub
