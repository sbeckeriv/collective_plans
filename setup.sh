#!/usr/bin/env bash
# setup.sh - Jekyll Pinball Database Setup

set -e  # Exit immediately on error

# --- Colors ---
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

PROJECT="pinball-db"

echo ""
info "Setting up Jekyll Pinball Database: '$PROJECT'"
echo ""

# --- Preflight checks ---
command -v ruby  &>/dev/null || error "Ruby not found. Install it first: https://jekyllrb.com/docs/installation/"
command -v gem   &>/dev/null || error "RubyGems not found."
command -v git   &>/dev/null || error "Git not found."

RUBY_VER=$(ruby -e 'puts RUBY_VERSION')
info "Ruby version: $RUBY_VER"

# --- Install Jekyll & Bundler ---
info "Installing Bundler and Jekyll..."
gem install bundler jekyll --no-document

# --- Create project dir ---
[ -d "$PROJECT" ] && warn "Directory '$PROJECT' already exists. Continuing inside it." || mkdir "$PROJECT"
cd "$PROJECT"

# --- Folder structure ---
info "Creating folder structure..."
mkdir -p _pinball
mkdir -p _layouts
mkdir -p _includes
mkdir -p assets/images/pinball
mkdir -p assets/css
mkdir -p .github/workflows

# ============================================================
# Gemfile
# ============================================================
info "Writing Gemfile..."
cat > Gemfile << 'EOF'
source "https://rubygems.org"

gem "jekyll", "~> 4.3"
gem "minima", "~> 2.5"

group :jekyll_plugins do
  gem "jekyll-paginate-v2"
  gem "jekyll-seo-tag"
  gem "jekyll-sitemap"
end
EOF

# ============================================================
# _config.yml
# ============================================================
info "Writing _config.yml..."
cat > _config.yml << 'EOF'
title: Pinball Database
description: A catalogue of pinball machines spanning decades of history.
baseurl: ""
url: ""   # e.g. https://yourusername.github.io

theme: minima

# --- Collection ---
collections:
  pinball:
    output: true
    permalink: /pinball/:slug/

# --- Default front matter for all machines ---
defaults:
  - scope:
      path: ""
      type: pinball
    values:
      layout: machine

# --- Pagination (jekyll-paginate-v2) ---
pagination:
  enabled: true
  collection: pinball
  per_page: 24
  sort_field: title
  sort_reverse: false
  trail:
    before: 2
    after: 2

# --- Plugins ---
plugins:
  - jekyll-paginate-v2
  - jekyll-seo-tag
  - jekyll-sitemap

minima:
  skin: classic
EOF

# ============================================================
# index.md
# ============================================================
info "Writing index.md..."
cat > index.md << 'EOF'
---
layout: home
title: Pinball Database
---

Welcome to the Pinball Database. Browse hundreds of machines spanning
electromechanical classics to modern LCD games.

[Browse All Machines](/pinball/){: .btn}
EOF

# ============================================================
# pinball.html  (paginated listing page)
# ============================================================
info "Writing pinball.html..."
cat > pinball.html << 'EOF'
---
layout: default
title: All Pinball Machines
pagination:
  enabled: true
  collection: pinball
  per_page: 24
  sort_field: title
  sort_reverse: false
---

<h1>All Pinball Machines</h1>
<p>{{ site.pinball.size }} machines in the database.</p>

<div class="machine-grid">
  {% for machine in paginator.documents %}
  <div class="machine-card">
    {% if machine.image %}
      <img src="{{ machine.image }}" alt="{{ machine.title }}" loading="lazy">
    {% endif %}
    <h2><a href="{{ machine.url }}">{{ machine.title }}</a></h2>
    <p><strong>{{ machine.manufacturer }}</strong> &bull; {{ machine.year }}</p>
    <p><em>{{ machine.type }}</em></p>
  </div>
  {% endfor %}
</div>

{% if paginator.total_pages > 1 %}
<nav class="pagination" aria-label="Page navigation">
  {% if paginator.previous_page %}
    <a href="{{ paginator.previous_page_path }}">&laquo; Previous</a>
  {% endif %}

  {% for page in paginator.page_trail %}
    {% if page.num == paginator.page %}
      <strong>{{ page.num }}</strong>
    {% else %}
      <a href="{{ page.path }}">{{ page.num }}</a>
    {% endif %}
  {% endfor %}

  {% if paginator.next_page %}
    <a href="{{ paginator.next_page_path }}">Next &raquo;</a>
  {% endif %}
</nav>
{% endif %}
EOF

# ============================================================
# _layouts/machine.html  (individual machine page)
# ============================================================
info "Writing _layouts/machine.html..."
cat > _layouts/machine.html << 'EOF'
---
layout: default
---

<article class="machine">
  <h1>{{ page.title }}</h1>

  {% if page.image %}
    <img src="{{ page.image }}" alt="{{ page.title }}" class="machine-cover">
  {% endif %}

  <table class="machine-meta">
    <tbody>
      <tr><th>Manufacturer</th><td>{{ page.manufacturer }}</td></tr>
      <tr><th>Year</th>        <td>{{ page.year }}</td></tr>
      <tr><th>Type</th>        <td>{{ page.type }}</td></tr>
      {% if page.designer %}<tr><th>Designer</th>  <td>{{ page.designer }}</td></tr>{% endif %}
      {% if page.artist %}  <tr><th>Artist</th>    <td>{{ page.artist }}</td></tr>{% endif %}
      {% if page.players %} <tr><th>Players</th>   <td>{{ page.players }}</td></tr>{% endif %}
      {% if page.theme %}   <tr><th>Theme</th>     <td>{{ page.theme }}</td></tr>{% endif %}
      {% if page.ipdb_id %}
        <tr>
          <th>IPDB</th>
          <td><a href="https://www.ipdb.org/machine.cgi?id={{ page.ipdb_id }}" target="_blank" rel="noopener">View on IPDB &rarr;</a></td>
        </tr>
      {% endif %}
    </tbody>
  </table>

  {% if page.features %}
  <div class="machine-features">
    <h3>Features</h3>
    <ul>
      {% for f in page.features %}<li>{{ f }}</li>{% endfor %}
    </ul>
  </div>
  {% endif %}

  <div class="machine-description">
    {{ content }}
  </div>
</article>

<p><a href="/pinball/">&larr; Back to all machines</a></p>
EOF

# ============================================================
# assets/css/custom.css  (basic mobile-friendly card grid)
# ============================================================
info "Writing assets/css/custom.css..."
cat > assets/css/custom.css << 'EOF'
/* Machine grid - responsive card layout */
.machine-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1.25rem;
  margin: 1.5rem 0;
}

.machine-card {
  border: 1px solid #ddd;
  border-radius: 6px;
  padding: 0.75rem;
  background: #fff;
}

.machine-card img {
  width: 100%;
  height: 180px;
  object-fit: cover;
  border-radius: 4px;
  margin-bottom: 0.5rem;
}

.machine-card h2 {
  font-size: 1rem;
  margin: 0 0 0.25rem;
}

/* Machine detail page */
.machine-cover {
  max-width: 320px;
  width: 100%;
  border-radius: 6px;
  margin-bottom: 1rem;
}

.machine-meta {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1.5rem;
}

.machine-meta th,
.machine-meta td {
  text-align: left;
  padding: 0.4rem 0.75rem;
  border-bottom: 1px solid #eee;
}

.machine-meta th {
  width: 140px;
  color: #555;
  font-weight: 600;
}

/* Pagination */
.pagination {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin: 2rem 0;
  align-items: center;
}

.pagination a,
.pagination strong {
  padding: 0.35rem 0.7rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  text-decoration: none;
}

.pagination strong {
  background: #333;
  color: #fff;
  border-color: #333;
}

/* Mobile tweaks */
@media (max-width: 600px) {
  .machine-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  }
}
EOF

# ============================================================
# Sample machine: _pinball/addams-family.md
# ============================================================
info "Writing sample machine file: _pinball/addams-family.md..."
cat > _pinball/addams-family.md << 'EOF'
---
title: "The Addams Family"
manufacturer: Bally
year: 1992
designer: Pat Lawlor
artist: Python Anghelo
type: DMD
theme: Movies
players: 4
ipdb_id: 20
features:
  - multiball
  - ramps
  - bear kicks
  - thing magnet
  - mansion modes
image: /assets/images/pinball/addams-family.jpg
---

The Addams Family is the best-selling pinball machine of all time, with over
20,000 units produced. Designed by Pat Lawlor for Bally in 1992, it features
characters and modes inspired by the Addams Family franchise.
EOF

# ============================================================
# GitHub Actions deploy workflow
# (needed because jekyll-paginate-v2 is not whitelisted on GH Pages)
# ============================================================
info "Writing .github/workflows/deploy.yml..."
cat > .github/workflows/deploy.yml << 'EOF'
name: Build and Deploy Jekyll Site

on:
  push:
    branches:
      - main

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: "3.3"
          bundler-cache: true

      - name: Configure GitHub Pages
        id: pages
        uses: actions/configure-pages@v5

      - name: Build Jekyll site
        run: bundle exec jekyll build --baseurl "${{ steps.pages.outputs.base_path }}"
        env:
          JEKYLL_ENV: production

      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v3

  deploy:
    runs-on: ubuntu-latest
    needs: build
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
EOF

# ============================================================
# .gitignore
# ============================================================
info "Writing .gitignore..."
cat > .gitignore << 'EOF'
_site/
.sass-cache/
.jekyll-cache/
.jekyll-metadata
vendor/
.bundle/
EOF

# ============================================================
# Bundle install
# ============================================================
info "Running bundle install..."
bundle install

# ============================================================
# Git init
# ============================================================
if [ ! -d ".git" ]; then
  info "Initialising git repository..."
  git init
  git add .
  git commit -m "Initial Jekyll pinball database setup"
fi

# ============================================================
# Done
# ============================================================
echo ""
info "============================================"
info " Setup complete!"
info "============================================"
echo ""
info " Project directory : $(pwd)"
echo ""
info " Preview locally:"
info "   cd $PROJECT"
info "   bundle exec jekyll serve"
info "   open http://localhost:4000"
echo ""
info " Deploy to GitHub Pages:"
info "   1. Create a repo on GitHub"
info "   2. git remote add origin <your-repo-url>"
info "   3. git push -u origin main"
info "   4. Go to Settings -> Pages -> Source -> GitHub Actions"
echo ""
info " Add your machines to: _pinball/<machine-name>.md"
info " See _pinball/addams-family.md as a template."
echo ""

