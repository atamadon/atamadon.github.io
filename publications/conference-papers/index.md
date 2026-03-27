---
layout: default
title: Conference Papers
---

{% assign publications = site.data.generated.publications | where: "subtype", "conference" %}

<section class="publication-landing page-section">
  {% include section-heading.html title="Conference papers" %}
  {% include publication-browse.html current="conference" %}
</section>

<section class="page-section" id="conference-paper-archive">
  {% include publication-archive.html publications=publications empty_message="No conference papers are available yet." %}
</section>
