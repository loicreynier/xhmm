{ config, lib, ... }:
let
  mkFontOption = desc:
    lib.mkOption {
      type = lib.types.nullOr lib.hm.types.fontType;
      default = null;
      description = desc;
    };
  possiblyFontName = font:
    lib.mkIf (font != null) (font.name
      + (if font.size != null then " ${builtins.toString font.size}" else ""));
  optionalFontPkg = font:
    if font != null && font.package != null then [ font.package ] else [ ];
in {
  options.gnome = {
    font =
      mkFontOption "The font used by default in GNOME and GTK applications";
    monospaceFont =
      mkFontOption "The monospace font to use in GNOME and GTK applications.";
    documentFont = mkFontOption "The font used to display documents by default";
    legacyTitlebarFont =
      mkFontOption "The font used in legacy applications’ window titles";
  };
  config = let cfg = config.gnome;
  in {
    dconf.settings = lib.mkIf (cfg.font != null || cfg.monospaceFont != null
      || cfg.documentFont != null || cfg.legacyTitlebarFont != null) {
        "org/gnome/desktop/interface" = {
          font-name = possiblyFontName cfg.font;
          monospace-font-name = possiblyFontName cfg.monospaceFont;
          document-font-name = possiblyFontName cfg.legacyTitlebarFont;
        };
        "org/gnome/desktop/wm/preferences".titlebar-font =
          possiblyFontName cfg.legacyTitlebarFont;
      };
    fonts.fonts = lib.concatLists (map optionalFontPkg
      (with cfg; [ font monospaceFont documentFont legacyTitlebarFont ]));
  };
}
