pipeline {

    agent any

    environment {
        // Maven
        MAVEN_HOME = tool 'M2_HOME'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"

        // Docker
        DOCKER_IMAGE = "oussemaaaaaa/student-management"

        // SonarQube
        SONAR_PROJECT_KEY = "student-management"
        SONAR_PROJECT_NAME = "student-management"
    }

    stages {

        /* ========================= */
        /*         CHECKOUT          */
        /* ========================= */
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        /* ========================= */
        /*           BUILD           */
        /* ========================= */
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

        /* ========================= */
        /*     WAIT FOR SONARQUBE    */
        /* ========================= */
        stage('Wait for SonarQube') {
            steps {
                sh '''
                  echo "⏳ Waiting for SonarQube to be ready..."
                  until curl -s http://192.168.49.2:30090/api/system/status | grep -q '"status":"UP"'; do
                    echo "SonarQube not ready yet..."
                    sleep 10
                  done
                  echo "✅ SonarQube is UP"
                '''
            }
        }

        /* ========================= */
        /*     SONARQUBE ANALYSIS    */
        /* ========================= */
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-K8s') {
                    sh '''
                      mvn sonar:sonar \
                      -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                      -Dsonar.projectName=${SONAR_PROJECT_NAME} \
                      -Dsonar.java.binaries=target \
                      -Dsonar.ws.timeout=120
                    '''
                }
            }
        }

        /* ========================= */
        /*      DOCKER BUILD         */
        /* ========================= */
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE}:latest .'
            }
        }

        /* ========================= */
        /*      DOCKER PUSH          */
        /* ========================= */
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }

        /* ========================= */
        /*   DEPLOY TO KUBERNETES    */
        /* ========================= */
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                echo "🚀 Deploying to Kubernetes..."

          	kubectl apply --validate=false -f k8s/mysql-pvc.yaml
                kubectl apply --validate=false -f k8s/mysql-deployment.yaml
                kubectl apply --validate=false -f k8s/mysql-service.yaml

                kubectl apply --validate=false -f k8s/spring-deployment.yaml
                kubectl apply --validate=false -f k8s/spring-service.yaml
                '''
            }
        }        
        
    }

    post {
        success {
            echo '✅ Pipeline Jenkins terminé avec SUCCÈS'
        }
        failure {
            echo '❌ Pipeline Jenkins ÉCHOUÉ'
        }
    }
}

