---
layout: default
title: Contact
---

{% assign contact = site.data.site.contact %}
{% assign accessibility = site.data.site.accessibility %}

{% include section-heading.html eyebrow="Connect" title="Contact the lab" %}

<section class="page-section contact-grid">
  <div class="contact-sidebar">
    <article class="contact-card">
      <h2>Department contact</h2>
      <p><strong>Email:</strong> <a href="mailto:{{ contact.email }}">{{ contact.email }}</a></p>
      <p><strong>Phone:</strong> {{ contact.phone }}</p>
      <p><strong>Fax:</strong> {{ contact.fax }}</p>
      <p>
        <strong>Address:</strong><br>
        {% for line in contact.address_lines %}
          {{ line }}{% unless forloop.last %}<br>{% endunless %}
        {% endfor %}
      </p>
    </article>
    <article class="contact-card">
      <h2>Accessibility</h2>
      <p>{{ accessibility.statement }}</p>
      <p><a href="{{ accessibility.report_url }}">Report a web accessibility issue</a></p>
      <p><strong>Site contact:</strong> <a href="mailto:{{ accessibility.support_email }}">{{ accessibility.support_email }}</a></p>
    </article>
  </div>
  <div class="contact-map">
    <iframe src="{{ contact.map_embed_url }}" allowfullscreen loading="lazy" referrerpolicy="no-referrer-when-downgrade" title="Map to Stanley Hall"></iframe>
  </div>
</section>
