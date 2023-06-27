{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  boring = buildGoModule rec {
    pname = "boring";
    version = "1.1.0";
    src = fetchFromGitHub {
      owner = "qbit";
      repo = "boring";
      rev = "v${version}";
      hash = "sha256-aXeOSU6TJKh2oWd7F+huCy0mz/KyLgUgQyyG8BnKFG0=";
    };

    vendorHash = "sha256-bOCbvybn5DtQEhVxoDWmZWxPvMTgSFbuYyJitlSgtBI=";
  };
  in pkgs.mkShell {
  shellHook = ''
    export PS1='\u@\h:\w$ '
    export NO_COLOR=1
  '';
  nativeBuildInputs = with pkgs; [
    bmake
    gnupg
    outils

    boring
  ];
}
