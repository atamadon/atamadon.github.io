---
layout: default
title: Contact
---

{% assign contact = site.data.site.contact %}

{% include section-heading.html title="Contact" %}

<section class="page-section contact-grid">
  <article class="contact-card contact-details-card">
    <h2>Department contact</h2>
    <div class="contact-list">
      <div class="contact-row">
        <p class="contact-label">Email</p>
        <p><a href="mailto:{{ contact.email }}">{{ contact.email }}</a></p>
      </div>
      <div class="contact-row">
        <p class="contact-label">Phone</p>
        <p>{{ contact.phone }}</p>
      </div>
      <div class="contact-row">
        <p class="contact-label">Fax</p>
        <p>{{ contact.fax }}</p>
      </div>
      <div class="contact-row">
        <p class="contact-label">Address</p>
        <p class="contact-address">
        {% for line in contact.address_lines %}
          {{ line }}{% unless forloop.last %}<br>{% endunless %}
        {% endfor %}
        </p>
      </div>
    </div>
  </article>
  <article class="contact-card contact-map-card">
    <h2>Visit Stanley Hall</h2>
    <iframe src="{{ contact.map_embed_url }}" allowfullscreen loading="lazy" referrerpolicy="no-referrer-when-downgrade" title="Map to Stanley Hall"></iframe>
  </article>
</section>
