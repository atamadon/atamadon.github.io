---
layout: default
title: Reference Entries
---

{% assign publications = site.data.generated.publications | where: "subtype", "reference_entry" %}

<section class="publication-landing page-section">
  {% include section-heading.html title="Reference entries" %}
  {% include publication-browse.html current="reference_entry" %}
</section>

<section class="page-section" id="reference-entry-archive">
  {% include publication-archive.html publications=publications empty_message="No reference entries are available yet." %}
</section>
