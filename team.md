---
layout: default
title: Team
---

# Our Team

## Principal Investigator

<ul class="team-list">
  {% for member in site.team %}
    {% if member.role == "Principal Investigator" %}
    <li class="team-card">
      <img src="{{ member.image }}" alt="Photo of {{ member.name }}">
      <h3>{{ member.name }}</h3>
      <p>{{ member.status }}</p>
      <p>{{ member.group }}</p>
      <p>Email: <a href="mailto:{{ member.email }}">{{ member.email }}</a></p>
      {{ member.content | markdownify }}
    </li>
    {% endif %}
  {% endfor %}
</ul>

## Postdoctoral Researchers

<ul class="team-list">
  {% for member in site.team %}
    {% if member.role == "Postdoc" %}
    <li class="team-card">
      <img src="{{ member.image }}" alt="Photo of {{ member.name }}">
      <h3>{{ member.name }}</h3>
      <p>{{ member.status }}</p>
      <p>{{ member.group }}</p>
      <p>Email: <a href="mailto:{{ member.email }}">{{ member.email }}</a></p>
      {{ member.content | markdownify }}
    </li>
    {% endif %}
  {% endfor %}
</ul>

## Graduate Students

<ul class="team-list">
  {% for member in site.team %}
    {% if member.role == "Graduate Student" %}
    <li class="team-card">
      <img src="{{ member.image }}" alt="Photo of {{ member.name }}">
      <h3>{{ member.name }}</h3>
      <p>{{ member.status }}</p>
      <p>{{ member.group }}</p>
      <p>Email: <a href="mailto:{{ member.email }}">{{ member.email }}</a></p>
      {{ member.content | markdownify }}
    </li>
    {% endif %}
  {% endfor %}
</ul>

## Undergraduate Students

<ul class="team-list">
  {% for member in site.team %}
    {% if member.role == "Undergraduate Student" %}
    <li class="team-card">
      <img src="{{ member.image }}" alt="Photo of {{ member.name }}">
      <h3>{{ member.name }}</h3>
      <p>{{ member.status }}</p>
      <p>{{ member.group }}</p>
      <p>Email: <a href="mailto:{{ member.email }}">{{ member.email }}</a></p>
      {{ member.content | markdownify }}
    </li>
    {% endif %}
  {% endfor %}
</ul>
