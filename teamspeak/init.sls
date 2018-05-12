{% from 'teamspeak/map.jinja' import teamspeak with context %}
{% from 'teamspeak/macros.jinja' import sls_block with context %}

teamspeak_user:
  user.present:
    - name: {{ teamspeak.user }}

teamspeak_group:
  group.present:
    - name: {{ teamspeak.group }}

teamspeak_directory:
  file.directory:
    - name: {{ teamspeak.directory }}
    - user: {{ teamspeak.user }}
    - group: {{ teamspeak.group }}
    - require:
      - user: teamspeak_user
      - group: teamspeak_group

teamspeak_archive:
  file.managed:
    - name: {{ teamspeak.directory }}/archive.tgz
    - user: {{ teamspeak.user }}
    - group: {{ teamspeak.group }}
    - require:
      - file: teamspeak_directory
    {{ sls_block(teamspeak.archive) | indent(4) }}

  cmd.run:
    - name: tar xf archive.tgz --strip-components=1
    - runas: {{ teamspeak.user }}
    - cwd: {{ teamspeak.directory }}
    - onchanges:
      - file: teamspeak_archive

teamspeak_ini:
  file.managed:
    - name: {{ teamspeak.directory }}/ts3server.ini
    - source: salt://teamspeak/files/ts3server.ini
    - template: jinja
    - mode: 640
    - defaults:
        options: {{ teamspeak.ini_options | yaml }}
    - require:
      - cmd: teamspeak_archive

{% if teamspeak.license is defined %}
teamspeak_license:
    file.managed:
      - name: {{ teamspeak.directory }}/licensekey.dat
      - user: {{ teamspeak.user }}
      - group: {{ teamspeak.group }}
      - mode: 600
      - contents_pillar: teamspeak:license
{% endif %}

{% if teamspeak.import_sqlitedb %}
teamspeak_sqlitedb:
  file.managed:
    - name: {{ teamspeak.directory }}/ts3server.sqlitedb
    - user: {{ teamspeak.user }}
    - group: {{ teamspeak.group }}
    - source: salt://teamspeak/files/ts3server.sqlitedb
    - mode: 640
    - require:
        - cmd: teamspeak_archive
{% endif %}

{% if grains.os_family == 'FreeBSD' %}
teamspeak_init_script:
  file.managed:
    - name: /usr/local/etc/rc.d/teamspeak
    - source: salt://teamspeak/files/teamspeak-rc.sh
    - template: jinja
    - mode: 755
    - defaults:
        directory: {{ teamspeak.directory | yaml_encode }}
        user: {{ teamspeak.user | yaml_encode }}
        executable: {{ teamspeak.executable | yaml_encode }}
    - require:
      - file: teamspeak_ini

teamspeak_service:
  service.running:
    - name: teamspeak
    - enable: true
    - require:
      - cmd: teamspeak_archive
{% if teamspeak.enable_master %}
      - service: teamspeak_master_service
{% endif %}
{% else %}
{% if grains['systemd'] %}
teamspeak_service_config:
  file.managed:
    - name: /etc/systemd/system/teamspeak.service
    - source: salt://teamspeak/files/teamspeak.service
    - template: jinja
    - mode: 755
    - defaults:
        directory: {{ teamspeak.directory | yaml_encode }}
        user: {{ teamspeak.user | yaml_encode }}
        group: {{ teamspeak.group | yaml_encode }}
        executable: {{ teamspeak.executable | yaml_encode }}
    - require:
      - file: teamspeak_ini

teamspeak_service:
  service.running:
    - name: teamspeak
    - enable: true
    - require:
      - cmd: teamspeak_archive
{% if teamspeak.enable_master %}
      - service: teamspeak_master_service
{% endif %}
{% endif %}
{% endif %}

{% if teamspeak.enable_master or teamspeak.enable_dns %}
include:
{% if teamspeak.enable_master %}
  - teamspeak.master
{% endif %}
{% if teamspeak.enable_dns %}
  - teamspeak.dns
{% endif %}
{% endif %}
