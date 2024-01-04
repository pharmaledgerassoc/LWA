import {translate} from "../translationUtils.js";
import {setFontSize} from "../../../utils.js";

window.onload = async (event) => {
  await translate();
}

document.getElementsByTagName("body").onload = setFontSize();


