# sp-roku-sdk
SP SDK for ROKU.

The SP-Roku-SDK leverages the SceneGraph API. Hence, it only integrates with Roku Channels that leverage the SceneGraph API themselves.

To integrate the SP-Roku-SDK into your app :  
* Unzip the file.
* Copy-Paste the contents of the `components` folder into your project’s `components` folder.
* Copy-Paste the code in the `ConsentDialog.brs` file into your  main Scene file.
* Delete the `ConsentDialog.brs` file.
* Invoke the `setUpDialogVars()` function from your Scene’s `init()` function.
* Copy the `config.brs` file or its contents into your project’s `source` folder.
* Replace the `site_id`, `privacy_manager_id` and `dialog_background_image` with the desired values in the `config.brs` file.
* Replace all `SP-TODO`s with the desired action.

