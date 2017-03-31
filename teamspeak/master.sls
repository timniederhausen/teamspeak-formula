{% from 'teamspeak/map.jinja' import teamspeak with context %}

teamspeak_master_init_script:
  file.managed:
    - name: /usr/local/etc/rc.d/teamspeak_master
    - source: salt://teamspeak/files/teamspeak_master-rc.sh
    - template: jinja
    - mode: 755
    - defaults:
        directory: {{ teamspeak.directory | yaml_encode }}
        user: {{ teamspeak.user | yaml_encode }}
        executable: {{ teamspeak.master_executable | yaml_encode }}
    - require:
      - cmd: teamspeak_archive

teamspeak_master_service:
  service.running:
    - name: teamspeak_master
    - enable: true
    - require:
      - cmd: teamspeak_archive
