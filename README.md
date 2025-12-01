📄 README.md (Feature 1)
Real-Time News App — Feature 1 Release
📰 Real-Time News App (Feature 1)

This branch delivers Feature 1 of the Real-Time News Application.
It includes a fully working Java web app built with:

Servlet (Jakarta 5)

JSP

Maven (WAR packaging)

Tomcat 10

NewsAPI (Free “everything” endpoint)

The UI auto-refreshes, shows today’s news, and includes a clean, modern layout using plain CSS.

✨ Feature 1 – What’s Included
✔ Fetch Real-Time News

The servlet fetches news from NewsAPI using the /v2/everything endpoint.

✔ Auto-Refresh

The page refreshes automatically every 30 seconds to show fresh headlines.

✔ Today’s News Only

Backend filters news by today’s date using:

from=<today>&to=<today>


If today’s news is empty, it falls back to last 7 days.

✔ Clean Modern UI

Index page uses:

Card-based layout

Hover animations

Centered header

Responsive layout

Timestamp indicator

✔ Externalized API Key

config.properties stores the API key:

NEWS_API_KEY=<your_key>
NEWS_URL=https://newsapi.org/v2/everything?q=

✔ Error Handling

If no news found → clean fallback text
If API returns error → servlet does not crash

📂 Project Structure
src/main/java/com/vikas/news/NewsServlet.java
src/main/resources/config.properties
src/main/webapp/index.jsp
src/main/webapp/WEB-INF/web.xml
pom.xml

🛠 Installation & Setup (Ubuntu)
1. Install Java 17 and Maven
sudo apt update
sudo apt install openjdk-17-jdk maven -y

2. Verify:
java -version
mvn -version

🌐 Add Your NewsAPI Key

Edit the file:

src/main/resources/config.properties


Add:

NEWS_API_KEY=YOUR_NEWSAPI_KEY
NEWS_URL=https://newsapi.org/v2/everything?q=

🏗 Build the Project (Generate WAR)
mvn clean package


WAR file will be created at:

target/news-app.war

🐱‍🏍 Install Tomcat 10 (Ubuntu 22/24)
cd /opt
sudo wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.30/bin/apache-tomcat-10.1.30.tar.gz
sudo tar -xzf apache-tomcat-10.1.30.tar.gz
sudo mv apache-tomcat-10.1.30 tomcat10
sudo chmod +x /opt/tomcat10/bin/*.sh


Start Tomcat:

sudo /opt/tomcat10/bin/startup.sh

🚀 Deploy to Tomcat
sudo rm -rf /opt/tomcat10/webapps/news-app
sudo rm /opt/tomcat10/webapps/news-app.war
sudo cp target/news-app.war /opt/tomcat10/webapps/
sudo /opt/tomcat10/bin/shutdown.sh
sudo /opt/tomcat10/bin/startup.sh

🔎 Access the Application
http://<server-ip>:8080/news-app/news

🎉 Feature 1 Delivered
