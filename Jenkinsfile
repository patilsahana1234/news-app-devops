pipeline {
    agent any

    tools {
        jdk 'Java17'
        maven 'Maven3'
    }

    stages {
        
        stage('Check Java') {
            steps {
                sh 'java -version'
            }
        }

        stage('Check Maven') {
            steps {
                sh 'mvn -version'
            }
        }

        stage('Build WAR File') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Deploy WAR to Tomcat') {
            steps {
                sh '''
                    /opt/tomcat10/bin/shutdown.sh || true
                    rm -rf /opt/tomcat10/webapps/news-app
                    rm -f /opt/tomcat10/webapps/news-app.war
                    cp target/news-app.war /opt/tomcat10/webapps/
                    /opt/tomcat10/bin/startup.sh
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
