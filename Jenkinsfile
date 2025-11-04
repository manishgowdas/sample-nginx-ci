pipeline {
    agent any
    options {
        disableConcurrentBuilds()
    }

    environment {
        AWS_REGION = 'ap-northeast-3'
        ECR_REPO = '373317459084.dkr.ecr.ap-northeast-3.amazonaws.com/myapp-repo'
        IMAGE_NAME = 'myapp'
        IMAGE_TAG = "v${BUILD_NUMBER}"
        GIT_CREDENTIALS_ID = 'githubrepo'
        AWS_CREDENTIALS_ID = 'aws-creds'
        SKIP_COMMITTER = "Jenkins CI"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/manishgowdas/sample-nginx-ci.git',
                    credentialsId: "${GIT_CREDENTIALS_ID}"
            }
        }

        stage('Build Docker Image') {
            steps {
                withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${AWS_REGION}") {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REPO}:latest
                    """
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${AWS_REGION}") {
                    sh """
                        docker push ${ECR_REPO}:${IMAGE_TAG}
                        docker push ${ECR_REPO}:latest
                    """
                }
            }
        }

        stage('Update Helm Chart') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'githubrepo', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
                    sh '''
                        echo "Updating Helm values.yaml with new image tag..."
                        sed -i "s|tag: .*|tag: ${IMAGE_TAG}|g" helm/myapp/values.yaml
                        git config --global user.email "jenkins@ci.local"
                        git config --global user.name "Jenkins CI"
                        git add helm/myapp/values.yaml
                        git commit -m "Update image tag to ${IMAGE_TAG}" || echo "No changes to commit"
                        git push https://${GIT_USER}:${GIT_PASS}@github.com/manishgowdas/sample-nginx-ci.git HEAD:main
                    '''
                }
            }
        }
    }  

    post {
        success {
            echo "CI Pipeline completed. ArgoCD will auto-sync the new image."
        }
        failure {
            echo "CI Pipeline failed. Please check Jenkins logs."
        }
    }
}
