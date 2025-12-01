<%@ page import="org.json.*, java.util.*" %>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>News App — Feature2</title>

  <!-- Bootstrap -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

  <style>
    body.dark { background:#0b1220; color:#e6eef8; }
    .card.dark { background:#0f1724; color: #e6eef8; border-color:#1f2a38; }
    .trending { gap: 8px; display:flex; flex-wrap:wrap; }
    .badge-tag { cursor:pointer; }
    .img-thumb { max-height:180px; object-fit:cover; width:100%; border-top-left-radius: .5rem; border-top-right-radius: .5rem; }
    .loading { display:none; text-align:center; padding:12px; color:#666; }
  </style>

  <script>
    // utilities
    function $(id){ return document.getElementById(id); }

    // persist theme
    function loadTheme(){
      const t = localStorage.getItem('theme') || 'light';
      if (t === 'dark') document.body.classList.add('dark');
    }
    function toggleTheme(){
      document.body.classList.toggle('dark');
      const now = document.body.classList.contains('dark') ? 'dark' : 'light';
      localStorage.setItem('theme', now);
    }

    // build query and fetch via AJAX
    let currentPage = 1;
    let currentQuery = 'india';
    let currentCategory = '';
    function fetchNews(reset){
      if (reset) currentPage = 1;
      const pageSize = 10;
      const q = encodeURIComponent(currentQuery);
      const url = `/news-data?q=${q}&category=${encodeURIComponent(currentCategory)}&page=${currentPage}&pageSize=${pageSize}`;

      $('loading').style.display = 'block';
      fetch(url).then(r => r.json()).then(json => {
        $('loading').style.display = 'none';
        const arr = json.articles || [];
        if (reset) $('news-list').innerHTML = '';
        if (arr.length === 0 && reset) {
          $('news-list').innerHTML = '<div class="text-center text-muted p-3">No news found for this query.</div>';
          $('updated').innerText = 'Updated: ' + new Date().toLocaleString();
          return;
        }
        arr.forEach(a => appendCard(a));
        $('updated').innerText = 'Updated: ' + new Date().toLocaleString();
        currentPage++;
      }).catch(err => {
        $('loading').style.display = 'none';
        $('news-list').innerHTML = '<div class="text-center text-danger p-3">Error loading news.</div>';
        console.error(err);
      });
    }

    function appendCard(a){
      const card = document.createElement('div');
      card.className = 'col-md-6 mb-3';
      const image = a.urlToImage ? `<img src="${a.urlToImage}" class="img-thumb" onerror="this.style.display=\\'none\\'">` : '';
      const desc = a.description ? a.description : '';
      const source = (a.source && a.source.name) ? a.source.name : '';
      const time = a.publishedAt ? new Date(a.publishedAt).toLocaleString() : '';
      card.innerHTML = `
        <div class="card ${document.body.classList.contains('dark') ? 'dark' : ''}">
          ${image}
          <div class="card-body">
            <h5 class="card-title">${escapeHtml(a.title)}</h5>
            <p class="card-text">${escapeHtml(desc)}</p>
            <div class="d-flex justify-content-between align-items-center">
              <small class="text-muted">${escapeHtml(source)} • ${escapeHtml(time)}</small>
              <a href="${a.url}" target="_blank" class="btn btn-sm btn-primary">Read</a>
            </div>
          </div>
        </div>`;
      $('news-list').appendChild(card);
    }

    function escapeHtml(s){
      if(!s) return '';
      return s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;');
    }

    // search
    function onSearch(e){
      e.preventDefault();
      const v = $('search-input').value.trim();
      currentQuery = v || 'india';
      currentCategory = '';
      fetchNews(true);
    }

    // category click
    function onCategory(cat){
      currentCategory = cat;
      currentQuery = cat;
      $('search-input').value = '';
      fetchNews(true);
    }

    // trending tags
    function onTag(tag){
      currentQuery = tag;
      currentCategory = '';
      $('search-input').value = tag;
      fetchNews(true);
    }

    // infinite scroll (load more when near bottom)
    window.addEventListener('scroll', () => {
      if ((window.innerHeight + window.scrollY) >= (document.body.offsetHeight - 300)) {
        fetchNews(false);
      }
    });

    // init
    window.addEventListener('load', () => {
      loadTheme();
      // default
      currentQuery = 'india';
      fetchNews(true);
      // trending tags (client-side)
      const tags = ['Elections','Cricket','AI','Movies','Startups'];
      const container = $('trending');
      tags.forEach(t => {
        const b = document.createElement('span');
        b.className = 'badge bg-secondary badge-tag';
        b.style.marginRight = '6px';
        b.style.cursor = 'pointer';
        b.onclick = () => onTag(t);
        b.innerText = t;
        container.appendChild(b);
      });
    });
  </script>
</head>
<body>

<div class="container py-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <div>
      <h3 class="m-0">📰 Feature2 — News</h3>
      <small id="updated" class="text-muted">Updated: --</small>
    </div>
    <div>
      <button class="btn btn-outline-secondary me-2" onclick="toggleTheme()">Toggle Dark</button>
      <a href="/news" class="btn btn-outline-primary">Refresh</a>
    </div>
  </div>

  <!-- Search -->
  <form onsubmit="onSearch(event)" class="input-group mb-3">
    <input id="search-input" type="text" class="form-control" placeholder="Search news or enter keyword...">
    <button class="btn btn-primary">Search</button>
  </form>

  <!-- Categories -->
  <div class="mb-3">
    <div class="btn-group" role="group">
      <button class="btn btn-outline-primary" onclick="onCategory('india')">India</button>
      <button class="btn btn-outline-primary" onclick="onCategory('technology')">Technology</button>
      <button class="btn btn-outline-primary" onclick="onCategory('sports')">Sports</button>
      <button class="btn btn-outline-primary" onclick="onCategory('business')">Business</button>
      <button class="btn btn-outline-primary" onclick="onCategory('health')">Health</button>
    </div>
  </div>

  <!-- Trending -->
  <div id="trending" class="trending mb-3"></div>

  <!-- Loading -->
  <div id="loading" class="loading">Loading news…</div>

  <!-- News list -->
  <div id="news-list" class="row"></div>

</div>

</body>
</html>
