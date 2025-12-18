pipeline {

    agent any

    environment {
        MAVEN_HOME = tool 'M2_HOME'
        PATH = "${MAVEN_HOME}/bin:${env.PATH}"
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
    }

    post {
        success {
            echo '✅ Compilation réussie'
        }
        failure {
            echo '❌ Échec de compilation'
        }
    }
}

