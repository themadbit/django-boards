let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.05";
  pkgs = import nixpkgs {
    config = { };
    overlays = [ ];
  };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    python313
    python313Packages.django
    python313Packages.django-widget-tweaks
    python313Packages.markdown
  ];
  shellHook = ''
    echo "The shell is loaded with aliases for easier dev:"

    alias manage="python3 manage.py"
    alias migrate="python3 manage.py migrate"
    alias runserver="python3 manage.py runserver"

  '';
}
