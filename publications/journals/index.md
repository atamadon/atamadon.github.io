---
layout: default
title: Journal Articles
---

{% assign journals = site.data.generated.publications | where: "subtype", "journal_article" %}

<section class="publication-landing page-section">
  {% include section-heading.html title="Journal articles" %}
</section>

<section class="page-section" id="journal-archive">
  <div class="journal-topic-grid">
    {% include journal-topic-column.html publications=journals topic="cell_nuclear" title="Cell & Nuclear Biomechanics" %}
    {% include journal-topic-column.html publications=journals topic="microbiome" title="Microbiome & Bacterial Community Biomechanics" %}
    {% include journal-topic-column.html publications=journals topic="slblp" title="Statistical Learning & Biological Language Processing" %}
  </div>
</section>
