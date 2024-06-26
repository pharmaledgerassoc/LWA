import constants from "../../../constants.js";
import {escapeHTML} from "../../../utils.js"

function LogsController() {
    let debugLog = JSON.parse(localStorage.getItem(constants.DEV_DEBUG));
    const formattedJSON = JSON.stringify(debugLog, null, 4);
    document.querySelector("#logs-container").textContent = escapeHTML(formattedJSON);
}

const logsController = new LogsController();

