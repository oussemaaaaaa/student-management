pipeline {

    agent any

    environment {
        JAVA_HOME = tool 'JAVA_HOME'
        MAVEN_HOME = tool 'M2_HOME'
        PATH = "${MAVEN_HOME}/bin:${JAVA_HOME}/bin:${env.PATH}"
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

