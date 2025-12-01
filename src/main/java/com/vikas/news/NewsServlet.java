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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        URL url = new URL(baseUrl + apiKey);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder json = new StringBuilder();
        String line;

        while ((line = br.readLine()) != null) {
            json.append(line);
        }

        JSONObject jsonObj = new JSONObject(json.toString());
        JSONArray articles = jsonObj.getJSONArray("articles");

        List<String> headlines = new ArrayList<>();

        for (int i = 0; i < Math.min(10, articles.length()); i++) {
            String title = articles.getJSONObject(i).getString("title");
            headlines.add(title);
        }

        req.setAttribute("headlines", headlines);
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}
