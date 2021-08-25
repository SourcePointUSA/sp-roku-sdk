const { spawn } = require('child_process');

module.exports = async () => {
    let childProcess, path;
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

    childProcess = spawn(path)

    global.webDriverProcess = childProcess;

    await new Promise(resolve => setTimeout(resolve, 3000));
}