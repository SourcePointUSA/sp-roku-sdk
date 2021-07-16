# Using the SDk

1. For each folder in `dist/` copy the `sourcepoint-sdk` folder into your corresponding project folder
2. After creating your application's screen, create the SourcepointSDK:
```
m.spSdk = new SourcepointSdk([[ accountId ]], [[ propertyHref ]], [[ legislation configs ]])
```
Arguments:
- [[ accountId ]] (Integer) : your account id, ex `22`
- [[ propertyHref ]] (String) : your property href, ex `"http://www.sourcepoint.com"`
- [[ legislation configs ]] (Object) : the legislations to enable along with their configs (optional)
ex:
```
{"ccpa": { "targetingParams": {"roku": true} }, "gdpr": {}}
```
3. Retrieve user consent
```
consent = m.spSdk.getUserConsent()
```
The first time this is called your configured scenarios will run and determine whether to show a message or message(s). 
If your scenarios dictate a message or message(s) should be shown, this will create a new screen and show those messages. Once messages have been dismissed, consent will be returned. Each subsequent call to this function will return the same consent object.

# Developing the SDK

Install dependencies:

`npm install`

Run Brighterscript compiler with auto channel reloading:

`ROKU_DEV_HOST=[roku device ip] ROKU_DEV_PASSWORD=[roku device password] npm run develop`

# Releasing the SDK

Compile Brighterscript to Brightscript:

`npm run compile`

Push the updates

Create a new release