module.exports = async () => {
    if (global.webDriverProcess) {
        global.webDriverProcess.kill();
    }
}