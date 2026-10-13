// permissions and requests {{{
// block autoplay videos
user_pref("media.autoplay.default", 5);
// don't allow notifications
user_pref("permissions.default.desktop-notification", 2);
// don't allow geo-location
user_pref("permissions.default.geo", 2);
// show other sites only the domain you come from
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);
// }}}

// privacy {{{
// strict tracking protection: partitions cookies, blocks known trackers
user_pref("browser.contentblocking.category", "strict");
// all fingerprinting defences, except hiding the dark-mode preference
user_pref("privacy.fingerprintingProtection", true);
user_pref(
    "privacy.fingerprintingProtection.overrides",
    "+AllTargets,-CSSPrefersColorScheme,-RoundWindowSize"
);
// send the global privacy control signal
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("dom.security.https_only_mode", true);
// same in private windows
user_pref("dom.security.https_only_mode_pbm", true);
// no dns lookups or connections for links that were not clicked
user_pref("network.dns.disablePrefetch", true);
user_pref("network.prefetch-next", false);
user_pref("network.http.speculative-parallel-limit", 0);
// don't send typed address-bar text to mozilla
user_pref("browser.urlbar.quicksuggest.dataCollection.enabled", false);
// no personalized add-on recommendations
user_pref("browser.discovery.enabled", false);
// }}}

// clearing on shutdown {{{
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.clearOnShutdown_v2.formdata", true);
// keep history and the downloads list
user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false);
// }}}

// passwords and forms {{{
// the password manager handles these, firefox stores nothing
user_pref("signon.rememberSignons", false);
user_pref("signon.autofillForms", false);
user_pref("browser.formfill.enable", false);
// }}}

// ai features {{{
// applies to ai features not listed below
user_pref("browser.ai.control.default", "blocked");
user_pref("browser.ai.control.linkPreviewKeyPoints", "blocked");
user_pref("browser.ai.control.pdfjsAltText", "blocked");
user_pref("browser.ai.control.sidebarChatbot", "blocked");
user_pref("browser.ai.control.smartTabGroups", "blocked");
user_pref("browser.ai.control.translations", "available");
// }}}

// tabs and startup {{{
// restore the previous session
user_pref("browser.startup.page", 3);
// switch to a tab opened from a link right away
user_pref("browser.tabs.loadInBackground", false);
user_pref("browser.tabs.hoverPreview.showThumbnails", false);
user_pref("browser.ctrlTab.sortByRecentlyUsed", true);
// }}}

// scrolling {{{
user_pref("general.smoothScroll", false);
// no middle-click scroll mode
user_pref("general.autoScroll", false);
// no rubber-band bounce at page edges
user_pref("apz.overscroll.enabled", false);
// }}}

// new tab page {{{
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.widgets.weather.enabled", false);
// }}}

// reading and language {{{
user_pref("reader.font_type", "serif");
user_pref("intl.locale.requested", "en-US");
// prefer japanese glyphs for characters shared between cjk languages
user_pref("font.cjk_pref_fallback_order", "ja,zh-hk,zh-tw,ko,zh-cn");
// }}}

// misc {{{
// always ask where to save downloads
user_pref("browser.download.useDownloadDir", false);
// sites can't move or resize windows
user_pref("dom.disable_window_move_resize", true);
// no automatic translation offer
user_pref("browser.translations.automaticallyPopup", false);
// fullscreen videos just take the browser window
user_pref("full-screen-api.ignore-widgets", true);
// }}}

// vim: set foldmethod=marker foldlevel=0:
