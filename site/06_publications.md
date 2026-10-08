---
layout: page
permalink: /publications/
title: publications
description: "A comprehensive list of scientific publications and research contributions regarding COMPACT and complex plasma physics. Advancing our understanding of complex plasmas using microgravity."
author: Daniel Mohr
license: CC0
---

[publication list as json]({{ 'publications.json' | relative_url }})

{% assign all_entries = "" %}
{% for pub in site.data.publications %}
  {% assign doi_meta = site.data.doi_cache[pub.doi] %}
  {% assign pub_date = pub.date | default: doi_meta.date %}
  {% assign pub_authors = pub.authors | default: doi_meta.author %}

  {% if pub_authors == blank %}
    {% assign authors_string = "Unknown Authors" %}
  {% elsif pub_authors.size == nil %}
    {% assign authors_string = pub_authors.given | default: "" | append: " " | append: pub_authors.family | default: "" | strip %}
    {% if authors_string == "" %}{% assign authors_string = pub_authors %}{% endif %}
  {% elsif pub_authors.size == 1 and pub_authors[0].family == nil %}
    {% assign authors_string = pub_authors[0] %}
  {% elsif pub_authors.size == 1 and pub_authors[0].family != nil %}
    {% assign authors_string = pub_authors[0].given | default: "" | append: " " | append: pub_authors[0].family | default: "" | strip %}
  {% else %}
    {% if pub_authors[0].family == nil %}
      {% assign authors_string = pub_authors %}
    {% else %}
      {% assign authors_string = "" %}
      {% for author in pub_authors %}
        {% assign full_name = author.given | default: "" | append: " " | append: author.family | default: "" | strip %}
        {% assign authors_string = authors_string | append: full_name %}
        {% unless forloop.last %}{% assign authors_string = authors_string | append: ", " %}{% endunless %}
      {% endfor %}
    {% endif %}
  {% endif %}

  {% capture entry %}
    {{ pub_date }}|{{ pub.title | default: doi_meta.title }}|{{ authors_string }}|{{ pub.doi }}|{{ pub.url }}
  {% endcapture %}
  {% assign all_entries = all_entries | append: entry | append: "###" %}
{% endfor %}

{% assign entries_array = all_entries | split: "###" | sort | reverse %}

<ul style="padding-left: 0;">
{% for entry in entries_array %}
  {% if entry == "" %}{% continue %}{% endif %}
  {% assign parts = entry | split: "|" %}
  {% assign raw_date = parts[0] %}
  {% assign title = parts[1] %}
  {% assign authors = parts[2] %}
  {% assign doi = parts[3] %}
  {% assign url = parts[4] %}

  {% if raw_date contains "-01-01" %}
    {% assign display_date = raw_date | slice: 0, 4 %}
  {% else %}
    {% assign display_date = raw_date %}
  {% endif %}

  <li style="margin-bottom: 1em;">
    <strong>{{ display_date | default: "n.d." }}</strong>:
    {{ authors }}.
    <span style="font-style: italic;">{{ title | default: "Untitled Document" }}</span>.
    {% if doi %}
      <a href="https://doi.org/{{ doi }}" target="_blank" rel="noopener">DOI: {{ doi }}</a>
    {% elsif url %}
      <a href="{{ url }}" target="_blank" rel="noopener">Link</a>
    {% endif %}
  </li>
{% endfor %}
</ul>

The publication list is dedicated to the public domain under
[CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).

Licensing for the content of individual publications is determined by their
respective rights holders and should be verified per work.
