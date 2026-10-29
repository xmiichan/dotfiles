(async () => {
    const host = location.hostname;
    const labels = host.split(".");
    const name = labels[Math.max(labels.length - 2, 0)];
    const command = "open " + location.href;
    const registrable = labels.slice(-2).join(".");
    const start = command.indexOf(host) + host.length - registrable.length;

    await tri.excmds.fillcmdline_notrail(command);

    document
        .getElementById("cmdline_iframe")
        .contentWindow.document.getElementById("tridactyl-input")
        .setSelectionRange(start, start + name.length);
})();
