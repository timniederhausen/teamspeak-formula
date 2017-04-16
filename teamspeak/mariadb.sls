{% from 'teamspeak/map.jinja' import teamspeak with context %}

mariadb_package:
  pkg.installed:
    - name: mariadbconnector-c

teamspeak_mariadb_ini:
  file.managed:
    - name: {{ teamspeak.directory }}/ts3db_mariadb.ini
    - source: salt://teamspeak/files/ts3server.ini
    - template: jinja
    - mode: 640
    - defaults:
        options: {{ teamspeak.mariadb_options | yaml }}
        section: config
    - require:
      - cmd: teamspeak_archive
      - pkg: mariadb_package
    - require_in:
      - service: teamspeak_service
