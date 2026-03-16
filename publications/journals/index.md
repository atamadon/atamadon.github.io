---
layout: default
title: Journal Articles
---

{% assign journals = site.data.generated.publications | where: "type", "journal" %}

<section class="publication-landing page-section">
  {% include section-heading.html eyebrow="Generated archive" title="Journal articles" %}
  <p class="publication-intro">
    Journal articles, perspectives, and related papers are listed here in the same generated archive system as the main publications page.
  </p>
  {% include publication-browse.html current="journal" %}
</section>

<section class="page-section" id="journal-archive">
  {% include section-heading.html eyebrow="Type archive" title="Journal archive" %}
  {% include publication-archive.html publications=journals empty_message="No journal articles are available yet." %}
</section>
