package com.vikas.news;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import org.json.*;

import java.io.*;
import java.net.*;
import java.time.LocalDate;
import java.util.Properties;

public class NewsServlet extends HttpServlet {

    private String apiKey;
    private String baseUrl;

    @Override
    public void init() throws ServletException {
        try (InputStream in = getClass().getClassLoader().getResourceAsStream("config.properties")) {
            if (in == null) throw new ServletException("config.properties not found in resources");
            Properties p = new Properties();
            p.load(in);
            apiKey = p.getProperty("NEWS_API_KEY");
            baseUrl = p.getProperty("NEWS_URL");
            if (apiKey == null || apiKey.trim().isEmpty()) {
                throw new ServletException("NEWS_API_KEY not set in config.properties");
            }
            if (baseUrl == null) baseUrl = "https://newsapi.org/v2/everything?";
        } catch (IOException e) {
            throw new ServletException("Failed to load config.properties", e);
        }
    }

    // Helper to call NewsAPI and return JSONObject (full response)
    private JSONObject callNewsApi(String q, String from, String to, int page, int pageSize) throws IOException {
        StringBuilder sb = new StringBuilder(baseUrl);

        // q parameter
        sb.append("q=").append(URLEncoder.encode(q == null || q.isEmpty() ? "india" : q, "UTF-8"));
        // date filter
        if (from != null && !from.isEmpty()) sb.append("&from=").append(URLEncoder.encode(from, "UTF-8"));
        if (to != null && !to.isEmpty()) sb.append("&to=").append(URLEncoder.encode(to, "UTF-8"));
        sb.append("&sortBy=publishedAt");
        sb.append("&page=").append(page);
        sb.append("&pageSize=").append(pageSize);
        sb.append("&apiKey=").append(URLEncoder.encode(apiKey, "UTF-8"));

        URL url = new URL(sb.toString());
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        int rc = conn.getResponseCode();
        InputStream is = (rc >= 200 && rc < 300) ? conn.getInputStream() : conn.getErrorStream();

        BufferedReader br = new BufferedReader(new InputStreamReader(is));
        StringBuilder resp = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) resp.append(line);
        br.close();

        return new JSONObject(resp.toString());
    }

    // Serve main page
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String servletPath = req.getServletPath(); // "/news" or "/news-data"
        if ("/news-data".equals(servletPath)) {
            handleNewsData(req, resp);
            return;
        }

        // render index.jsp
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }

    // AJAX endpoint: returns JSON (articles array + meta)
    private void handleNewsData(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String q = req.getParameter("q");
        String category = req.getParameter("category"); // will be used as query part if present
        String query = (q != null && !q.isEmpty()) ? q : (category != null && !category.isEmpty() ? category : "india");

        String from = req.getParameter("from"); // YYYY-MM-DD or null
        String to = req.getParameter("to");
        if (from == null || from.isEmpty()) {
            String today = LocalDate.now().toString();
            from = today;
            to = today;
        }

        int page = 1;
        int pageSize = 10;
        try {
            page = Integer.parseInt(req.getParameter("page") == null ? "1" : req.getParameter("page"));
            pageSize = Integer.parseInt(req.getParameter("pageSize") == null ? "10" : req.getParameter("pageSize"));
        } catch (NumberFormatException ignored) { }

        JSONObject result;
        try {
            result = callNewsApi(query, from, to, page, pageSize);
            // normalize response: return articles array and status/message
            JSONObject out = new JSONObject();
            out.put("status", result.optString("status", "error"));
            out.put("totalResults", result.optInt("totalResults", 0));
            out.put("articles", result.optJSONArray("articles") == null ? new JSONArray() : result.getJSONArray("articles"));
            writeJson(resp, out);
        } catch (IOException e) {
            JSONObject out = new JSONObject();
            out.put("status", "error");
            out.put("message", e.getMessage());
            out.put("articles", new JSONArray());
            writeJson(resp, out);
        }
    }

    private void writeJson(HttpServletResponse resp, JSONObject obj) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(obj.toString());
    }
}
