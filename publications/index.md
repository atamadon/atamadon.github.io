---
layout: default
title: Publications
---

{% assign publications = site.data.generated.publications %}
{% assign featured_publications = publications | where: "featured", true %}

<section class="publication-landing page-section">
  {% include section-heading.html eyebrow="Scholarly output" title="Publications" %}
  <p class="publication-intro">
    The publications archive is generated from the lab's curated source data and grouped for browsing first.
    External publisher or DOI links remain the canonical destinations for each record.
  </p>
  {% include publication-browse.html current="all" %}
</section>

{% if featured_publications.size > 0 %}
  <section class="page-section">
    {% include section-heading.html eyebrow="Curated selection" title="Featured publications" %}
    <div class="publication-featured-grid">
      {% for publication in featured_publications %}
        {% include publication-card.html publication=publication %}
      {% endfor %}
    </div>
  </section>
{% endif %}

<section class="page-section" id="publication-archive">
  {% include section-heading.html eyebrow="Complete archive" title="Browse by year" %}
  {% include publication-archive.html publications=publications empty_message="No publications are available yet." %}
</section>
