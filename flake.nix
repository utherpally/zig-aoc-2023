{
  description = "Zig development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    zig.url = "github:utherpally/zig-overlay";
    zig.inputs.nixpkgs.follows = "nixpkgs";
    zig.inputs.flake-utils.follows = "flake-utils";

    zls.url = "github:zigtools/zls";
    zls.inputs.nixpkgs.follows = "nixpkgs";
    zls.inputs.zig-overlay.follows = "zig";
    zls.inputs.flake-utils.follows = "flake-utils";
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlay = _: prev: {
          zig = inputs.zig.packages.${system}.master;
          zls = inputs.zls.packages.${system}.default;
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            zig
            clang
            gdb
            valgrind
            zls
            poop
          ];
          # PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig"
          # LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (with pkgs;[SDL2 SDL2_image stdenv.cc.cc.lib])}";
        };
      }
    );
}
