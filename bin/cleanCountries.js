import {countries} from "../app/js/countriesUtils.js"
import fs from 'fs';
import path from 'path';
// import data from "../app/translations/en.js"

const root = process.cwd();

function getFilesFromDirectory(directoryPath) {
  try {
    const files = fs.readdirSync(directoryPath);
    return files;
  } catch (err) {
    console.error('Error reading directory:', err);
    return [];
  }
}

const directoryPath = path.join(root, "app", "translations");
const translationFiles = getFilesFromDirectory(directoryPath);

function removeKeysFromObject(obj, keysToRemove) {
  for (let key in obj) {
    if (keysToRemove.includes(key)) {
      delete obj[key];
    }
  }
}

function getKeysStartingWithPrefix(obj, prefix) {
  return Object.keys(obj)
    .filter(key => key.startsWith(prefix))
    .map(key => key.toLowerCase()); // Convert the filtered keys to lowercase
}

function saveFile(lang, data){
  const content = `const data = ${JSON.stringify(data, undefined, 2)}

export default data;`;
  fs.writeFileSync(path.join(root, "app", "translations", `${lang}`), content);
}


let endCountriesList = countries.map(country => country.code.toLowerCase());
endCountriesList.shift();
console.log("countries list:"+endCountriesList.length())

translationFiles.forEach(async (file) => {

  let datafile = await import(`../app/translations/${file}`);
  let data = datafile.default;

  let updatedEndCountriesList = endCountriesList.map(country => "country_" + country);

  let tranlationsCountryList = getKeysStartingWithPrefix(data,"country_")

  const removecountries = tranlationsCountryList.filter(item => !updatedEndCountriesList.includes(item));

  const finalData = removeKeysFromObject(data, removecountries);

  saveFile(file,data);

})







