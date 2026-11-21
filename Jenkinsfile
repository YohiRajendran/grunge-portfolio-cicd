pipeline {
    agent any
    tools {
        nodejs 'Node20'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
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
         stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=yohi \
                    -Dsonar.projectKey=yohi '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-server' 
                }
            } 
        }

        stage('Build Docker Image & Push') {
            steps {
                script {
                    
                
                withDockerRegistry(credentialsId: 'docker', url: 'https://index.docker.io/v1/'){
                sh '''
                    docker build -t grunge-portfolio:latest .
                    docker tag grunge-portfolio yoheswari/grunge-portfolio:latest
                    docker push yoheswari/grunge-portfolio:latest
                ''' }
                }
            }
        }
        

        stage('Deploy Container') {
            steps {
                sh '''
                    docker rm -f grunge-portfolio || true

                    docker run -d \
                        --name grunge-portfolio \
                        --restart unless-stopped \
                        -p 4321:4321 \
                        grunge-portfolio:latest
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    docker ps
                    docker logs --tail 20 grunge-portfolio
                '''
            }
        }
    }

    post {
        success {
            echo 'grunge-Portfolio deployed successfully!'
        }

        failure {
            echo 'Deployment failed. Check Jenkins console output.'
        }
    }
}
