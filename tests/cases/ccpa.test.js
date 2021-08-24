const rokuLibrary = require("../lib/rokuLibrary");
const { spawn } = require('child_process');

let path;

switch(process.platform) {
    case "linux": 
        path = './tests/bin/RokuWebDriver_linux'
        break;
    case "win32":
        path = './tests/bin/RokuWebDriver_win.exe'
        break;
    case "darwin":
        path = './tests/bin/RokuWebDriver_mac'
        break;
    default:
        throw new Error("Unsupported OS")
        break;
        
}

const childProcess = spawn(path);

let library;

jest.setTimeout(30 * 1000);

beforeAll(async () => {
    library = new rokuLibrary.Library(process.env.ROKU_HOST);
    await library.sideLoad("./out/sp-roku-sdk.zip", process.env.ROKU_USER, process.env.ROKU_PASSWORD);
});

afterAll(async () => {
    await library.close();
    childProcess.kill()
});

const expectIds = async (idsToFind) => {
    for(let i = 0; i < idsToFind.length; i++) {
        let id = idsToFind[i];

        let elements = await library.getElements({ 
            elementData: [
                {
                    using: "attr",
                    attribute: "name",
                    value: id
                }
            ]
        })

        expect(elements.length).toBe(1)
    }
}

describe(`CCPA view validation`, () => {
    it(`should launch the test channel`, async () => {
        const verified = await library.verifyIsChannelLoaded('dev');

        expect(verified).toBe(true);
    })

    it(`should show the home screen`, async () => {
        const elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "HomeViewCcpa"
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
            "save_and_exit", 
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

    it(`should show the logo, DNS button`, async () => {
        await expectIds(['image_logo', 'dns_button_holder'])
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
                value: "CategoriesViewCcpa"
            }]
        })

        expect(elements.length).toBe(1)
    })

    it(`should show the logo, category list, back button`, async () => {
        await expectIds(['category_list', 'image_logo', 'button_nav_back'])
    })

    it(`should let us navigate to a category detail view`, async () => {
        await library.sendKey("right")
        await library.sendKey("select")

        const elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "CategoryViewCcpa"
            }]
        })

        expect(elements.length).toBe(1)

        await expectIds(['image_logo', 'button_nav_back', 'vendor_list'])
    })

    it(`should let us navigate back to home`, async () => {
        await library.sendKey("left")
        await library.sendKey("select")

        let elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "CategoriesViewCcpa"
            }]
        })

        expect(elements.length).toBe(1)

        await library.sendKey("left")
        await library.sendKey("select")

        elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "HomeViewCcpa"
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
                value: "VendorsViewCcpa"
            }]
        })

        expect(elements.length).toBe(1)
    })

    it(`should show the logo, vendor list, back button`, async () => {
        await expectIds(["image_logo", "vendor_list", "button_nav_back"])
    })

    it(`should let us navigate to a vendor detail view`, async () => {
        await library.sendKey("right")
        await library.sendKey("select")

        let elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "VendorViewCcpa"
            }]
        })

        expect(elements.length).toBe(1)

        await expectIds(["image_logo", "privacy_policy_url", "category_list"])
    })

    it(`should let us navigate back to home`, async () => {
        await library.sendKey("left")
        await library.sendKey("select")

        let elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "VendorsViewCcpa"
            }]
        })

        expect(elements.length).toBe(1)

        await library.sendKey("left")
        await library.sendKey("select")

        elements = await library.getElements({ 
            elementData: [{
                using: "tag",
                value: "HomeViewCcpa"
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
                value: "PrivacyPolicyViewCcpa"
            }]
        })

        expect(elements.length).toBe(1)
    })

    it(`should show privacy policy`, async () => {
        await expectIds(["privacy_policy_body", "button_nav_back", "image_logo"])
    })
})