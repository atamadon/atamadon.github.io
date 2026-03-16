---
layout: default
title: News
---

{% assign news_posts = site.posts %}

{% include section-heading.html eyebrow="Updates" title="Lab news archive" %}

{% if news_posts.size > 0 %}
<div class="news-placeholder">
  <p>These are temporary sample updates to populate the archive while the WordPress news backfill is pending.</p>
</div>

<section class="news-feed" aria-label="Lab news feed">
  {% for post in news_posts %}
    <article class="news-item">
      <div class="news-date">
        <p class="news-month">{{ post.date | date: "%b" }}</p>
        <p class="news-day">{{ post.date | date: "%-d" }}</p>
        <p class="news-year">{{ post.date | date: "%Y" }}</p>
      </div>
      <div class="news-body">
        <p class="feature-meta">{{ post.date | date: "%B %-d, %Y" }}</p>
        <h2>{{ post.title }}</h2>
        {% if post.featured_image %}
          <div class="news-image">
            <img src="{{ post.featured_image | relative_url }}" alt="{{ post.featured_image_alt | default: post.title }}">
          </div>
        {% endif %}
        <p>{{ post.excerpt | strip_html | normalize_whitespace | truncate: 220 }}</p>
      </div>
    </article>
  {% endfor %}
</section>
{% else %}
<div class="news-placeholder">
  <p>The news archive will be backfilled from the previous WordPress website in a later migration pass.</p>
  <p>Until then, the most complete public record on this site is the <a href="{{ '/publications/' | relative_url }}">publications archive</a>, along with the <a href="{{ '/teaching/' | relative_url }}">teaching</a> and <a href="{{ '/research/' | relative_url }}">research</a> sections.</p>
</div>
{% endif %}
