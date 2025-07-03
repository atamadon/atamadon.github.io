---
layout: default
title: Publications
---

# All Publications

<table class="publications-table">
  <tbody>
    {% assign pubs_by_year = site.publications
       | sort: "date" | reverse
       | group_by_exp: "item", "item.date | date: '%Y'" %}
    {% for year in pubs_by_year %}
      <tr>
        <th colspan="2" class="year-heading">{{ year.name }}</th>
      </tr>
      {% for pub in year.items %}
      <tr>
        <td class="pub-image-cell">
          {% if pub.type == "journal" and pub.figure %}
            <img src="{{ pub.figure | relative_url }}"
                 alt="Figure from {{ pub.title }}">
          {% elsif pub.type == "book" and pub.cover %}
            <img src="{{ pub.cover | relative_url }}"
                 alt="Cover of {{ pub.title }}">
          {% endif %}
        </td>
        <td class="pub-text-cell">
          {% assign href = pub.external_url | default: pub.url %}
          <strong>
            <a href="{{ href }}" target="_blank" rel="noopener">
              {{ pub.title }}
            </a>
          </strong><br/>
          {% if pub.citation %}
            <em>{{ pub.citation }}</em><br/>
          {% endif %}
          {% if pub.authors %}
            <strong>Authors:</strong> {{ pub.authors | join: ", " }}<br/>
          {% endif %}
          {% if pub.keywords %}
            <strong>Keywords:</strong> {{ pub.keywords | join: ", " }}<br/>
          {% endif %}
        </td>
      </tr>
      {% endfor %}
    {% endfor %}
  </tbody>
</table>
