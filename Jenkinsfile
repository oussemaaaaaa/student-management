pipeline {

    agent any

    tools {
        maven 'M2_HOME'
    }

    environment {
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

        stage('Wait for SonarQube') {
            steps {
                sh '''
                  echo "⏳ Waiting for SonarQube..."
                  until curl -s http://192.168.49.2:30090/api/system/status | grep -q '"status":"UP"'; do
                    sleep 10
                  done
                  echo "✅ SonarQube is UP"
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-K8s') {
                    sh '''
                      mvn sonar:sonar \
                      -Dsonar.projectKey=student-management \
                      -Dsonar.projectName=student-management \
                      -Dsonar.java.binaries=target \
                      -Dsonar.ws.timeout=300 \
                      -Dsonar.ce.task.timeout=300 || true
                    '''
                }
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
                  echo "🚀 Deploying to Kubernetes..."
                  kubectl apply -f k8s/mysql-pvc.yaml --validate=false
                  kubectl apply -f k8s/mysql-deployment.yaml --validate=false
                  kubectl apply -f k8s/mysql-service.yaml --validate=false
                  kubectl apply -f k8s/spring-deployment.yaml --validate=false
                  kubectl apply -f k8s/spring-service.yaml --validate=false
                '''
            }
        }
    }

    post {
        success {
            echo '✅ PIPELINE DEVOPS TERMINÉ AVEC SUCCÈS'
        }
        failure {
            echo '❌ PIPELINE ÉCHOUÉ'
        }
    }
}

