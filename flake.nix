{
  description = "A Nix-flake-based Go 1.22 development environment";

  inputs = {
      nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
      flake-utils.url = "github:numtide/flake-utils";
      dagger.url = "github:dagger/nix";
      dagger.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, dagger }:
    let
      goVersion = 22; # Change this to update the whole stack

      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      });
    in
    {
      overlays.default = final: prev: {
        go = final."go_1_${toString goVersion}";
      };

      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          shellHook = ''
            # Setup 'k' as a 'kubectl' alias
            source <(kubectl completion bash)

            alias k=kubectl
            complete -o default -F __start_kubectl k
          '';
          COLORTERM = "truecolor";
          packages = with pkgs; [
            go
            gotools
            golangci-lint

            kind
            jq
            kubernetes-helm
            kubectl
            golangci-lint
            gopls
 
            protobuf
            protoc-gen-go
            protoc-gen-doc

            go-task
          ];
        };
      });
    };
}
