{
  description = "A Nix-flake-based Go 1.22 development environment";

  inputs = {
      nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
      flake-utils.url = "github:numtide/flake-utils";
      dagger.url = "github:dagger/nix";
      dagger.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, dagger }:
    flake-utils.lib.eachDefaultSystem (system:
      let
	pkgs = import nixpkgs {inherit system; };
      in {
	devShells.default = pkgs.mkShell {
	  shellHook = ''
	    # Setup 'k' as a 'kubectl' alias
	    source <(kubectl completion bash)

	    alias k=kubectl
	    complete -o default -F __start_kubectl k
	  '';
	  COLORTERM = "truecolor";

	  buildInputs = [
	    dagger.packages.${system}.dagger

	    pkgs.go
	    pkgs.gotools
	    pkgs.golangci-lint
	    pkgs.kubernetes-helm
	    pkgs.kubebuilder

	    pkgs.kind
	    pkgs.jq
	    pkgs.kubectl
	  ];

	  packages = [
	    pkgs.gopls
	    pkgs.go-task

	    pkgs.protobuf
	    pkgs.protoc-gen-go
	    pkgs.protoc-gen-doc

	    pkgs.protobuf
	    pkgs.protoc-gen-go
	    pkgs.protoc-gen-doc
	 ];
	};
      });

}
