function addQueryParams(uri as string, params as object) as string
    separator = bslib_ternary(uri.Instr(0, "?") < 0, "?", "&")
    for each k in params
        if params[k] <> invalid then
            uri = uri + separator + k + "=" + params[k].ToStr().Escape()
            separator = "&"
        end if
    end for
    return uri
end function

function createFont(fontSettings as object) as object
    font = CreateObject("roSGNode", "Font")
    if fontSettings <> invalid and fontSettings.fontWeight <> invalid and fontSettings.fontWeight <> "400" then
        font.uri = "font:BoldSystemFontFile"
    else
        font.uri = "font:SystemFontFile"
    end if
    if fontSettings <> invalid and fontSettings.fontSize <> invalid then
        font.size = fontSettings.fontSize
    else
        font.size = 14
    end if
    return font
end function

' Convert html hex to roku hex
function colorConvert(color as string) as string
    if color <> invalid then
        return color.replace("#", "0x") + "FF"
    end if
    return color
end function

function getLocalState() as string
    registry = CreateObject("roRegistrySection", "SourcepointSdk")
    if registry.Exists("localState") then
        return registry.read("localState")
    end if
    return ""
end function

function htmlEntityDecode(baseStr as string) as string
    return baseStr.replace("&quot;", """").replace("&apos;", "'").replace("&lt;", "<").replace("&gt;", ">").replace("&amp;", "&")
end function

sub setLocalState(localState)
    registry = CreateObject("roRegistrySection", "SourcepointSdk")
    if localState = invalid then
        localState = ""
    end if
    registry.write("localState", localState)
    registry.flush()
end sub

function getUuid(legislation) as string
    localState = getLocalState()
    if localState <> "" then
        localState = ParseJson(localState)
        if localState[legislation] <> invalid and localState[legislation].uuid <> invalid then
            return localState[legislation].uuid
        end if
    end if
    return ""
end function

sub scalePixelDimensions(node as object, scaleMap as object)
    resolutionInfo = m.top.getScene().currentDesignResolution
    for each nodeId in scaleMap
        updateNode = node.findNode(nodeId)
        if updateNode <> invalid then
            if type(scaleMap[nodeId]) = "roFunction" then
                dims = scaleMap[nodeId](updateNode, resolutionInfo.width, resolutionInfo.height)
            else
                dims = scaleMap[nodeId]
            end if
            for i = 0 to (dims.count() - 1) step 1
                if dims[i] <> invalid and dims[i] > 0 then
                    dims[i] = scalePixelDimension(dims[i], resolutionInfo)
                end if
            end for
            if dims[0] <> invalid and dims[1] <> invalid then
                updateNode.translation = [
                    dims[0],
                    dims[1]
                ]
            end if
            if dims[2] <> invalid then
                updateNode.width = dims[2]
            end if
            if dims[3] <> invalid then
                updateNode.height = dims[3]
            end if
        end if
    end for
end sub

function scalePixelDimension(value as float, resolutionInfo = invalid as object) as float
    if resolutionInfo = invalid then
        resolutionInfo = m.top.getScene().currentDesignResolution
    end if
    if resolutionInfo.resolution = "FHD" then
        return value * 1.5
    end if
    return value
end function

function stripHtmlTags(baseStr as string) as string
    baseStr = baseStr.replace("</p>", chr(10))
    r = createObject("roRegex", "<[^<]+?>", "i")
    return htmlEntityDecode(r.replaceAll(baseStr, "")).trim()
end function