import environment from "../environment.js";

const appPages = ["main.html", "scan.html", "leaflet.html", "error.html", "about-page.html", "help-page.html", "privacy-page.html", "terms-page.html"];
//regex for GS1 Digital Link validation (ex: https://brand.com/01/21215242352340/10/UV2307?17=210710)
/*
* https://digital-link.com/gs1-digital-link/
* URI structure
A GS1 digital link URI is a web address formatted to contain a product’s unique GS1 identifier (like a GTIN number). The URI structure connects physical objects to online digital identities.

The URI syntax follows a standardized structure defined in the GS1 digital link specifications:

Domain – The brand’s or company’s owned web domain.
Primary ID Key – A GS1 Application Identifier (AI) indicating the type of identifier used, such as GTIN-13, GTIN-14, SSCC, etc.
Identifier – The actual product identification number based on the AI key. For example, the 12-digit UPC.
Qualifiers – Optional additional IDs such as batch number, serial number, etc.
Attributes – Optional data points like weight, dimensions, and expiration dates.

When encoded and scanned, the URI enables the lookup of the product’s digital identity and associated information.
* */
const gs1DigitalLinkRegex = /\/01\/(\d{14})\/10\/(\w{1,20})\?17=(\d{6})/;

window.onload = () => {
    try {
        let urlParts = location.href.split(location.origin)[1].split("/").filter(function (item) {
            return item !== "";
        })

        let pageWithQuery = urlParts[urlParts.length - 1].split("?");
        let page = pageWithQuery[0];
        let query = pageWithQuery[1]

        if (appPages.indexOf(page) === -1) {
            validateAndRedirect(constructUrl("main.html"));
        } else {
            validateAndRedirect(constructUrl(page, query));
        }

    } catch (e) {
        goTo404ErrPage()
    }
}

function getGS1Url() {
    let gs1Url;
    let gs1Split = document.referrer.split(window.location.origin);
    if (gs1Split && gs1Split[1] && gs1DigitalLinkRegex.test(gs1Split[1])) {
        const matchesArr = gs1Split[1].match(gs1DigitalLinkRegex);
        const gtin = matchesArr[1];
        const batchNumber = matchesArr[2];
        const expiry = matchesArr[3];
        gs1Url = `/leaflet.html?gtin=${gtin}&batch=${batchNumber}&expiry=${expiry}`;
    }
    return gs1Url;
}

function goTo404ErrPage() {
    let pageUrl = "/404.html";
    let err404Page = `/app${pageUrl}`;
    if (environment.enableRootVersion) {
        err404Page = `/${environment.appBuildVersion}${pageUrl}`;
    }
    window.location.href = window.location.origin + err404Page;
}

function constructUrl(page, query) {
    let gs1Url = getGS1Url();

    if (gs1Url) {
        return `${window.location.origin}/${environment.appBuildVersion}${gs1Url}`;
    }

    return query ? `${window.location.origin}/${environment.appBuildVersion}/${page}?${query}` : `${window.location.origin}/${environment.appBuildVersion}/${page}`
}

function validateAndRedirect(url) {
    if (url.startsWith(`${window.location.origin}/${environment.appBuildVersion}`)) {
        window.location.href = url;
    } else {
        throw new Error("Invalid or potentially harmful URL.")
    }
}
