{ pkgs ? import <nixpkgs> { } }:

let
  packages = with pkgs; [
    neovim
    lua-language-server
    stylua
    lua54Packages.luacheck
    nodePackages.markdownlint-cli
    python3Packages.pyspelling
    nixpkgs-fmt
    lefthook
    gum
    cocogitto
  ];
in
pkgs.mkShell {
  buildInputs = packages;

  shellHook = ''
    echo "Run 'show-env' to display this information again"
  '';
}
