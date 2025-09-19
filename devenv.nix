{ pkgs, ... }:

{
  languages.python = {
    enable = true;
    venv.enable = true;
    venv.requirements = ''
      Django
      django-widget-tweaks
      Markdown
      python-decouple
      gunicorn
    '';
  };
}
