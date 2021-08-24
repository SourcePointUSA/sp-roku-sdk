const rokuLibrary = require("../lib/rokuLibrary");
const { spawn } = require('child_process');

let path;

switch(process.env.TEST_OS) {
    case "linux": 
        path = './tests/bin/RokuWebDriver_linux'
        break;
    case "windows":
        path = './tests/bin/RokuWebDriver_win.exe'
        break;
    case "mac":
    default:
        path = './tests/bin/RokuWebDriver_mac'
        break;
        
}
const childProcess = spawn(path);

let library;

jest.setTimeout(30 * 1000);

describe(`CCPA campaign tests`, () => {
    beforeAll(async () => {
        library = new rokuLibrary.Library("192.168.4.43");
        await library.sideLoad("./out/sp-roku-sdk.zip", "rokudev", "pittsburgh2020");
    });

    afterAll(async () => {
        await library.close();
        childProcess.kill()
    });

    it(`should launch the test channel`, async () => {
        const verified = await library.verifyIsChannelLoaded('dev');

        expect(verified).toBe(true);
    })
})