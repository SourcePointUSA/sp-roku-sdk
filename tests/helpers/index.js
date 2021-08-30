const expectIds = async (library, idsToFind) => {
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

const getToggleButtonValue = async (library, buttonNode) => {
    const buttonSearchData = [
        {
            using: "attr",
            attribute: "name",
            value: "on_off_toggle"
        }
    ];
    let onOffToggle = await library.getChildNodes(buttonNode, buttonSearchData)
    
    try {
        return library.getAttribute(onOffToggle[0].Nodes[0], "text").toLowerCase()
    } catch(e) {
        return null
    }
}

module.exports = {
    expectIds,
    getToggleButtonValue
}