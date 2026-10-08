---
layout: page
permalink: /
tagline: Complex Plasma Facility for Microgravity Research
description: COMPACT -- Multi-user facility for investigating complex (dusty) plasmas under microgravity conditions aboard a space station
author: COMPACT-for-space contributors, Andre Melzer
---
# COMPACT

COMPACT (**Com**plex **P**l**a**sma Fa**c**ili**t**y) is a multi-user facility for the investigation of complex (dusty) plasmas under microgravity conditions aboard a space station.

<img src="{{ 'assets/images/compact_locker_progress_meeting3B_anno.png' | relative_url }}" width="600">

[COMPACT](https://doi.org/10.1088/1361-6587/ac9ff0) will feature large, extended three-dimensional dust clouds under nearly stress-free conditions and will be equipped with a whole suite of [diagnostic and manipulation devices][sec:documentation].

[Scientific questions][sec:science_mission] of this project include:
* Statistical physics of many-body systems
* Active and non-spherical particles
* Phase transitions and glass phases
* Nonlinear dynamics and turbulence
* Planetary physics
* Particles as diagnostics in plasmas

Science team core members (incl. official Science Definition Team) ([list as json]({{ 'science_team.json' | relative_url }})):

| Name | Affiliation | Role | ORCID | ROR |
|---|---|---|---|
{% for m in site.data.science_team %}| {{ m.name }} | {{ m.affiliation }} | {{ m.role }} | [{{ m.orcid }}](https://orcid.org/{{ m.orcid }}) | {% if m.ror %}[{{ m.ror }}](https://ror.org/{{ m.ror | replace: 'https://ror.org/', '' }}){% else %}—{% endif %} |
{% endfor %}

COMPACT is an international project funded by the German Space Agency DLR with support from ESA, NASA and NSF.

[sec:documentation]:/realization-design/
[sec:science_mission]:/science-mission/
