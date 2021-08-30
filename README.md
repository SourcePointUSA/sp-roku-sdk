# Using the SDk

### Installing the SDK

For each folder in `dist/` copy the `sourcepoint-sdk` folder into your corresponding project folder

### Loading the SDK

The SDK must be created in your main thread, as it will create its own Screen object if it needs to show messages.

See the test-channel for an example of how to trigger SDK functions from your screen if needed.

After creating your application's screen, create the SourcepointSDK:
```
m.spSdk = new SourcepointSdk(accountId, propertyHref, legislationConfigs, optionalConfigs, showMessage)
```
Arguments:
- `accountId` (Integer, required) : your account id, ex `22`
- `propertyHref` (String, required) : your property href, ex `"http://www.sourcepoint.com"`
- `legislationConfigs` (Object, required) : the legislations to enable, optionalally with configs
ex:
```
{"ccpa": { "targetingParams": {"roku": true} }, "gdpr": {}}
```
- `optionalConfigs` (Object, optional) : additional configs, accepted keys:
  - `authId` (String) : universal authId, see Sourcepoint documentation for additional info
  - `campaignEnv` ("public" | "stage") : which campaign type to query, defaults to public
  - `consentLanguage` (String) : two letter consent language 
- `showMessage` (Boolean, optional) : whether to get and show messages, and retrieve consent right away, defaults to `true`

### Retrieving user consent
```
consent = m.spSdk.getUserConsent()
```
The first time this is called your configured scenarios will run and determine whether to show a message or message(s). 
If your scenarios dictate a message or message(s) should be shown, this will create a new screen and show those messages. Once messages have been dismissed, consent will be returned. Each subsequent call to this function will return the same consent object.

If showMessage is `true` when SourcepointSdk is created this will be called automatically.

### Opening a Privacy Manager
```
m.spSdk.openPrivacyManager(privacyManagerId)
```
Arguments:
- `privacyManagerId` (Integer) : the ID of the privacy manager to open

As an alternative to hardcoding a `privacyManagerId`, you can setup a targeted scenario and call `m.spSdk.runCampaignLogic(legislationsEnabled)` to show your PM

For example: `m.spSdk.runCampaignLogic({ "gdpr": { "targetingParams": { "showPm": true } } })` to re-run campaign logic for only GDPR, sending specific targetingParams that will trigger a show PM always scenario. (Note: these are example targeting params corresponding to an example scenario)

# Developing the SDK

Enable development mode for your Roku device: https://developer.roku.com/en-gb/docs/developer-program/getting-started/developer-setup.md

Install dependencies:

`npm install`

Run Brighterscript compiler with auto channel reloading:

`ROKU_DEV_HOST=[roku device ip] ROKU_DEV_PASSWORD=[roku device password] npm run develop`

# Testing the SDK

Running tests:

`ROKU_DEV_HOST=[ device ip ] ROKU_DEV_USER=[ device user ] ROKU_DEV_PASSWORD=[ device password ] npm run test`

Note: contents of `tests/bin` and `tests/lib` are from https://github.com/rokudev/automated-channel-testing

# Releasing the SDK

Compile Brighterscript to Brightscript:

`npm run compile`

Push the updates

Create a new release
