{
  description = "C++ Project with lsp-framework overlay";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        lspOverlay = final: prev: {
          lsp-framework = final.callPackage prev.stdenv.mkDerivation rec {
            pname = "lsp-framework";
            version = "1.3.0";

            src = prev.fetchFromGitHub {
              owner = "leon-bckl";
              repo = "lsp-framework";
              rev = "${version}";
              hash = "sha256-ajYsCUDx1h93uCYbBv1TKvHpJJbXSj4bqhWyJ1vM9N0="; 
            };

            nativeBuildInputs = [ prev.cmake ];

            cmakeFlags = [ "-DLSP_INSTALL=ON" ];
          };
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ lspOverlay ];
        };

      in
      {
        overlays.default = lspOverlay;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.cmake ];
          buildInputs = [ pkgs.lsp-framework ];
        };
      }
    );
}
