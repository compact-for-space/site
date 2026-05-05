---
layout: page
title: publications
permalink: /publications/
---

<ul>
{% for pub in site.data.publications | sort: 'year', 'reverse' %}
<li>
<strong>{{ pub.year }}</strong>: {{ pub.authors }}. {{ pub.title }}. 
{% if pub.doi %}
  <a href="https://doi.org/{{ pub.doi }}" target="_blank" rel="noopener">
DOI: {{ pub.doi }}
</a>.
{% elsif pub.url %}
  <a href="{{ pub.url }}">pub.url</a>.
{% endif %}
</li>
{% endfor %}
</ul>
