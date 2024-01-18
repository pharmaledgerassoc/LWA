import environment from "../environment.js";

const appPages = ["main.html", "scan.html", "leaflet.html", "error.html"];

window.onload = () => {
  try {
    let urlParts = location.href.split(location.origin)[1].split("/").filter(function (item) {
      return item !== "";
    })

    let pageWithQuery = urlParts[urlParts.length - 1].split("?");
    let page = pageWithQuery[0];
    let query = pageWithQuery[1]

    if (appPages.indexOf(page) !== -1) {
      validateAndRedirect(constructUrl("main.html"));
    } else {
      validateAndRedirect(constructUrl(page, query));
    }

  } catch (e) {
    goTo404ErrPage()
  }

}

function goTo404ErrPage() {
  let err404Page = `/app/404.html`;
  if (environment.enableRootVersion) {
    err404Page = `/${environment.appBuildVersion}/404.html`;
  }
  window.location.href = window.location.origin + err404Page;
}

function constructUrl(page, query) {
  return query ? `${window.location.origin}/${environment.appBuildVersion}/${page}?${query}` : `${window.location.origin}/${environment.appBuildVersion}/${page}`
}

function validateAndRedirect(url) {
  let validPagesRegex = Object.values(appPagesMap).join("|");
  const regexPattern = new RegExp(`^${window.location.origin}/${environment.appBuildVersion}/(${validPagesRegex})$`);
  if (regexPattern.test(url)) {
    window.location.href = url;
  } else {
    throw new Error("Invalid or potentially harmful URL.")
  }
}
