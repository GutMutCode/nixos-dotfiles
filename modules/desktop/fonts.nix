{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      maple-mono.NF-CN-unhinted
      nerd-fonts.jetbrains-mono
      nerd-fonts.d2coding
    ];
  };
}
