'import "pkg:/source/sourcepoint-sdk/Helpers.bs"

sub init()
    ' pass
end sub

function _makeRequest(url as string, method as string, body = {} as object, retry = true as boolean) as object
    request = createObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.AddHeader("X-Roku-Reserved-Dev-Id", "")
    request.InitClientCertificates()
    request.RetainBodyOnError(true)
    request.SetUrl(url)
    port = createObject("roMessagePort")
    request.setPort(port)
    if UCase(method) = "GET" then
        request.asyncGetToString()
    else if UCase(method) = "POST" then
        request.addHeader("Content-Type", "application/json")
        request.asyncPostFromString(FormatJson(body))
    end if
    response = port.waitMessage(10 * 1000)
    responseBody = invalid
    try
        responseBody = ParseJson(response)
    catch error
        m.top.error = "Invalid JSON response"
        print m.top.error
        return invalid
    end try
    if response.GetResponseCode() = 200 then
        return responseBody
    else if response.GetResponseCode() = 500 and retry = true then
        ' sleep for 2 seconds and retry if we hit a 500
        Sleep(2 * 1000)
        return _makeRequest(url, method, body, false)
    else if responseBody <> invalid then
        m.top.error = "Request failed with error:" + response.GetFailureReason()
        print "Request failed with error:"
        print responseBody
        print response.GetFailureReason()
        print "=========================="
        print url
        print FormatJson(body)
        print "=========================="
        return invalid
    else
        m.top.error = "Request failed with error:" + response.GetFailureReason()
        print "Request failed with no response body"
        print response.GetFailureReason()
        return invalid
    end if
end function

function makeRequest(url as string, method as string, body = {} as object) as object
    response = _makeRequest(url, method, body)
    if response = invalid then
        if m.top.resetOnError = true then
            ' if we errored, reset localstate
            setLocalState(invalid)
        end if
    else if response.localState <> invalid then
        setLocalState(response.localState)
    end if
    return response
end function