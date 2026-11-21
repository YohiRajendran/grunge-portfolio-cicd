pipeline {
    agent any
    tools {
        nodejs 'Node20'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/YohiRajendran/grunge-portfolio-cicd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t yohi-portfolio:latest .
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    docker rm -f yohi-portfolio || true

                    docker run -d \
                        --name yohi-portfolio \
                        --restart unless-stopped \
                        -p 4321:4321 \
                        yohi-portfolio:latest
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    docker ps
                    docker logs --tail 20 yohi-portfolio
                '''
            }
        }
    }

    post {
        success {
            echo 'Yohi Portfolio deployed successfully!'
        }

        failure {
            echo 'Deployment failed. Check Jenkins console output.'
        }
    }
}
