pipeline {

    agent any

    environment {
        MAVEN_HOME = tool 'M2_HOME'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"
        DOCKER_IMAGE = "oussemaaaaaa/student-management"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Clean') {
            steps {
                sh 'mvn clean'
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:latest .'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_IMAGE:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    echo "🚀 Déploiement Kubernetes..."

                    kubectl apply -f k8s/mysql-pvc.yaml
                    kubectl apply -f k8s/mysql-deployment.yaml
                    kubectl apply -f k8s/mysql-service.yaml

                    kubectl apply -f k8s/spring-deployment.yaml
                    kubectl apply -f k8s/spring-service.yaml
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Build, Push Docker & Déploiement Kubernetes réussis'
        }
    }
}

