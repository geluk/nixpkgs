# To test:
# ```bash
# nix-shell
# import pylibsshext
# import expandvars
# expandvars.expandvars("$SHELL")
# ```


{ pkgs ? import ../. {} }:

pkgs.mkShell {
    packages = [ (pkgs.python3.withPackages (ps: [ps.ansible-pylibssh])) ];
}
