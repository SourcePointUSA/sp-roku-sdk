
# Roku SourcepointSdk

### Install the SDK

For each folder in `dist/` copy the `sourcepoint-sdk` folder into your corresponding project folder.

### Load the SDK

The SDK must be created in your main thread, as it will create its own Screen object if it needs to show messages.

> **Note:** See the test-channel for an example of how to trigger SDK functions from your screen if needed.

After creating your application's screen, create the SourcepointSdk:
```
m.spSdk = new SourcepointSdk(accountId, propertyHref, legislationConfigs, optionalConfigs, showMessage)
```
SourcepointSdk takes the following arguments:



| Argument             | Data Type           | Required? | Description                                                                                                                                                                                                                                                                                                                          |
|----------------------|---------------------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `accountId`          | Integer             | Required  | The `accountId` associates the property with your organization's Sourcepoint account. It can be retrieved by contacting your Sourcepoint Account Manager or via the  **My Account** page in your Sourcepoint account.                                                                                                                |
| `propertyHref`       | String              | Required  | Maps the implementation to a specific URL as set up in the Sourcepoint account dashboard. (e.g. `https://www.sourcepoint.com`)                                                                                                                                                                                                       |
| `legislationConfigs` | Object              | Required  | The consent legislations enabled for your implementation with optional configs. For example:<br>  `{"ccpa": { "targetingParams": {"roku": true} }, "gdpr": {}}`                                                                                                                                                                      |
| `optionalConfigs`    | Object              | Optional  | Optional configurations for your implementation which accepts the following keys:<br> -`authId` <br> -`campaignEnv` <br> -`consentLanguage`                                                                                                                                                                                          |
| `authId`             | String              | Optional  | Allows your organization to share an end-user's consent preferences across their different authenticated (i.e. logged-in) devices. [Click here](https://documentation.sourcepoint.com/consent_mp/authenticated-consent/authenticated-consent-overview) to learn more.<br><br> **Note:** Included in your `optionalConfigs` argument. |
| `campaignEnv`        | "public" \| "stage" | Optional  | When set to `stage`, the implementation will default to campaigns configured in your stage campaign environment. This parameter defaults to `public`.<br><br> **Note:** Included in your `optionalConfigs` argument.                                                                                                                 |
| `consentLanguage`    | String              | Optional  | Ensure that the purposes or stack names listed in a consent message remain in the same language regardless of an end-user's browser language setting. [Click here](https://www.loc.gov/standards/iso639-2/php/code_list.php) for a list of ISO 639-1 language codes.<br><br> **Note:** Included in your `optionalConfigs` argument.  |
| `showMessage`        | Boolean             | Optional  | Decides whether to get and show messages, and retrieve consent immediately. This parameter defaults to `true`.                                                                                                                                                                                                                       |



### Retrieve user consent
```
consent = m.spSdk.getUserConsent()
```
The first time this is called your configured scenarios will run and determine whether to show a message(s).
If your scenarios dictate a message(s) should be shown, this will create a new screen and show those message(s). Once message(s) have been dismissed, the end-users consent will be returned. Each subsequent call to this function will return the same consent object.

If `showMessage` is `true` when SourcepointSdk is created this will be called automatically.

### Open a Privacy Manager
To open a privacy manager you can hardcode the ID of the privacy manager to open by running:
```
m.spSdk.openPrivacyManager(privacyManagerId)
```
The above accepts the following as an argument:

| Argument           | Data Type | Description                            |
|--------------------|-----------|----------------------------------------|
| `privacyManagerId` | Integer   | The ID of the privacy manager to open. |


As an alternative to hardcoding a `privacyManagerId`, you can setup a targeted scenario and call `m.spSdk.runCampaignLogic(legislationsEnabled)` to show your privacy manager.

> For example: `m.spSdk.runCampaignLogic({ "gdpr": { "targetingParams": { "showPm": true } } })` to re-run campaign logic for only GDPR, sending specific targetingParams that will trigger a show PM always scenario. (Note: these are example targeting params corresponding to an example scenario).

# Developing the SDK

Enable development mode for your Roku device: https://developer.roku.com/en-gb/docs/developer-program/getting-started/developer-setup.md

Install dependencies:

```
npm install
```

Run Brighterscript compiler with auto channel reloading:

```
ROKU_DEV_HOST=[roku device ip] ROKU_DEV_PASSWORD=[roku device password] npm run develop
```

# Testing the SDK

Running tests:

```
ROKU_DEV_HOST=[ device ip ] ROKU_DEV_USER=[ device user ] ROKU_DEV_PASSWORD=[ device password ] npm run test
```

Note: contents of `tests/bin` and `tests/lib` are from https://github.com/rokudev/automated-channel-testing

# Releasing the SDK

Compile Brighterscript to Brightscript:

```
npm run compile
```

Push the updates.

Create a new release.
