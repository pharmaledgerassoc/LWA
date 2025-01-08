const path = require('path');
const fs = require('fs');
const root = process.cwd();
const { translate } = require('@vitalets/google-translate-api');
const [command, ...args] = process.argv.slice(2);

let availableTranslations;

function getAvailableLanguages(){
  if (availableTranslations)
    return availableTranslations;
  availableTranslations = fs.readdirSync(path.join(root, "app", "translations"))
    .filter(file => file.match(/\w{2}(-\w{2,})?\.js/g))
    .map(file => {
      const regexp = /(\w{2}(?:-\w{2,})?)\.js/g
      const match = regexp.exec(file);
      if (!match) throw new Error(`Invalid file name: ${file}`);
      return match[1];
    })
  return availableTranslations;
}

async function translateString(fromLang, toLang, str){
  return (await translate(str, {from: fromLang, to: toLang})).text;
}

async function addKey(lang, key, str){
  const languages = getAvailableLanguages();
  let file = fs.readFileSync(path.join(root, "app", "translations", `${lang}.js`)).toString();
  const regexp = /const data = (.*)export default data;/gm

  function parseFile(f){
    const match = regexp.exec(f);
    if (!match)
      throw new Error(`Invalid file content ${key}.js`);
    return JSON.parse(match[1].trim());
  }

  let json = parseFile(file);
  json[key] = str;

  function saveFile(l, j){
    fs.writeFileSync(path.join(root, "app", "translations", `${l}.js`),
      `const data = ${JSON.stringify(j, undefined, 2)};

export default data;`);
  }

  saveFile(lang, json);

  for (const otherLang in Object.values(languages)){
    if (otherLang === lang){
      console.log(`No need to translate ${key} for ${otherLang}`)
      continue;
    }
    const translated = await translateString(lang, otherLang, str);
    json = parseFile(otherLang);
    json[key] = translated;
    saveFile(otherLang, json);
  }
}

switch (command) {
  case 'key':
    const lang = args.shift();
    if (!getAvailableLanguages().includes(lang))
      throw new Error(`Language ${lang} is not supported`);
    const key = args.shift();
    if (!key)
      throw new Error(`no key specified`);
    const str = args.join(' ').trim();
    if (!str)
      throw new Error(`Empty string provided for key ${lang}`);
    await addKey(lang, key, str)
    break;
  case "add":
    // TODO add new language from template
    break
  default:
    throw new Error(`Invalid command: ${command}`);
}