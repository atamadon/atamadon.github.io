---
layout: default
title: News
---

{% assign news_posts = site.posts %}

{% include section-heading.html title="News" %}

{% if news_posts.size > 0 %}
<section class="news-feed" aria-label="Lab news feed">
  {% for post in news_posts %}
    <article class="news-item">
      <div class="news-date">
        <p class="news-month">{{ post.date | date: "%b" }}</p>
        <p class="news-day">{{ post.date | date: "%-d" }}</p>
        <p class="news-year">{{ post.date | date: "%Y" }}</p>
      </div>
      <div class="news-marker" aria-hidden="true"></div>
      <div class="news-body">
        <div class="news-card{% unless post.featured_image %} news-card-no-image{% endunless %}">
          {% if post.featured_image %}
            <div class="news-image">
              <img src="{{ post.featured_image | relative_url }}" alt="{{ post.featured_image_alt | default: post.title | escape_once }}">
            </div>
          {% endif %}
          <div class="news-copy">
            <h2>{{ post.title }}</h2>
            {% assign news_summary = post.content | split: '</p>' | first | append: '</p>' | strip_html | normalize_whitespace %}
            <p>{{ news_summary | truncate: 220 }}</p>
          </div>
        </div>
      </div>
    </article>
  {% endfor %}
</section>
{% else %}
<div class="news-placeholder">
  <p>News updates will appear here as they are published.</p>
</div>
{% endif %}
