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
  ];

  packageVersions = pkgs.lib.concatMapStringsSep "\n"
    (package:
      "echo \"${package.pname or package.name}|${package.version}\""
    )
    packages;

  show-env = pkgs.writeShellScriptBin "show-env" ''
    header=$(gum format -t template '{{ Background "250" (Bold "ork-o-scope.nvim") }}{{ Background "250" " development environment:" }}')
    table=$(
      {
        ${packageVersions}
      } | gum table --separator "|" --columns "Package,Version" --print
    )
    gum join --vertical --align="left" "$header" "$table"
  '';
in
pkgs.mkShell {
  buildInputs = packages ++ [ show-env ];

  shellHook = ''
    show-env
    echo "Run 'show-env' to display this information again"
  '';
}
