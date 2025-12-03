pipeline {
    agent any
    
    stages {

        stage('Check & Install Java') {
            steps {
                sh '''
                    echo "=== Checking Java ==="
                    if java -version >/dev/null 2>&1; then
                        echo "Java already installed"
                        java -version
                    else
                        echo "Installing Java 17..."
                        sudo apt update -y
                        sudo apt install -y openjdk-17-jdk
                        java -version
                    fi
                '''
            }
        }

        stage('Check & Install Maven') {
            steps {
                sh '''
                    echo "=== Checking Maven ==="
                    if mvn -version >/dev/null 2>&1; then
                        echo "Maven already installed"
                        mvn -version
                    else
                        echo "Installing Maven..."
                        sudo apt install -y maven
                        mvn -version
                    fi
                '''
            }
        }

        stage('Check & Install Tomcat 10') {
            steps {
                sh '''
                    echo "=== Checking Tomcat ==="
                    if [ -d "/opt/tomcat10" ]; then
                        echo "Tomcat already installed in /opt/tomcat10"
                    else
                        echo "Installing Tomcat 10..."
                        cd /opt
                        sudo wget https://archive.apache.org/dist/tomcat/tomcat-10/v10.1.30/bin/apache-tomcat-10.1.30.tar.gz
                        sudo tar -xzf apache-tomcat-10.1.30.tar.gz
                        sudo mv apache-tomcat-10.1.30 /opt/tomcat10
                        sudo chmod +x /opt/tomcat10/bin/*.sh
                    fi
                '''
            }
        }

        stage('Build WAR File') {
            steps {
                sh '''
                    echo "=== Building WAR ==="
                    mvn clean package -DskipTests
                '''
            }
        }

        stage('Deploy WAR to Tomcat') {
            steps {
                sh '''
                    echo "=== Stopping Tomcat ==="
                    sudo /opt/tomcat10/bin/shutdown.sh || true

                    echo "=== Removing old deployment ==="
                    sudo rm -rf /opt/tomcat10/webapps/news-app
                    sudo rm -f /opt/tomcat10/webapps/news-app.war

                    echo "=== Deploying new WAR ==="
                    sudo cp target/news-app.war /opt/tomcat10/webapps/

                    echo "=== Starting Tomcat ==="
                    sudo /opt/tomcat10/bin/startup.sh
                '''
            }
        }
    }

    post {
        success {
            echo "Deployment completed successfully!"
        }
        failure {
            echo "Deployment failed!"
        }
    }
}
