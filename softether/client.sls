#!jinja|yaml

{% from "softether/map.jinja" import datamap %}

{%- if salt['grains.get']('os_family') == 'Debian' %}

{%- if datamap.interface.enabled %}
include:
  - softether.interface
{%- endif %}

vpnclient_default_file:
  file:
    - managed
    - name: {{ datamap.lookup.default_file }}
    - source: salt://softether/templates/default-file.jinja
    - template: jinja
    - user: root
    - group: root
    - mask: 0644
    - options:
      interface: {{ datamap.interface.name }}

{% if grains['os'] == 'Ubuntu' and grains['osrelease_info'][0] > 14 %}
vpnclient_systemd_start_script:
  file:
    - managed
    - name: /usr/local/bin/start-softether-vpnclient
    - source: salt://softether/files/systemd-start-script.sh
    - user: root
    - group: root
    - mask: 0755

vpnclient_systemd_script:
  file:
    - managed
    - name: {{ datamap.lookup.systemd_script }}
    - source: salt://softether/files/systemd-softether-vpnclient.service
    - user: root
    - group: root
    - mask: 0644
  cmd.run:
    - name: /bin/systemctl daemon-reload
    - watch:
      - file: vpnclient_systemd_script

{% elif grains['os'] == 'Ubuntu' %}
vpnclient_upstart_script:
  file:
    - managed
    - name: {{ datamap.lookup.upstart_script }}
    - source: salt://softether/templates/upstart-softether-vpnclient.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mask: 0644
    - options:
      interface: {{ datamap.interface.name }}
  cmd.run:
    - name: /sbin/initctl reload-configuration
    - watch:
      - file: vpnclient_upstart_script
{% endif %}

vpnclient:
  pkgrepo:
    - managed
    - humanname: paskal-07-ubuntu-softethervpn-trusty
    - name: deb http://ppa.launchpad.net/paskal-07/softethervpn/ubuntu trusty main
    - file: /etc/apt/sources.list.d/paskal-07-ubuntu-softethervpn-trusty.list
    - dist: trusty
    - keyid: 'A36194BE91291215'
    - keyserver: keyserver.ubuntu.com
    - refresh: True
  pkg:
    - installed
    - pkgs: {{ datamap.lookup.client_pkgs }}
    - require:
      - pkgrepo: vpnclient
  service:
    - {{ datamap.lookup.client_svc_state }}
    - name: {{ datamap.lookup.client_svc_name }}
    - enable: {{ datamap.lookup.client_svc_onboot }}
    - require:
{% if grains['os'] == 'Ubuntu' and grains['osrelease_info'][0] > 14 %}
      - file: vpnclient_systemd_script
{% elif grains['os'] == 'Ubuntu' %}
      - file: vpnclient_upstart_script
{% endif %}
      - file: vpnclient_default_file
      - file: vpnclient_upstart_script
      - pkg: vpnclient
      - network: vpnclient_interface
    - watch:
      - pkg: vpnclient

{%- endif %}
