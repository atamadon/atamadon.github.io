---
layout: default
title: Repository Records
---

{% assign publications = site.data.generated.publications | where: "subtype", "repository" %}

<section class="publication-landing page-section">
  {% include section-heading.html title="Repository records" %}
  {% include publication-browse.html current="repository" %}
</section>

<section class="page-section" id="repository-record-archive">
  {% include publication-archive.html publications=publications empty_message="No repository records are available yet." %}
</section>
