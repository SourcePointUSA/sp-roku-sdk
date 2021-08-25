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

module.exports = {
    expectIds
}