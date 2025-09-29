pipeline {
  
  agent any;
  
    environment {
        DOCKER_IMAGE_NAME = "easyshop-mainapp"
        DOCKER_MIGRATION_IMAGE_NAME = "easyshop-migration"
        IMAGE_TAG = "${BUILD_NUMBER}"
        
    }


    stages {
        
        stage('Clean Workspace'){
            steps{
                cleanWs()
                echo "Workspace cleaned succesfully"
            }
        }
        stage('Checkout') {
            steps {
                echo "Cloning Repo code"
                git branch: 'master', url: 'https://github.com/devopsdock0125/tws-e-commerce-app_hackathon.git'
                sh 'pwd'
                sh 'ls -la'
            }
        }
        
        stage('SonarQube Analysis'){
            environment{
                scannerHome = tool 'SonarServer'
            }
            steps{
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

        stage('Build Docker Image') {
            parallel {
                stage('Build Main App Image') {
                    steps {
                        echo "Starting to build Main App docker image"
                        script{
                            def dockerfile = 'Dockerfile'
                            docker.build("${DOCKER_IMAGE_NAME}:${IMAGE_TAG}","-f ${dockerfile} .")
                             
                        }
                    }
                }
                stage('Build Migration Image') {
                    steps {
                        echo "Starting to build Migration image"
                        script{
                            def dockerfile = "scripts/Dockerfile.migration"
                            docker.build("${DOCKER_MIGRATION_IMAGE_NAME}:${IMAGE_TAG}","-f ${dockerfile} .")
                        }
                    }
                }
            }
        }
        
        stage('Push Image to DockerHub'){
            parallel{
                stage('DockerHub-login'){
                    steps{
                        withcredentials([usernamePassword(credentialsID: "dockerhub-token" ,usernameVariable:"DOCKERHUB_USERNAME", passwordVariable: "DOCKERHUB_PASSWORD")])
                        sh "docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASSWORD"
                        echo "Login Complete"
                    }
                }
                stage('Push Main App Image'){
                    steps{
                        sh "docker image tag ${MainAppImage} ${DOCKERHUB_USERNAME}/${MainAppImage}"
                        sh "docker push image $MainAppImage"
                    }
                }
                    
                stage('Push Migration Image'){
                    steps{
                        sh "docker image tag ${MigrationImage} ${DOCKERHUB_USERNAME}/${MigrationImage}"
                        sh "docker push image $MigrationImange"
                        
                    }
                }
            }
        }
    
    
}
}
