{% from 'teamspeak/map.jinja' import teamspeak with context %}

teamspeak_dns_init_script:
  file.managed:
    - name: /usr/local/etc/rc.d/teamspeak_dns
    - source: salt://teamspeak/files/teamspeak_dns-rc.sh
    - template: jinja
    - mode: 755
    - defaults:
        directory: {{ teamspeak.directory }}/tsdns
        user: {{ teamspeak.dns_user }}
        executable: {{ teamspeak.dns_executable | yaml_encode }}
    - require:
      - cmd: teamspeak_archive

teamspeak_tsdns_ini:
  file.managed:
    - name: {{ teamspeak.directory }}/tsdns/tsdns_settings.ini
    - source: salt://teamspeak/files/ts3server.ini
    - template: jinja
    - mode: 640
    - defaults:
        options: {{ teamspeak.tsdns_ini_options | yaml }}

teamspeak_tsdns_json:
  file.serialize:
    - name: {{ teamspeak.directory }}/tsdns/tsdns_settings.json
    - dataset: {{ teamspeak.tsdns_ini_options | yaml }}
    - formatter: json

teamspeak_dns_service:
  service.running:
    - name: teamspeak_dns
    - enable: true
