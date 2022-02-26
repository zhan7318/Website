{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem
    (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          lib = nixpkgs.lib;
      in {
        devShell = pkgs.mkShell {
          buildInputs =
            (with pkgs;
              [ zola ]) ++
            (with pkgs.nodePackages;
              [ vscode-css-languageserver-bin vscode-html-languageserver-bin ]);
        };
        packages = rec {
          site = pkgs.stdenvNoCC.mkDerivation {
            name = "site";
            src = pkgs.nix-gitignore.gitignoreSource [] ./.;

            buildInputs = with pkgs; [ zola ];
            phases = [ "unpackPhase" "buildPhase" ];
            buildPhase = ''
              echo \"${self.shortRev or "HEAD"}\" >rev.json
              zola build -o $out
            '';
          };
        };
      });
}
