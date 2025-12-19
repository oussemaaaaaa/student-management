pipeline {

    agent any

    environment {
        // Maven
        MAVEN_HOME = tool 'M2_HOME'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"

        // Docker
        DOCKER_IMAGE = "oussemaaaaaa/student-management"

        // SonarQube
        SONARQUBE_SERVER = "SonarQube-K8s"
    }

    stages {

        /* ========================= */
        /*        CHECKOUT           */
        /* ========================= */
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        /* ========================= */
        /*           CLEAN           */
        /* ========================= */
        stage('Clean') {
            steps {
                sh 'mvn clean'
            }
        }

        /* ========================= */
        /*          COMPILE          */
        /* ========================= */
        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }

        /* ========================= */
        /*          PACKAGE          */
        /* ========================= */
        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        /* ========================= */
        /*       SONARQUBE           */
        /* ========================= */
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh '''
                      mvn sonar:sonar \
                      -Dsonar.projectKey=student-management \
                      -Dsonar.projectName=student-management \
                      -Dsonar.java.binaries=target
                    '''
                }
            }
        }

        /* ========================= */
        /*      BUILD DOCKER         */
        /* ========================= */
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:latest .'
            }
        }

        /* ========================= */
        /*      PUSH DOCKER          */
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
                        docker push $DOCKER_IMAGE:latest
                    '''
                }
            }
        }

        /* ========================= */
        /*   DEPLOY KUBERNETES       */
        /* ========================= */
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                  echo "🚀 Déploiement Kubernetes..."

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
            echo '✅ Build, SonarQube, Docker & Déploiement Kubernetes réussis'
        }
        failure {
            echo '❌ Pipeline échoué'
        }
    }
}

