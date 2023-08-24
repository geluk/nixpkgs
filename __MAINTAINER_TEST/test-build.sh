export NIXPKGS=$PWD
nix-build $NIXPKGS -A python3.pkgs.ansible-pylibssh
