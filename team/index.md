---
layout: default
title: Team
---

{% assign active_team = site.team | where: "active", true | where_exp: "member", "member.placeholder != true" | sort: "join_date" %}
{% assign principal_investigators = active_team | where: "role", "Principal Investigator" %}
{% assign postdocs = active_team | where: "role", "Postdoc" %}
{% assign graduate_students = active_team | where: "role", "Graduate Student" %}
{% assign undergraduate_students = active_team | where: "role", "Undergraduate Student" %}
{% assign alumni = site.team | where: "role", "Alumni" | where: "active", false | sort: "leave_date" %}
{% assign lab_photo = site.posts | where: "title", "Fall 2023 Lab Picture!" | first %}

{% include section-heading.html title="Team" %}

<section class="page-section">
  <article class="feature-card team-photo-feature">
    <div class="team-photo-feature-image">
      <img
        src="{{ lab_photo.featured_image | relative_url }}"
        alt="{{ lab_photo.featured_image_alt | default: 'Lab group photo' | escape_once }}">
    </div>
    <div class="team-photo-feature-copy">
      <p class="team-photo-feature-caption">Lab Group Photo Fall 2023</p>
    </div>
  </article>
</section>

{% if principal_investigators.size > 0 %}
<section class="page-section">
  {% include section-heading.html title="Principal Investigator" %}
  {% include team-member-grid.html members=principal_investigators %}
</section>
{% endif %}

{% if postdocs.size > 0 %}
<section class="page-section">
  {% include section-heading.html title="Postdocs" %}
  {% include team-member-grid.html members=postdocs %}
</section>
{% endif %}

{% if graduate_students.size > 0 %}
<section class="page-section">
  {% include section-heading.html title="Graduate Students" %}
  {% include team-member-grid.html members=graduate_students graduate_hierarchy=true %}
</section>
{% endif %}

{% if undergraduate_students.size > 0 %}
<section class="page-section">
  {% include section-heading.html title="Undergraduate Students" %}
  {% include team-member-grid.html members=undergraduate_students %}
</section>
{% endif %}

{% if alumni.size > 0 %}
<section class="page-section">
  {% include section-heading.html title="Alumni" %}
  <div class="alumni-list">
    {% for member in alumni %}
      {% include alumni-card.html member=member %}
    {% endfor %}
  </div>
</section>
{% endif %}
