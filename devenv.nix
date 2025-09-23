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
      pre-commit
      gunicorn
      psycopg2-binary
    '';
  };
}
