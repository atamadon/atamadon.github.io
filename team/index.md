---
layout: default
title: Team
---

# Our Team

## Principal Investigator

<div class="team-list">
  {% for member in site.team %}
    {% if member.role == "Principal Investigator" %}
    <div class="team-card">
      <img src="{{ member.image | relative_url }}" alt="Photo of {{ member.name }}">
      <h3>{{ member.name }}</h3>
      <p class="status">{{ member.status }}</p>
      <p>Email: <a href="mailto:{{ member.email }}">{{ member.email }}</a></p>
      <p>Group: {{ member.group }}</p>
      <div>{{ member.content | markdownify }}</div>
    </div>
    {% endif %}
  {% endfor %}
</div>

## Postdoctoral Researchers

<div class="team-list">
  {% for member in site.team %}
    {% if member.role == "Postdoc" %}
    <!-- identical card markup -->
    <div class="team-card">
      <img src="{{ member.image | relative_url }}" alt="Photo of {{ member.name }}">
      <h3>{{ member.name }}</h3>
      <p class="status">{{ member.status }}</p>
      <p>Email: <a href="mailto:{{ member.email }}">{{ member.email }}</a></p>
      <p>Group: {{ member.group }}</p>
      <div>{{ member.content | markdownify }}</div>
    </div>
    {% endif %}
  {% endfor %}
</div>

## Graduate Students

<div class="team-list">
  {% for member in site.team %}
    {% if member.role == "Graduate Student" %}
    <div class="team-card">
      <img src="{{ member.image | relative_url }}" alt="Photo of {{ member.name }}">
      <h3>{{ member.name }}</h3>
      <p class="status">{{ member.status }}</p>
      <p>Email: <a href="mailto:{{ member.email }}">{{ member.email }}</a></p>
      <p>Group: {{ member.group }}</p>
      <div>{{ member.content | markdownify }}</div>
    </div>
    {% endif %}
  {% endfor %}
</div>

## Undergraduate Students

<div class="team-list">
  {% for member in site.team %}
    {% if member.role == "Undergraduate Student" %}
    <div class="team-card">
      <img src="{{ member.image | relative_url }}" alt="Photo of {{ member.name }}">
      <h3>{{ member.name }}</h3>
      <p class="status">{{ member.status }}</p>
      <p>Email: <a href="mailto:{{ member.email }}">{{ member.email }}</a></p>
      <p>Group: {{ member.group }}</p>
      <div>{{ member.content | markdownify }}</div>
    </div>
    {% endif %}
  {% endfor %}
</div>

## Alumni

<ul class="alumni-list">
  {% for member in site.team %}
    {% if member.role == "Alumni" %}
    <li>{{ member.name }}</li>
    {% endif %}
  {% endfor %}
</ul>
