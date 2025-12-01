package com.vikas.news;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

public class NewsServlet extends HttpServlet {

    private String apiKey;
    private String baseUrl;

    @Override
    public void init() throws ServletException {
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("config.properties")) {

            if (input == null) {
                throw new ServletException("config.properties not found.");
            }

            Properties props = new Properties();
            props.load(input);

            apiKey = props.getProperty("NEWS_API_KEY");
            baseUrl = props.getProperty("NEWS_URL");

        } catch (IOException e) {
            throw new ServletException("Error loading config.properties", e);
        }
    }

    private List<String> fetchNews(String fromDate, String toDate) throws IOException {

        String finalUrl = baseUrl + apiKey +
                "&from=" + fromDate +
                "&to=" + toDate +
                "&sortBy=publishedAt";

        URL url = new URL(finalUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder json = new StringBuilder();
        String line;

        while ((line = br.readLine()) != null) {
            json.append(line);
        }

        JSONObject jsonObj = new JSONObject(json.toString());
        JSONArray articles = jsonObj.optJSONArray("articles");

        List<String> headlines = new ArrayList<>();
        if (articles == null) return headlines;

        for (int i = 0; i < Math.min(10, articles.length()); i++) {
            headlines.add(articles.getJSONObject(i).getString("title"));
        }

        return headlines;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        LocalDate today = LocalDate.now();
        String todayStr = today.toString();

        // Fetch today's news first
        List<String> headlines = fetchNews(todayStr, todayStr);

        // If no news found, fetch last 7 days
        if (headlines.isEmpty()) {
            LocalDate weekAgo = today.minusDays(7);
            headlines = fetchNews(weekAgo.toString(), todayStr);

            req.setAttribute("date", weekAgo + " to " + todayStr);
        } else {
            req.setAttribute("date", todayStr);
        }

        req.setAttribute("headlines", headlines);
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}
