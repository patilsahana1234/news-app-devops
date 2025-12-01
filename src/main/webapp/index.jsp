<html>
<body>
    <h2>Latest News (India)</h2>

    <ul>
        <% 
            java.util.List<String> headlines = (java.util.List<String>) request.getAttribute("headlines");
            for (String h : headlines) { 
        %>
            <li><%= h %></li>
        <% 
            } 
        %>
    </ul>

</body>
</html>

