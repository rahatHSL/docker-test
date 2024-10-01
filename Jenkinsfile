pipeline {
    agent { label 'fwb-test' }
    environment {
        IMAGE_REPO_NAME = "fwb-ui"
        BUILD_TAG = "1.1"
        REMOTE_HOST = "ubuntu@54.254.21.104"
        REMOTE_PATH = "/home/ubuntu/fwb-ui"
        SSH_KEY_ID = "fwb-keypair"  
        GIT_REPO_URL = "https://github.com/rahatHSL/docker-test.git" 
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: "${GIT_REPO_URL}"
            }
        }
        
        stage('Data Sync') {
            steps {
                script {
                    // Debug information
                    sh 'pwd'
                    sh 'hostname'
                    sh 'ls -la ./'
                    
                    withCredentials([sshUserPrivateKey(credentialsId: "${SSH_KEY_ID}", keyFileVariable: 'SSH_KEY')]) {
                        sh "ssh -o StrictHostKeyChecking=no -i ${SSH_KEY} ${REMOTE_HOST} 'rm -rf ${REMOTE_PATH}/src'"
                        
                        sh "rsync -az -e 'ssh -i ${SSH_KEY}' ./src ${REMOTE_HOST}:${REMOTE_PATH}/"
                        sh "rsync -az -e 'ssh -i ${SSH_KEY}' ./package.json ${REMOTE_HOST}:${REMOTE_PATH}/"
                    }
                }
            }
        }

        stage('Build Image') {
            agent { label 'fwb-test' }
            options { skipDefaultCheckout() }
            steps {
                sh "cd ${REMOTE_PATH} && sudo docker build -t ${IMAGE_REPO_NAME}:${BUILD_TAG} ."
            }
        }

        stage('Container Deployment') {
            agent { label 'fwb-test' }
            options { skipDefaultCheckout() }
            steps {
                sh "cd ${REMOTE_PATH} && sed -i 's|image: .*|image: ${IMAGE_REPO_NAME}:${BUILD_TAG}|' docker-compose.yml"
                sh "cd ${REMOTE_PATH} && sudo docker compose up -d --remove-orphans"
            }
        }

        stage('Container Log Analysis') {
            agent { label 'fwb-test' }
            options { skipDefaultCheckout() }
            steps {
                sh "cd ${REMOTE_PATH} && sudo docker compose logs --tail=100"
                echo 'Deployment Successful...!'
            }
        }
    }
}
