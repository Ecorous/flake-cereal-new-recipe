/** @type {boolean} */
let real_external = false;

/** @type {HTMLInputElement} */
let switchElem;

function js_load() {
    let external = window.localStorage.getItem("use_external");
    console.log(external)
    if (external == "true" || external == true) {
        real_external = true;
        window.localStorage.setItem("use_external", real_external);
    }
    if (external == null) {
        real_external = false;
        window.localStorage.setItem("use_external", real_external);
    }
    real_external = (external == "true" || external == true);
    switchElem = document.getElementById("switch");
    switchElem.value = real_external;
    switchElem.checked = real_external;

    let links = document.getElementsByClassName("link");
    for (let i = 0; i < links.length; i++) {
        let link = links[i];
        if (real_external) {
            let currentHref = link.getAttribute("href");
            link.setAttribute("href", currentHref.replaceAll(".int", ".ext"));
        } else {
            let currentHref = link.getAttribute("href");
            link.setAttribute("href", currentHref.replaceAll(".ext", ".int"));
        }
    }
}

function switchClick() {
    console.log(`what is this? ${real_external}, ${switchElem.checked}, ${window.localStorage.getItem("use_external")}`);
    real_external = switchElem.checked;
    window.localStorage.setItem("use_external", real_external);
    switchElem.checked = real_external;
    console.log(`it is this: ${real_external}, ${switchElem.checked}, ${window.localStorage.getItem("use_external")}`);
    js_load();
}