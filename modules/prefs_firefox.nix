{ config, pkgs, ... }:

{
  programs.firefox = {
    languagePacks = [ "fr" ];
    preferences = {
      "browser.translations.automaticallyPopup" = false;
      "browser.startup.homepage" = "https://duckduckgo.com/";
      "intl.locale.requested" = "fr";
      "intl.accept_languages" = "fr-fr,fr";
      "spellchecker.dictionary" = "fr-FR";
      "spellchecker.dictionary_path" = "${pkgs.hunspellDicts.fr-any}/share/hunspell";
      "layout.spellcheckDefault" = 2;
    };  
    policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value= true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DontCheckDefaultBrowser = true;  
        SearchEngines = {
          Remove = [
            "eBay"
            "Google"
            "Bing"
            "Ecosia"
            "Wikipedia"
            "Perplexity"
          ];
          Add = [
            {
                "Name" = "DuckDuckGo";
                "URLTemplate" = "https://duckduckgo.com/?q={searchTerms}&ia=web&assist=false";
                "IconURL" = "https://duckduckgo.com/favicon.ico";
                "Alias" = "ddg";
                "Description" = "Duckduckgo sans IA";
            }
          ];
          Default = "DuckDuckGo";
        };   
    };
  };
}
