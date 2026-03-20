---
layout: default
title: Team
---

{% assign active_team = site.team | where: "active", true | where_exp: "member", "member.placeholder != true" | sort: "sort_order" %}
{% assign principal_investigators = active_team | where: "role", "Principal Investigator" %}
{% assign postdocs = active_team | where: "role", "Postdoc" %}
{% assign graduate_students = active_team | where: "role", "Graduate Student" %}
{% assign undergraduate_students = active_team | where: "role", "Undergraduate Student" %}
{% assign alumni = site.team | where: "role", "Alumni" | where: "active", false | where_exp: "member", "member.placeholder != true" | sort: "sort_order" %}
{% assign sample_profiles = site.team | where: "placeholder", true | where: "active", true %}

{% include section-heading.html eyebrow="People" title="Team" %}

{% if sample_profiles.size > 0 %}
<div class="news-placeholder">
  <p>Additional public profiles are being finalized as the roster is migrated and reviewed for publication.</p>
</div>
{% endif %}

<section class="page-section">
  {% include section-heading.html title="Principal Investigator" %}
  <div class="team-list">
    {% for member in principal_investigators %}
      {% include team-card.html member=member %}
    {% endfor %}
  </div>
</section>

{% if postdocs.size > 0 %}
<section class="page-section">
  {% include section-heading.html title="Postdoctoral Researchers" %}
  <div class="team-list">
    {% for member in postdocs %}
      {% include team-card.html member=member %}
    {% endfor %}
  </div>
</section>
{% endif %}

{% if graduate_students.size > 0 %}
<section class="page-section">
  {% include section-heading.html title="Graduate Students" %}
  <div class="team-list">
    {% for member in graduate_students %}
      {% include team-card.html member=member %}
    {% endfor %}
  </div>
</section>
{% endif %}

{% if undergraduate_students.size > 0 %}
<section class="page-section">
  {% include section-heading.html title="Undergraduate Students" %}
  <div class="team-list">
    {% for member in undergraduate_students %}
      {% include team-card.html member=member %}
    {% endfor %}
  </div>
</section>
{% endif %}

{% if postdocs.size == 0 and graduate_students.size == 0 and undergraduate_students.size == 0 %}
<p>Additional public profiles will be added as active lab members are approved for publication with finalized bios and images.</p>
{% endif %}

{% if alumni.size > 0 %}
<section class="page-section">
  {% include section-heading.html title="Alumni" %}
  <ul class="alumni-list">
    {% for member in alumni %}
      <li>
        {{ member.name }}
        {% if member.current_position %}(presently {{ member.current_position }}){% endif %}
      </li>
    {% endfor %}
  </ul>
</section>
{% endif %}
