#!jinja|yaml

{% from "softether/map.jinja" import datamap %}

{% if salt['grains.get']('os_family') == 'Debian' %}

{%- if datamap.interface.enabled %}

vpnclient_interface:
  network:
    - managed
    - noifupdown: True
    - enabled: False
    - proto: static
    - type: eth
    - name: {{ datamap.interface.name }}
    - ipaddr: {{ datamap.interface.ipv4address }}
    - netmask: {{ datamap.interface.ipv4netmask }}
{% if datamap.interface.ipv6enabled %}
    - enable_ipv6: True
    - ipv6proto: static
    - ipv6ipaddr: {{ datamap.interface.ipv6address }}
    - ipv6netmask: {{ datamap.interface.ipv6netmask }}
{% endif %}

{% endif %}

{%- endif %}
