pipeline {
    agent any
    environment {
        AWS_REGION = 'ap-northeast-3'
        ECR_REPO = '373317459084.dkr.ecr.ap-northeast-3.amazonaws.com/myapp-repo'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/manish40/sample-nginx-ci.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    IMAGE_TAG = "v${env.BUILD_NUMBER}"
                    sh """
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                    docker build -t sample-nginx:$IMAGE_TAG .
                    docker tag sample-nginx:$IMAGE_TAG $ECR_REPO:$IMAGE_TAG
                    docker tag sample-nginx:$IMAGE_TAG $ECR_REPO:latest
                    """
                }
            }
        }

        stage('Push to ECR') {
            steps {
                sh """
                docker push $ECR_REPO:$IMAGE_TAG
                docker push $ECR_REPO:latest
                """
            }
        }

        stage('Update Helm Chart or Manifest') {
            steps {
                script {
                    // Example: Update image tag in deployment YAML (for ArgoCD)
                    sh """
                    git config user.name "jenkins-ci"
                    git config user.email "ci@myorg.com"
                    sed -i 's|image: .*|image: $ECR_REPO:$IMAGE_TAG|' manifests/deployment.yaml || true
                    git add manifests/deployment.yaml || true
                    git commit -m "Update image tag to $IMAGE_TAG" || true
                    git push origin main || true
                    """
                }
            }
        }
    }
}
