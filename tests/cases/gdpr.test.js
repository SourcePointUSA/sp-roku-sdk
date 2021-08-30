const rokuLibrary = require("../lib/rokuLibrary");
const { expectIds } = require('../helpers')

let library;

jest.setTimeout(30 * 1000);

beforeAll(async () => {
    library = new rokuLibrary.Library(process.env.ROKU_DEV_HOST);
    await library.sideLoad("./out/sp-roku-sdk.zip", process.env.ROKU_DEV_USER, process.env.ROKU_DEV_PASSWORD);
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
            'category_slider',
            'image_logo', 
            'button_nav_back',
            'accept_all',
            'save_and_exit'
        ])
    })

    it(`should let us navigate to a category detail view`, async () => {
        await library.sendKeys(["right", "select"])

        const elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "CategoryViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)

        await expectIds(library, ['image_logo', 'button_nav_back', 'vendor_list', 'category_description'])
    })

    it(`should go back to the categories view if we hit the back button`, async () => {
        // go back
        await library.sendKeys(["left", "left", "select"])
    })

    it(`should show the LI category list if we choose to`, async () => {
        // make sure we start from the back button 
        await library.sendKeys(["left", "left"])

        // navigate to slider and move it
        await library.sendKeys(["right", "up", "right"])

        await expectIds(library, ["category_list_li"])
    })

    it(`should let us navigate to a LI category detail view`, async () => {
        await library.sendKeys(["down", "right", "select"])

        const elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "CategoryViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)

        await expectIds(library, ['image_logo', 'button_nav_back', 'vendor_list', 'category_description'])
    })

    it(`should let us navigate home via the back button`, async () => {
        await library.sendKeys(["left", "left", "select"])

        let elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "CategoriesViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)

        await library.sendKeys(["left", "left", "select"])

        elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "HomeViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)
    })

    it(`should let us navigate to the vendors view`, async () => {
        let focusedEl = await library.getFocusedElement()
        let focusedElName = library.getAttribute(focusedEl, 'name');
        let presses = 0;

        while(focusedElName !== "button_nav_vendors" && presses <= 10) {
            await library.sendKey("down")

            focusedEl = await library.getFocusedElement()
            focusedElName = library.getAttribute(focusedEl, 'name');

            presses ++;
        }

        await library.sendKey("select")

        const elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "VendorsViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)
    })

    it(`should show the logo, vendor list, back button`, async () => {
        await expectIds(library, [
            'vendor_list', 
            'vendor_slider',
            'image_logo', 
            'button_nav_back',
            'accept_all',
            'save_and_exit'
        ])
    })

    it(`should let us navigate to a vendor detail view`, async () => {
        await library.sendKey("right")
        await library.sendKey("select")

        let elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "VendorViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)

        await expectIds(library, ["privacy_policy_url", "category_list"])
    })

    it(`should let us navigate back to home`, async () => {
        await library.sendKeys(["left", "left", "select"])

        let elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "VendorsViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)

        await library.sendKeys(["left", "left", "select"])

        elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "HomeViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)
    })

    it(`should let us navigate to the privacy policy`, async () => {
        let focusedEl = await library.getFocusedElement()
        let focusedElName = library.getAttribute(focusedEl, 'name');
        let presses = 0;

        while(focusedElName !== "button_nav_privacy_policy" && presses <= 10) {
            await library.sendKey("down")

            focusedEl = await library.getFocusedElement()
            focusedElName = library.getAttribute(focusedEl, 'name');

            presses ++;
        }

        await library.sendKey("select")

        const elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "PrivacyPolicyViewGdpr"
            }]
        })

        expect(elements.length).toBe(1)
    })
})