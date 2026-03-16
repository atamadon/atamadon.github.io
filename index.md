---
layout: default
title: Home
---

{% assign site_info = site.data.site %}
{% assign recent_pubs = site.data.generated.publications | sort: "date" | reverse | slice: 0, 3 %}

<!-- Homepage hero variants: hero-section-structural, hero-section-mechanical,
hero-section-molecular, hero-section-editorial -->
<section class="hero-section hero-section-mechanical">
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
      <h3><a href="{{ '/research/nuclear-mechanotransduction/' | relative_url }}">Nuclear Mechanotransduction</a></h3>
      <p>Mechanics at the nuclear envelope, force transmission, and structure-function relationships in protein assemblies.</p>
    </article>
    <article class="feature-card">
      <h3><a href="{{ '/research/microbiome/' | relative_url }}">Microbiome</a></h3>
      <p>Computational models of host-microbe systems, ecological dynamics, and spatial organization in the gut environment.</p>
    </article>
    <article class="feature-card">
      <h3><a href="{{ '/research/ai/' | relative_url }}">Artificial Intelligence</a></h3>
      <p>Machine learning and automation for biological discovery, predictive modeling, and analysis of complex datasets.</p>
    </article>
  </div>
</section>

<section class="home-section">
  {% include section-heading.html title="Recent Publications" link_label="View publication archive" link_url="/publications/" %}
  <div class="feature-grid">
    {% for pub in recent_pubs %}
      <article class="feature-card">
        <p class="feature-meta">{{ pub.date | date: "%Y" }} · {{ pub.type | capitalize }}</p>
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
    <h2>Teaching and Contact</h2>
    <p>Browse course offerings and find department contact details for collaboration and student inquiries.</p>
    <a href="{{ '/contact/' | relative_url }}">Contact the lab</a>
  </article>
</section>
