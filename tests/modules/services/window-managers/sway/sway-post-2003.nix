{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    home.stateVersion = "20.09";

    wayland.windowManager.sway = {
      enable = true;
      package = pkgs.runCommandLocal "dummy-package" { } "mkdir $out" // {
        outPath = "@sway";
      };
      # overriding findutils causes issues
      config.menu = "${pkgs.dmenu}/bin/dmenu_run";
    };

    nixpkgs.overlays = [
      (self: super: {
        dummy-package = super.runCommandLocal "dummy-package" { } "mkdir $out";
        dmenu = self.dummy-package // { outPath = "@dmenu@"; };
        rxvt-unicode-unwrapped = self.dummy-package // {
          outPath = "@rxvt-unicode-unwrapped@";
        };
        i3status = self.dummy-package // { outPath = "@i3status@"; };
      })
    ];

    nmt.script = ''
      assertFileExists home-files/.config/sway/config
      assertFileContent home-files/.config/sway/config \
        ${./sway-default.conf}
    '';
  };
}
