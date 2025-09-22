{ ... }:

{
  languages.python = {
    enable = true;
    venv.enable = true;
    venv.requirements = ''
      Django
      django-widget-tweaks
      Markdown
      python-decouple
      dj_database_url
      gunicorn
      psycopg2-binary
    '';
  };
}
