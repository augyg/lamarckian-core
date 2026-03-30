{ system ? builtins.currentSystem
, obelisk ? import ../jenga/.obelisk/impl {
    inherit system;
    config.allowBroken = true;
  }
}:
let
  pkgs = obelisk.nixpkgs;
  thunkSet = pkgs.thunkSet ../jenga/thunks;
  hackGet = pkgs.hackGet;
  haskellLib = pkgs.haskell.lib;

  haskellPackages = obelisk.reflex-platform.ghc.override {
    overrides = self: super: with haskellLib; {
      IStr = super.callPackage thunkSet.IStr {};
      scrappy-core = super.callPackage thunkSet.scrappy-core {};
      scrappy-template = self.callCabal2nix "scrappy-template" ../scrappy-template {};
      mmark-ext = self.callCabal2nix "mmark-ext" (hackGet thunkSet.mmark-ext) {};
      skylighting = dontHaddock (self.callHackage "skylighting" "0.10.2" {});
      skylighting-core = dontHaddock (self.callHackage "skylighting-core" "0.10.2" {});
      ghc-syntax-highlighter = dontHaddock (self.callHackage "ghc-syntax-highlighter" "0.0.6.0" {});
      lamarckian-core = self.callCabal2nix "lamarckian-core" ./. {};
    };
  };
in
pkgs.mkShell {
  buildInputs = [ pkgs.cabal-install ];
  inputsFrom = [ (if pkgs.lib.inNixShell then haskellPackages.lamarckian-core.env else haskellPackages.lamarckian-core) ];
}
