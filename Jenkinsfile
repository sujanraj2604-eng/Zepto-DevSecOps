
pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                echo 'Checkout Zepto source code'
                checkout scm
            }
        }

        stage('SonarQube Code Analysis') {
            steps {
                echo 'SonarQube analysis'
            }
        }

        stage('OWASP Dependency Scan') {
            steps {
                echo 'OWASP dependency scan'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Build Docker image'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                echo 'Trivy image scan'
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Push image to Docker Hub'
            }
        }

        stage('Terraform Infrastructure') {
            steps {
                echo 'Terraform infrastructure'
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo 'Deploy application to EC2'
            }
        }
    }
}

