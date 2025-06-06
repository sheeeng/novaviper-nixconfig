# Shell for bootstrapping flake-enabled nix and other tooling
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
{
  pkgs ?
    # If pkgs is not defined, instantiate nixpkgs from locked commit
    let
      lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
      nixpkgs = fetchTarball {
        url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
        sha256 = lock.narHash;
      };
    in
    import nixpkgs { },
  checks,
  ...
}:
let
  checks-lib = checks.${pkgs.system};
in
{
  default = pkgs.mkShell {
    FLAKE = ".";
    NH_FLAKE = ".";
    NIX_CONFIG = "use-xdg-base-directories = true\nextra-experimental-features = nix-command flakes";
    PKCS = "${pkgs.opensc}/lib/opensc-pkcs11.so";
    buildInputs = checks-lib.pre-commit-check.enabledPackages;
    nativeBuildInputs = with pkgs; [
      # Nix toolkit
      nix
      nix-output-monitor
      nix-inspect
      deadnix
      statix
      home-manager

      # Encryption tools/Secrets bootstrapping
      gnupg
      openssh
      vim # Needed for age/sops
      sops # This one is from the overlay
      ssh-to-age
      age-plugin-fido2-hmac
      age-plugin-yubikey
      age-plugin-tpm
      age-plugin-ledger

      # Git setup
      gitFull
      git-extras
      tig
      just
      git-credential-oauth
      git-crypt
      pre-commit
    ];
    shellHook = ''
      ${checks-lib.pre-commit-check.shellHook}
        export EDITOR=vim
    '';
  };
}
