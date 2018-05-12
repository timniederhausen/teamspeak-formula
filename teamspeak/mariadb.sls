{% from 'teamspeak/map.jinja' import teamspeak with context %}

{% if grains.os_family == 'FreeBSD' %}
# TODO: make this more dynamic
mariadb_package:
  pkg.installed:
    - sources:
      - 'mariadbconnector-c': http://pkg.freebsd.org/FreeBSD:11:amd64/release_1/All/mariadbconnector-c-2.3.2.txz
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
