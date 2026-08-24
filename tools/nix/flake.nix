{
  # here we define a dictionary
  description = "Clang development environment";

  # shortcut for {inputs = {nixpkgs = {url = ...}}}
  # use nix packages defined at release 26.05
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  # outputs is a function of 2 arguments: self & nixpkgs
  outputs = { self, nixpkgs }:
    let
      # variables
      system = "aarch64-darwin";
      # pkgs is all packages for the specified system
      pkgs = import nixpkgs { inherit system; };
    in
    # we return a dictionary from this function
    {
      # ${system} is a string interpolation
      # devShells allows us to support `nix develop`
      # here we start a shell with the clang_22 package
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.clang_22
        ];
      };
    };
}