import environment from "../environment.js";

const appPagesMap = {
  "index": "main.html",
  "main": "main.html",
  "scan": "scan.html",
  "leaflet": "leaflet.html",
  "error": "error.html"
};

window.onload = () => {
  debugger;
  let urlParts = location.href.split(location.origin)[1].split("/").filter(function (item) {
    return item !== "";
  })
  if (!urlParts.includes(`/${environment.appBuildVersion}`)) {
    let pageWithQuerry = urlParts[urlParts.length - 1];

    Object.keys(appPagesMap).forEach(key => {
      if (pageWithQuerry.startsWith(key)) {
        let regexPattern = new RegExp(key + '.*?\\.html');
        pageWithQuerry.replace(regexPattern, appPagesMap[key]);
      }
    })
    if (!Object.values(appPagesMap).find(val => pageWithQuerry.startsWith(val))) {
      pageWithQuerry = "main.html";
    }
    let newUrl = environment.enableRootVersion ? `${window.location.origin}/${environment.appBuildVersion}/${pageWithQuerry}` : `${window.location.origin}/lwa/app/${pageWithQuerry}`;

    window.location.href = newUrl;
    return;
  }
  let err404Page = `/app/404.html`;
  if (environment.enableRootVersion) {
    err404Page = `/${environment.appBuildVersion}/404.html`;
  }
  window.location.href = window.location.origin + err404Page;
}
