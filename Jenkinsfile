pipeline {
    agent any

    options {
        cleanWs()
        timestamps()
        ansiColor('xterm') 
    }

    environment {
        DOCKER_IMAGE_NAME = "easyshop-mainapp"
        DOCKER_MIGRATION_IMAGE_NAME = "easyshop-migration"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Cloning Repo code"
                git branch: 'main', url: 'https://github.com/isthatyous/Infra-Pulse-Check.git'
                sh 'pwd'
                sh 'ls -la'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                scannerHome = tool 'SonarServer'
            }
            steps {
                withSonarQubeEnv(credentialsId: 'Sonar-Token', installationName: 'SonarQube Server') {
                    sh """
                    ${scannerHome}/bin/sonar-scanner \
                    -Dsonar.projectKey=easyshop \
                    -Dsonar.projectName="easyshop" \
                    -Dsonar.sources=.
                    """
                }
            }
        }

        stage('Build Docker Image & Scan with Trivy') {
            parallel {
                stage('Build Main App Image') {
                    steps {
                        echo "Building Main App docker image"
                        script {
                            docker.build("${DOCKER_IMAGE_NAME}:${IMAGE_TAG}", "-f Dockerfile .")
                        }
                    }
                }
                stage('Build Migration Image') {
                    steps {
                        echo "Building Migration image"
                        script {
                            docker.build("${DOCKER_MIGRATION_IMAGE_NAME}:${IMAGE_TAG}", "-f scripts/Dockerfile.migration .")
                        }
                    }
                }
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "dockerhub-token", usernameVariable: "DOCKERHUB_USERNAME", passwordVariable: "DOCKERHUB_PASSWORD")]) {
                    script {
                        sh "docker login -u ${DOCKERHUB_USERNAME} -p ${DOCKERHUB_PASSWORD}"

                        // Push Main App
                        def mainImage = "${DOCKERHUB_USERNAME}/${DOCKER_IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${IMAGE_TAG} ${mainImage}"
                        sh "docker push ${mainImage}"
                        sh "trivy image --format table -o trivy-report-mainapp.txt ${mainImage}"

                        // Push Migration App
                        def migrationImage = "${DOCKERHUB_USERNAME}/${DOCKER_MIGRATION_IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker tag ${DOCKER_MIGRATION_IMAGE_NAME}:${IMAGE_TAG} ${migrationImage}"
                        sh "docker push ${migrationImage}"
                        sh "trivy image --format table -o trivy-report-migrationapp.txt ${migrationImage}"
                    }
                }
            }
        }
    }
}
