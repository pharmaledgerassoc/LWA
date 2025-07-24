import { getDocumentFromFHIR, createLaflet } from "./app/js/utils/fhirLeaflet.js";

import {json} from './bundletest.js';

const compositions = getDocumentFromFHIR(json);

console.log("lenght",compositions.length)



const container = document.getElementById('container');
const leaflet = createLaflet(compositions[0],container);
console.log(leaflet);




