// script that can click on a menu item in yt's three-dot meny
// example usage: js/yt-click-menu.js@Don't recommend channel

(async () => {
    const label = JS_ARGS.join(" ");
    const tiles = "yt-lockup-view-model";
    const menuButton = ".ytLockupMetadataViewModelMenuButton button";
    const menuEntries = "tp-yt-iron-dropdown yt-list-item-view-model";
    const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

    // find menu item
    const find = () =>
        [...document.querySelectorAll(menuEntries)].find(
            entry =>
                entry.offsetParent !== null &&
                entry.textContent.trim() === label,
        );

    // wait until menu shows
    const wait = async () => {
        for (let attempt = 0; attempt < 20; attempt++) {
            const entry = find();
            if (entry) return entry;
            await sleep(50);
        }

        return null;
    };

    const hinted = await tri.excmds.hint("-Jc", tiles, "-F", "e => e");

    if (!hinted) return;

    const button = hinted.closest(tiles).querySelector(menuButton);

    if (!button) return;

    button.click();

    const entry = await wait();

    if (!entry) {
        button.click();
        tri.excmds.fillcmdline_nofocus(`"${label}" not available`);
        return;
    }

    (entry.querySelector("button") ?? entry).click();
})();
