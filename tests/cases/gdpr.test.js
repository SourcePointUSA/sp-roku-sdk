const rokuLibrary = require("../lib/rokuLibrary");
const { expectIds } = require('../helpers')

let library;

jest.setTimeout(30 * 1000);

beforeAll(async () => {
    library = new rokuLibrary.Library(process.env.ROKU_HOST);
    await library.sideLoad("./out/sp-roku-sdk.zip", process.env.ROKU_USER, process.env.ROKU_PASSWORD);
});

afterAll(async () => {
    await library.close();
});

describe(`GDPR view validation`, () => {
    it(`should launch the test channel`, async () => {
        const verified = await library.verifyIsChannelLoaded('dev');

        expect(verified).toBe(true);

        await library.sendKeys(["down", "down", "select"])
    })

    it(`should show the home screen`, async () => {
        const elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "HomeViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)
    })

    it(`should show the home screen navigation`, async () => {
        const elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "SpNativeButton"
            }]
        })

        const expectedButtonIds = [
            "accept_all", 
            "reject_all", 
            "button_nav_categories", 
            "button_nav_vendors",
            "button_nav_privacy_policy"
        ]

        elements.forEach((b) => {
            const buttonId = library.getAttribute(b, 'name');
            expect(expectedButtonIds.includes(buttonId)).toBe(true)
        })

        expect(elements.length).toBe(expectedButtonIds.length)
    })
})