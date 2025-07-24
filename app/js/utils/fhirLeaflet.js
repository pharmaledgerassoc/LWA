/**
 * Gets a document from the FHIR object
 * 
 * @param {object} json - FHIR Bundle object.
 * @returns {object} the
 */
function getDocumentFromFHIR(json) {
    const compositions = [];
  
    function recurse(obj) {
      if (Array.isArray(obj)) {
        for (const item of obj) {
          recurse(item);
        }
      } else if (obj !== null && typeof obj === 'object') {
        if (obj.resourceType === 'Composition') {
          compositions.push(obj.section[0]);
        }
        for (const value of Object.values(obj)) {
          recurse(value);
        }
      }
    }
  
    recurse(json);
  
    return compositions;
}

function createLaflet(composition, leaflet) {
  
  function recurse(obj,element) {
    if (Array.isArray(obj)) {
      for (const item of obj) {
        recurse(item,element);
      }
    } else if (obj !== null && typeof obj === 'object') {
      let childELement = document.createElement("div");
      if (obj.code.coding.display !== null) {
        let title = document.createElement("h2");
        title.textContent = obj.code.coding[0].display;
        childELement.appendChild(title);
        if(obj.text.div !== undefined){
          const template = document.createElement('template');
          template.innerHTML = obj.text.div.trim();
          const divElement = template.content;
          const div = document.createElement('div');
          div.appendChild(divElement)
          childELement.appendChild(div);
        }
        element.appendChild(childELement)
        if(obj.section !== null){
          recurse(obj.section, childELement);
        }
      }
      
    }
  }

  recurse(composition.section,leaflet);

  return leaflet;
}

export {
    getDocumentFromFHIR,
    createLaflet
}