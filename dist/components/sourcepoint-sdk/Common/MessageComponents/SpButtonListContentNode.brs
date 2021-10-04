sub init()
    m.top.observeField("on", "updateOff")
end sub

' boolean interface fields default to "false" not "invalid"
' we can set "off" based on "on" being set, 
' and then in our button check both 
' ex: on = false and off = false means nothing has been set
sub updateOff(event as object)
    on = event.getData()
    if on = true then
        m.top.off = false
    else
        m.top.off = true
    end if
end sub