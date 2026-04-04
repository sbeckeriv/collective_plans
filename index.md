---
layout: default
title: Pinball Strategy Guides
---

<h1>AI-Generated Pinball Strategy Guides</h1>
<p>Master the game with comprehensive strategy guides for classic and modern pinball machines.</p>
<p><span id="machine-count">{{ site.pinball.size }}</span> machines in the database.</p>

<!-- Filters -->
<div class="filters">
  <div class="filter-group">
    <label>Manufacturer:</label>
    <select id="filter-manufacturer" onchange="filterMachines()">
      <option value="">All</option>
      {% assign manufacturers = site.pinball | map: "manufacturer" | uniq | sort %}
      {% for mfg in manufacturers %}
      <option value="{{ mfg }}">{{ mfg }}</option>
      {% endfor %}
    </select>
  </div>

  <div class="filter-group">
    <label>Type:</label>
    <select id="filter-type" onchange="filterMachines()">
      <option value="">All</option>
      {% assign types = site.pinball | map: "type" | uniq | sort %}
      {% for type in types %}
      <option value="{{ type }}">{{ type }}</option>
      {% endfor %}
    </select>
  </div>

  <button onclick="clearFilters()" class="btn-clear">Clear Filters</button>
</div>

<div class="machine-grid">
  {% for machine in site.pinball %}
  <div class="machine-card" data-manufacturer="{{ machine.manufacturer }}" data-type="{{ machine.type }}"
    data-year="{{ machine.year }}">
    {% if machine.image %}
    <img src="{{ machine.image | relative_url }}" alt="{{ machine.title }}" loading="lazy">
    {% endif %}
    <h2><a href="{{ machine.url | relative_url }}">{{ machine.title }}</a></h2>
    <p><strong>{{ machine.manufacturer }}</strong> &bull; {{ machine.year }}</p>
    <p><em>{{ machine.type }}</em></p>
  </div>
  {% endfor %}
</div>

<script>
  function filterMachines() {
    const mfgFilter = document.getElementById('filter-manufacturer').value;
    const typeFilter = document.getElementById('filter-type').value;

    const cards = document.querySelectorAll('.machine-card');
    let visibleCount = 0;

    cards.forEach(card => {
      const mfg = card.dataset.manufacturer;
      const type = card.dataset.type;

      const mfgMatch = !mfgFilter || mfg === mfgFilter;
      const typeMatch = !typeFilter || type === typeFilter;

      if (mfgMatch && typeMatch) {
        card.style.display = '';
        visibleCount++;
      } else {
        card.style.display = 'none';
      }
    });

    document.getElementById('machine-count').textContent = visibleCount;
  }

  function clearFilters() {
    document.getElementById('filter-manufacturer').value = '';
    document.getElementById('filter-type').value = '';
    filterMachines();
  }
</script>
