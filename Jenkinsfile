pipeline {
    agent any
    environment {
        AWS_REGION = 'ap-northeast-3'
        ECR_REPO = '373317459084.dkr.ecr.ap-northeast-3.amazonaws.com/myapp-repo'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/manishgowdas/sample-nginx-ci.git',
                    credentialsId: 'githubrepo'
            }
        }

        stage('Build Docker Image') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_REGION}") {
                    script {
                        def IMAGE_TAG = "v${env.BUILD_NUMBER}"
                        sh """
                            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                            docker build -t myapp:$IMAGE_TAG .
                            docker tag myapp:$IMAGE_TAG $ECR_REPO:$IMAGE_TAG
                            docker tag myapp:$IMAGE_TAG $ECR_REPO:latest
                        """
                    }
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withAWS(credentials: 'aws-creds', region: "${AWS_REGION}") {
                    script {
                        def IMAGE_TAG = "v${env.BUILD_NUMBER}"
                        sh """
                            docker push $ECR_REPO:$IMAGE_TAG
                            docker push $ECR_REPO:latest
                        """
                    }
                }
            }
        }
    }
}
