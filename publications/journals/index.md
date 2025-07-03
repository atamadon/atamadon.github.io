---
layout: default
title: Journal Articles
---

# Journal Articles

<ul class="journal-list">
  {% assign journals = site.publications
     | where: "type", "journal"
     | sort: "date" | reverse %}
  {% for pub in journals %}
    <li>
      {% if pub.figure %}
        <img src="{{ pub.figure | relative_url }}"
             alt="Figure from {{ pub.title }}">
      {% endif %}
      <div>
        {% assign href = pub.external_url | default: pub.url %}
        <strong>
          <a href="{{ href }}" target="_blank" rel="noopener">
            {{ pub.title }}
          </a>
        </strong><br/>
        {% if pub.citation %}
          <em>{{ pub.citation }}</em><br/>
        {% endif %}
        <strong>Date:</strong> {{ pub.date | date: "%B %-d, %Y" }}<br/>
        {% if pub.authors %}
          <strong>Authors:</strong> {{ pub.authors | join: ", " }}<br/>
        {% endif %}
        {% if pub.subgroups %}
          <strong>Subgroups:</strong> {{ pub.subgroups | join: ", " }}<br/>
        {% endif %}
        {% if pub.keywords %}
          <strong>Keywords:</strong> {{ pub.keywords | join: ", " }}<br/>
        {% endif %}
      </div>
    </li>
  {% endfor %}
</ul>
