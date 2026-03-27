---
layout: default
title: Home
---

{% assign site_info = site.data.site %}
{% assign recent_pubs = site.data.generated.publications | sort: "date" | reverse | slice: 0, 3 %}

<!-- Homepage hero variants remain available: hero-section-structural,
hero-section-mechanical, hero-section-molecular, hero-section-editorial -->
<section class="hero-section">
  <p class="eyebrow">{{ site_info.tagline }}</p>
  <h1>Modeling how physical forces shape living systems</h1>
  <p class="hero-copy">
    The Molecular Cell Biomechanics Laboratory studies biological systems across scales,
    combining mechanobiology, molecular modeling, and data-driven methods to better
    understand how structure, force, and dynamics influence function.
  </p>
  <div class="hero-actions">
    <a class="button-link" href="{{ '/research/' | relative_url }}">Explore research</a>
    <a class="button-link button-link-secondary" href="{{ '/publications/' | relative_url }}">Browse publications</a>
  </div>
</section>

<section class="home-section">
  {% include section-heading.html title="Research Areas" link_label="See all research" link_url="/research/" %}
  <div class="feature-grid">
    <article class="feature-card">
      <h3><a href="{{ '/research/nuclear-mechanotransduction/' | relative_url }}">Cell &amp; Nuclear Biomechanics</a></h3>
      <p>Cell and nuclear mechanics, force transmission across the nuclear envelope, and structure-function relationships at the cell-nucleus interface.</p>
    </article>
    <article class="feature-card">
      <h3><a href="{{ '/research/microbiome/' | relative_url }}">Microbiome &amp; Bacterial Community Biomechanics</a></h3>
      <p>Biomechanics and multiscale modeling of host-microbe systems, bacterial communities, gut biogeography, and ecological dynamics.</p>
    </article>
    <article class="feature-card">
      <h3><a href="{{ '/research/ai/' | relative_url }}">Statistical Learning &amp; Biological Language Processing</a></h3>
      <p>Statistical learning, biological language processing, and model-driven discovery across sequence, genome, and microbiome data.</p>
    </article>
  </div>
</section>

<section class="home-section">
  {% include section-heading.html title="Recent Publications" link_label="View publication archive" link_url="/publications/" %}
  <div class="feature-grid">
    {% for pub in recent_pubs %}
      <article class="feature-card">
        <p class="feature-meta">{{ pub.date | date: "%Y" }} &middot; {{ pub.type | capitalize }}</p>
        <h3><a href="{{ pub.source_url }}" target="_blank" rel="noopener">{{ pub.title }}</a></h3>
        {% if pub.citation %}
          <p>{{ pub.citation }}</p>
        {% endif %}
      </article>
    {% endfor %}
  </div>
</section>

<section class="home-section home-callouts">
  <article class="callout-card">
    <h2>Meet the Lab</h2>
    <p>Learn more about the principal investigator, lab structure, and future team updates.</p>
    <a href="{{ '/team/' | relative_url }}">Go to team page</a>
  </article>
  <article class="callout-card">
    <h2>Teaching</h2>
    <p>Browse course offerings across computational biology, molecular biomechanics, and mechanobiology.</p>
    <a href="{{ '/teaching/' | relative_url }}">View teaching page</a>
  </article>
</section>
