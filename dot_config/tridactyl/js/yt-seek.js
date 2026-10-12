{
    const seconds = parseInt(JS_ARGS[0], 10);
    const script = document.createElement("script");
    script.textContent =
        `document.querySelector("#movie_player").seekBy(${seconds})`;
    document.head.appendChild(script);
    script.remove();
}
