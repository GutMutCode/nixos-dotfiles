{ config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    hypr = "hypr";
    waybar = "waybar";
    fcitx5 = "fcitx5";
    wallust = "wallust";
    rofi = "rofi";
    nvim = "nvim";
    mako = "mako";
  };
in
{
  xdg.configFile = (builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs);

  # MIME type associations for default applications
  # Works with Thunar file manager
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Image files
      "image/bmp" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/jpeg" = "imv.desktop";
      "image/jpg" = "imv.desktop";
      "image/png" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/avif" = "imv.desktop";
      "image/heif" = "imv.desktop";

      # Video files
      "video/mp4" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/x-flv" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/x-ms-wmv" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/mkv" = "mpv.desktop";

      # Audio files
      "audio/mpeg" = "mpv.desktop";
      "audio/mp3" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/opus" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/x-wav" = "mpv.desktop";
      "audio/aac" = "mpv.desktop";
      "audio/m4a" = "mpv.desktop";
    };
  };

  home.file."Pictures/wallpapers" = {
    source = create_symlink "${dotfiles}/wallpapers";
    recursive = true;
  };
}
