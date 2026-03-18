---
layout: default
title: Style Guide
nav_exclude: true
---

<style>
  /* Style-guide-only helper styles — not part of the main design system */
  .sg-section {
    padding: var(--space-5) 0;
    border-bottom: 1px solid var(--line-300);
  }
  .sg-section:last-child {
    border-bottom: none;
  }
  .sg-section-title {
    font-size: 0.82rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    color: var(--ink-700);
    margin: 0 0 var(--space-4);
    padding-bottom: var(--space-2);
    border-bottom: 2px solid var(--berkeley-gold);
    display: inline-block;
  }
  .sg-label {
    font-size: 0.78rem;
    color: var(--ink-700);
    margin-top: 0.35rem;
    font-family: var(--font-sans);
  }
  .sg-row {
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-3);
    align-items: flex-start;
  }
  .sg-col {
    display: flex;
    flex-direction: column;
  }
  .sg-swatch {
    width: 3rem;
    height: 3rem;
    border-radius: var(--radius-card);
    border: 1px solid var(--line-300);
  }
  .sg-type-row {
    margin-bottom: var(--space-3);
  }
  .sg-type-label {
    font-size: 0.75rem;
    color: var(--ink-700);
    margin-bottom: 0.2rem;
  }
  .sg-space-bar {
    height: 0.5rem;
    background: #002676;
    border-radius: 2px;
    margin-bottom: 0.3rem;
  }
  .sg-space-row {
    margin-bottom: var(--space-2);
  }
  .sg-table {
    border-collapse: collapse;
    width: 100%;
    max-width: 36rem;
  }
  .sg-table th,
  .sg-table td {
    text-align: left;
    padding: 0.4rem 0.8rem;
    font-size: 0.9rem;
    border-bottom: 1px solid var(--line-300);
  }
  .sg-table th {
    font-weight: 700;
    color: var(--ink-700);
    font-size: 0.8rem;
    text-transform: uppercase;
    letter-spacing: 0.06em;
  }
  .sg-table td code {
    font-family: monospace;
    font-size: 0.85rem;
    color: var(--berkeley-blue);
  }
  .sg-note {
    font-size: 0.85rem;
    color: var(--ink-700);
    margin-top: var(--space-2);
    padding: var(--space-2) var(--space-3);
    background: var(--surface-50);
    border-left: 3px solid var(--berkeley-gold);
    border-radius: 0 var(--radius-card) var(--radius-card) 0;
  }
  .sg-buttons-row {
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-3);
    align-items: center;
  }
  .sg-button-group {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 0.4rem;
  }
  .sg-cards-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: var(--space-4);
  }
  .sg-tags-row {
    display: flex;
    flex-wrap: wrap;
    gap: var(--space-2);
    align-items: center;
  }
  .sg-tag-group {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 0.3rem;
  }
  .sg-intro {
    max-width: 52rem;
    color: var(--ink-700);
    margin-bottom: var(--space-5);
    font-size: 0.95rem;
    line-height: 1.6;
  }
</style>

<div class="hero-section hero-section-editorial">
  <p class="eyebrow">Internal Developer Reference</p>
  <h1>Style Guide</h1>
  <p class="hero-copy">A live inventory of every design token and UI component used across the Mofrad Lab website. All elements below render using the actual CSS classes from <code>assets/css/style.css</code>.</p>
</div>

<p class="sg-intro">
  This page is not linked from site navigation and is intended for development use only. View it at <code>/style-guide/</code>. The light/dark theme toggle in the header applies to all swatches and components below.
</p>

---

<section class="sg-section">
  <span class="sg-section-title">0 — Color Palette</span>

  <div style="margin-bottom: var(--space-4);">
    <p class="sg-type-label" style="font-weight:700; color: var(--ink-900); margin-bottom: var(--space-2);">Core — Berkeley Brand Colors</p>
    <div class="sg-row">
      <div class="sg-col">
        <div class="sg-swatch" style="background: #002676;"></div>
        <div class="sg-label">Berkeley Blue</div>
        <div class="sg-label">#002676</div>
      </div>
      <div class="sg-col">
        <div class="sg-swatch" style="background: #FDB515;"></div>
        <div class="sg-label">California Gold</div>
        <div class="sg-label">#FDB515</div>
      </div>
    </div>
  </div>

  <div style="margin-bottom: var(--space-4);">
    <p class="sg-type-label" style="font-weight:700; color: var(--ink-900); margin-bottom: var(--space-2);">Accent Colors</p>
    <div class="sg-row">
      <div class="sg-col">
        <div class="sg-swatch" style="background: #010133;"></div>
        <div class="sg-label">Blue Dark</div>
        <div class="sg-label">#010133</div>
      </div>
      <div class="sg-col">
        <div class="sg-swatch" style="background: #004AAE;"></div>
        <div class="sg-label">Blue Medium</div>
        <div class="sg-label">#004AAE</div>
      </div>
      <div class="sg-col">
        <div class="sg-swatch" style="background: #FC9313;"></div>
        <div class="sg-label">Gold Dark</div>
        <div class="sg-label">#FC9313</div>
      </div>
      <div class="sg-col">
        <div class="sg-swatch" style="background: #FFC31B;"></div>
        <div class="sg-label">Gold Medium</div>
        <div class="sg-label">#FFC31B</div>
      </div>
    </div>
  </div>

  <div style="margin-bottom: var(--space-4);">
    <p class="sg-type-label" style="font-weight:700; color: var(--ink-900); margin-bottom: var(--space-2);">Surfaces — theme-aware CSS vars (toggle header to see dark values)</p>
    <div class="sg-row">
      <div class="sg-col">
        <div class="sg-swatch" style="background: var(--surface-0);"></div>
        <div class="sg-label">--surface-0</div>
        <div class="sg-label">Base page bg</div>
      </div>
      <div class="sg-col">
        <div class="sg-swatch" style="background: var(--surface-50);"></div>
        <div class="sg-label">--surface-50</div>
        <div class="sg-label">Subtle tint</div>
      </div>
      <div class="sg-col">
        <div class="sg-swatch" style="background: var(--surface-100);"></div>
        <div class="sg-label">--surface-100</div>
        <div class="sg-label">Card interior</div>
      </div>
      <div class="sg-col">
        <div class="sg-swatch" style="background: var(--surface-tint);"></div>
        <div class="sg-label">--surface-tint</div>
        <div class="sg-label">Hover states</div>
      </div>
    </div>
  </div>

  <div style="margin-bottom: var(--space-4);">
    <p class="sg-type-label" style="font-weight:700; color: var(--ink-900); margin-bottom: var(--space-2);">Ink & Borders</p>
    <div class="sg-row">
      <div class="sg-col">
        <div class="sg-swatch" style="background: var(--ink-900);"></div>
        <div class="sg-label">--ink-900</div>
        <div class="sg-label">Body text</div>
      </div>
      <div class="sg-col">
        <div class="sg-swatch" style="background: var(--ink-700);"></div>
        <div class="sg-label">--ink-700</div>
        <div class="sg-label">Muted text</div>
      </div>
      <div class="sg-col">
        <div class="sg-swatch" style="background: var(--line-300); border: 1px dashed var(--ink-700);"></div>
        <div class="sg-label">--line-300</div>
        <div class="sg-label">Card borders</div>
      </div>
    </div>
  </div>
</section>

<section class="sg-section">
  <span class="sg-section-title">1 — Typography Scale</span>

  <div class="sg-type-row">
    <div class="sg-type-label">h1 — Source Serif 4, clamp(2.4rem, 4vw, 4.4rem)</div>
    <h1 style="margin-bottom:0;">Mofrad Lab</h1>
  </div>

  <div class="sg-type-row">
    <div class="sg-type-label">h2 — Source Serif 4, default size</div>
    <h2 style="margin-bottom:0;">Research Areas</h2>
  </div>

  <div class="sg-type-row">
    <div class="sg-type-label">h3 — Source Serif 4, default size</div>
    <h3 style="margin-bottom:0;">Principal Investigator</h3>
  </div>

  <div class="sg-type-row">
    <div class="sg-type-label">h4 — Source Serif 4, default size</div>
    <h4 style="margin-bottom:0;">Journal Article</h4>
  </div>

  <div class="sg-type-row">
    <div class="sg-type-label">body / p — Inter, 1rem / 1.65 line-height</div>
    <p style="max-width:52rem; margin-bottom:0;">The Mofrad Lab investigates fundamental problems in biomechanics and mechanobiology with a focus on cellular and molecular mechanics, transport phenomena, and computational modeling of biological systems at multiple scales.</p>
  </div>

  <div class="sg-type-row">
    <div class="sg-type-label">small text — 0.88rem</div>
    <p style="font-size:0.88rem; color: var(--ink-700); margin-bottom:0;">Published in <em>Nature Methods</em> · Vol. 18, pp. 1–12 · 2024</p>
  </div>

  <div class="sg-type-row">
    <div class="sg-type-label">.eyebrow — 0.82rem, uppercase, letter-spacing 0.08em, font-weight 700</div>
    <p class="eyebrow" style="margin-bottom:0;">Research Group</p>
  </div>
</section>

<section class="sg-section">
  <span class="sg-section-title">2 — Spacing Scale</span>

  <div class="sg-space-row">
    <div class="sg-label" style="margin-bottom:0.4rem;">--space-1 — 0.5rem</div>
    <div class="sg-space-bar" style="width: var(--space-1);"></div>
  </div>
  <div class="sg-space-row">
    <div class="sg-label" style="margin-bottom:0.4rem;">--space-2 — 0.75rem</div>
    <div class="sg-space-bar" style="width: var(--space-2);"></div>
  </div>
  <div class="sg-space-row">
    <div class="sg-label" style="margin-bottom:0.4rem;">--space-3 — 1rem</div>
    <div class="sg-space-bar" style="width: var(--space-3);"></div>
  </div>
  <div class="sg-space-row">
    <div class="sg-label" style="margin-bottom:0.4rem;">--space-4 — 1.5rem</div>
    <div class="sg-space-bar" style="width: var(--space-4);"></div>
  </div>
  <div class="sg-space-row">
    <div class="sg-label" style="margin-bottom:0.4rem;">--space-5 — 2rem</div>
    <div class="sg-space-bar" style="width: var(--space-5);"></div>
  </div>
  <div class="sg-space-row">
    <div class="sg-label" style="margin-bottom:0.4rem;">--space-6 — 3rem</div>
    <div class="sg-space-bar" style="width: var(--space-6);"></div>
  </div>
  <div class="sg-space-row">
    <div class="sg-label" style="margin-bottom:0.4rem;">--space-7 — 4rem</div>
    <div class="sg-space-bar" style="width: var(--space-7);"></div>
  </div>
</section>

<section class="sg-section">
  <span class="sg-section-title">3 — Link States</span>

  <div style="margin-bottom: var(--space-4);">
    <div class="sg-type-label">Body text link — animated underline via background-size grow on hover</div>
    <p>Research in the Mofrad Lab spans <a href="#">cellular mechanobiology</a>, <a href="#">molecular dynamics simulation</a>, and <a href="#">transport in biological membranes</a>. Hover each link to see the underline slide in.</p>
  </div>

  <div style="margin-bottom: var(--space-4);">
    <div class="sg-type-label">.section-link — bold, same underline animation, used for "View all" CTAs</div>
    <p><a href="#" class="section-link">View all publications →</a></p>
  </div>

  <div style="margin-bottom: var(--space-4);">
    <div class="sg-type-label">.nav-item-link — scale-transform underline via ::after pseudo-element (only visible inside the actual site header)</div>
    <p class="sg-note">Nav links use a different technique: a <code>::after</code> pseudo-element that scales from <code>scaleX(0)</code> to <code>scaleX(1)</code> on hover/focus. Body links use <code>background-size</code> growth. Both achieve the same visual result with different implementations suited to their layout contexts.</p>
  </div>
</section>

<section class="sg-section">
  <span class="sg-section-title">4 — Tokens: Motion & Radius</span>

  <table class="sg-table">
    <thead>
      <tr>
        <th>Token</th>
        <th>Default value</th>
        <th>Use</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><code>--motion-fast</code></td>
        <td><code>160ms</code></td>
        <td>Color, border transitions</td>
      </tr>
      <tr>
        <td><code>--motion-base</code></td>
        <td><code>240ms</code></td>
        <td>Card lift, underline grow</td>
      </tr>
      <tr>
        <td><code>--motion-slow</code></td>
        <td><code>420ms</code></td>
        <td>Larger layout transitions</td>
      </tr>
      <tr>
        <td><code>--motion-hero</code></td>
        <td><code>28s</code></td>
        <td>Hero ambient animations</td>
      </tr>
      <tr>
        <td><code>--ease-standard</code></td>
        <td><code>cubic-bezier(0.2, 0, 0.12, 1)</code></td>
        <td>Most transitions</td>
      </tr>
      <tr>
        <td><code>--ease-soft</code></td>
        <td><code>cubic-bezier(0.22, 0.6, 0.2, 1)</code></td>
        <td>Lifts, underlines</td>
      </tr>
      <tr>
        <td><code>--radius-card</code></td>
        <td><code>1rem</code></td>
        <td>All card corners</td>
      </tr>
      <tr>
        <td><code>--radius-pill</code></td>
        <td><code>999px</code></td>
        <td>Buttons, tags, nav pills</td>
      </tr>
      <tr>
        <td><code>--link-underline-thickness</code></td>
        <td><code>1.5px</code></td>
        <td>Underline bar height</td>
      </tr>
      <tr>
        <td><code>--link-underline-offset</code></td>
        <td><code>2px</code></td>
        <td>Gap below text baseline</td>
      </tr>
    </tbody>
  </table>
</section>

<section class="sg-section">
  <span class="sg-section-title">5 — Buttons</span>

  <div class="sg-buttons-row">
    <div class="sg-button-group">
      <div class="sg-type-label">.button-link — primary, Berkeley Blue fill</div>
      <a href="#" class="button-link">View Research</a>
    </div>
    <div class="sg-button-group">
      <div class="sg-type-label">.button-link + .button-link-secondary — outline style</div>
      <a href="#" class="button-link button-link-secondary">Download PDF</a>
    </div>
  </div>

  <p class="sg-note">Hover either button to see the state change. Primary darkens to <code>--accent-blue</code> with a drop shadow. Secondary fills with <code>--surface-tint</code>. Both use <code>--radius-pill</code> and <code>--motion-fast</code> transitions.</p>
</section>

<section class="sg-section">
  <span class="sg-section-title">6 — Cards</span>

  <div class="sg-cards-row">
    <div>
      <div class="sg-type-label" style="margin-bottom: var(--space-2);">.feature-card</div>
      <div class="feature-card">
        <p class="feature-meta">Computational Biology</p>
        <h3>Molecular Dynamics</h3>
        <p>Atomistic simulations revealing the mechanical response of cytoskeletal proteins under physiological loading conditions and disease states.</p>
      </div>
    </div>

    <div>
      <div class="sg-type-label" style="margin-bottom: var(--space-2);">.callout-card</div>
      <div class="callout-card">
        <p class="eyebrow">Opportunity</p>
        <h3>Join the Lab</h3>
        <p>We are recruiting PhD students and postdoctoral researchers with backgrounds in biophysics, bioengineering, or computational science.</p>
      </div>
    </div>

    <div>
      <div class="sg-type-label" style="margin-bottom: var(--space-2);">.team-card — minimal example with fallback initials</div>
      <div class="team-card">
        <div class="team-photo">
          <div class="team-photo-fallback" aria-hidden="true">ML</div>
        </div>
        <div class="team-card-body">
          <h3>Mohammad Mofrad</h3>
          <p class="team-status">Principal Investigator</p>
          <div class="team-groups">
            <span class="team-group-tag">PI</span>
            <a href="#" class="team-group-tag">Biomechanics</a>
          </div>
          <p class="team-bio">Professor of Bioengineering and Mechanical Engineering at UC Berkeley. Research spans cell mechanics, mechanobiology, and molecular simulation.</p>
          <ul class="team-links">
            <li><a href="#">Email</a></li>
            <li><a href="#">Lab Page</a></li>
          </ul>
        </div>
      </div>
    </div>
  </div>

  <p class="sg-note">All three card types share the same base styles: <code>--surface-0</code> background, <code>1px solid var(--line-300)</code> border, <code>var(--shadow-card)</code> shadow, and a hover state that lifts with <code>var(--card-hover-lift)</code> and shifts the border to gold.</p>
</section>

<section class="sg-section">
  <span class="sg-section-title">7 — Tag Pills</span>

  <div class="sg-tags-row">
    <div class="sg-tag-group">
      <div class="sg-type-label">.team-group-tag (span — non-interactive)</div>
      <span class="team-group-tag">Computational Biology</span>
    </div>
    <div class="sg-tag-group">
      <div class="sg-type-label">a.team-group-tag (link — hover for gold border)</div>
      <a href="#" class="team-group-tag">Mechanobiology</a>
    </div>
    <div class="sg-tag-group">
      <div class="sg-type-label">.publication-tag (gold tint background)</div>
      <span class="publication-tag">Biophysics</span>
    </div>
    <div class="sg-tag-group">
      <div class="sg-type-label">.publication-tag (another example)</div>
      <span class="publication-tag">Cell Mechanics</span>
    </div>
  </div>

  <p class="sg-note">Team group tags use <code>--surface-100</code> fill and transition to <code>--surface-tint</code> with a gold border on hover (link variant only). Publication tags use a semi-transparent gold background (<code>rgba(253, 181, 21, 0.12)</code>) and always show <code>--berkeley-blue</code> text.</p>
</section>

<section class="sg-section">
  <span class="sg-section-title">8 — Section Heading</span>

  <div class="sg-type-label" style="margin-bottom: var(--space-3);">.section-heading — flex row with space-between, aligns h2 and a .section-link</div>

  <div class="section-heading">
    <h2>Recent Publications</h2>
    <a href="#" class="section-link">View all publications →</a>
  </div>

  <div class="section-heading" style="margin-top: var(--space-4);">
    <h2>Lab Members</h2>
    <a href="#" class="section-link">Meet the team →</a>
  </div>

  <p class="sg-note">On mobile (≤48rem), <code>.section-heading</code> switches to <code>flex-direction: column</code> with <code>align-items: flex-start</code>, and the h2 reduces to 1.65rem. The <code>.section-link</code> inherits the sliding underline animation from the base link styles.</p>
</section>
