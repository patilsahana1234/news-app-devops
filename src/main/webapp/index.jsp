<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Feature 2 News App-jfrog</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <style>
        body { background: linear-gradient(135deg, #0f172a, #1e293b); color: white; }
        .card {
            backdrop-filter: blur(8px);
            background: rgba(255,255,255,.08);
            border: 1px solid rgba(255,255,255,.1);
            transition: .3s;
        }
        .card:hover { transform: scale(1.03); }
        .category-btn { margin-right: 8px; margin-bottom: 8px; }
        .chip {
            padding: 5px 12px; background: #475569; border-radius: 20px;
            margin-right: 6px; cursor: pointer; transition: .2s;
        }
        .chip:hover { background: #64748b; }
        #loading { display: none; color: #f87171; }
    </style>

    <script>
        let page = 1;
        let query = "india";

        function $(id) { return document.getElementById(id); }

        function fetchNews(reset){
            if (reset) { page = 1; $("news").innerHTML = ""; }

            $("loading").style.display = "block";

            const url =
                "${pageContext.request.contextPath}/news-data?q=" +
                encodeURIComponent(query) +
                "&page=" + page;

            fetch(url)
                .then(r => r.json())
                .then(j => {
                    $("loading").style.display = "none";
                    j.articles.forEach(a => addCard(a));
                    page++;
                })
                .catch(() => {
                    $("loading").innerText = "Failed to load news!";
                    $("loading").style.display = "block";
                });
        }

        function addCard(a){
            const div = document.createElement("div");
            div.className = "col-md-6 mb-3";

            const img = a.urlToImage
                ? `<img src="${a.urlToImage}" class="img-fluid rounded-top"
                    onerror="this.style.display='none'">`
                : "";

            div.innerHTML = `
                <div class="card p-3">
                    ${img}
                    <h5 class="mt-3">${a.title || ""}</h5>
                    <p>${a.description || ""}</p>
                    <a href="${a.url}" class="btn btn-primary btn-sm" target="_blank">Read More</a>
                </div>
            `;

            $("news").appendChild(div);
        }

        function searchNews(e){
            e.preventDefault();
            query = $("search").value || "india";
            fetchNews(true);
        }

        function setCategory(cat){
            query = cat;
            $("search").value = "";
            fetchNews(true);
        }

        function setChip(tag){
            query = tag;
            $("search").value = tag;
            fetchNews(true);
        }

        window.onload = function(){ fetchNews(true); };
    </script>

</head>
<body>

<div class="container py-4">

    <h2 class="mb-4 text-center">📰 Feature 2 News App</h2>

    <form onsubmit="searchNews(event)" class="input-group mb-3">
        <input id="search" class="form-control" placeholder="Search news...">
        <button class="btn btn-primary">Search</button>
    </form>

    <div class="mb-3">
        <button class="btn btn-outline-light category-btn" onclick="setCategory('india')">India</button>
        <button class="btn btn-outline-light category-btn" onclick="setCategory('technology')">Technology</button>
        <button class="btn btn-outline-light category-btn" onclick="setCategory('sports')">Sports</button>
        <button class="btn btn-outline-light category-btn" onclick="setCategory('business')">Business</button>
        <button class="btn btn-outline-light category-btn" onclick="setCategory('health')">Health</button>
    </div>

    <div class="mb-4">
        <span class="chip" onclick="setChip('Cricket')">Cricket</span>
        <span class="chip" onclick="setChip('AI')">AI</span>
        <span class="chip" onclick="setChip('Movies')">Movies</span>
        <span class="chip" onclick="setChip('Startups')">Startups</span>
        <span class="chip" onclick="setChip('Politics')">Politics</span>
    </div>

    <div id="loading" class="text-center mb-3">Loading news...</div>

    <div class="row" id="news"></div>

</div>

</body>
</html>
