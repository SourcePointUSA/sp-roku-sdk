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

        const buttonSearchData = [{"using": "attr", attribute: "text", "value": "run gdpr campaign"}];
        let focusedEl = await library.getFocusedElement()
        let buttonLabel = await library.getChildNodes(focusedEl, buttonSearchData)
        let presses = 0;

        while(buttonLabel.length === 0 && presses <= 10) {
            await library.sendKey("down")

            focusedEl = await library.getFocusedElement()
            buttonLabel = await library.getChildNodes(focusedEl, buttonSearchData)

            presses ++;
        }

        await library.sendKey("select")
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

    it(`should let us navigate to the categories view`, async () => {
        let focusedEl = await library.getFocusedElement()
        let focusedElName = library.getAttribute(focusedEl, 'name');
        let presses = 0;

        while(focusedElName !== "button_nav_categories" && presses <= 10) {
            await library.sendKey("down")

            focusedEl = await library.getFocusedElement()
            focusedElName = library.getAttribute(focusedEl, 'name');

            presses ++;
        }

        await library.sendKey("select")

        const elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "CategoriesViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)
    })

    it(`should show the logo, category list, back button`, async () => {
        await expectIds(library, [
            'category_list', 
            'category_list_li',
            'category_slider',
            'image_logo', 
            'button_nav_back',
            'accept_all',
            'save_and_exit'
        ])
    })
})