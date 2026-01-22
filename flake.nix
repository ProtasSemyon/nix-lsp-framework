{
  description = "C++ Project with lsp-framework overlay";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      lspOverlay = final: prev: {
        lsp-framework = final.callPackage prev.stdenv.mkDerivation rec {
          pname = "lsp-framework";
          version = "1.3.1";

          src = prev.fetchFromGitHub {
            owner = "ProtasSemyon";
            repo = "lsp-framework";
            rev = "${version}";
            hash = "sha256-LLHclj1JbQG+N10kyZq6PQMmdTujARxdA6kjjV/QWLg=";
          };

          nativeBuildInputs = [ prev.cmake ];

          cmakeFlags = [ "-DLSP_INSTALL=ON" ];
        };
      };
    in
    {
      overlays.default = lspOverlay;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ lspOverlay ];
        };
      in
      {
        packages.default = pkgs.lsp-framework;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.cmake ];
          buildInputs = [ pkgs.lsp-framework ];
        };
      }
    );
}
