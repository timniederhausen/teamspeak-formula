{% from 'teamspeak/map.jinja' import teamspeak with context %}

{% if grains.os_family == 'FreeBSD' %}
mariadb_package:
  pkg.installed:
    - name: mariadb-connector-c

/usr/local/lib/mariadb/libmariadb.so.2:
  file.symlink:
    - target: /usr/local/lib/mariadb/libmariadb.so.3
    - require:
      - mariadb_package
    - require_in:
      - teamspeak_mariadb_ini
{% endif %}

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
