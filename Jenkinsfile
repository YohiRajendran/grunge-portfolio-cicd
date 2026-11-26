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
        
        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([
                    credentialsId: 'k8s-kubeconfig'
                ]) {
                    sh '''
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
        
                        kubectl rollout restart deployment/grunge-portfolio -n myapp
        
                        kubectl rollout status deployment/grunge-portfolio \
                            -n myapp --timeout=120s
                    '''
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                withKubeConfig([
                    credentialsId: 'k8s-kubeconfig'
                ]) {
                    sh '''
                        kubectl get deployments -n myapp
                        kubectl get pods -n myapp -o wide
                        kubectl get services -n myapp
                    '''
                }
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
