# Barcodes

Barcodes is a simple app for scanning barcodes, looking them up on [UPC Database](http://upcdatabase.org), and searching for the result on [DuckDuckGo](https://duckduckgo.com).

## Setting Up

To use the app, you need to get an API key from UPC Database. Once you've registered an account there, your API key can be found in the [API control panel](http://upcdatabase.org/ucp-api).

Your API key will need to be pasted into the `kUPCDatabaseAPIKey` constant in `SOSBarcodeInformationRequest`. There's currently an error set up there to remind you to do that. Comment out the error once you've set your key up.

## Trying the App

You'll need to be a member of the [developer program](https://developer.apple.com/programs/ios/) to use the app, as it needs to be run on a physical device.

## Acknowledgments

Barcodes uses [TSMessages](https://github.com/toursprung/TSMessages) to notify the user that a barcode has been detected.