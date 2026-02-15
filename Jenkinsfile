pipeline {
    agent any

    environment {
        // Pull AWS credentials from Jenkins
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {

        stage('Checkout SCM') {
            steps {
                echo "Checking out code from Git..."
                git url: 'https://github.com/sneha-samala/ansible-challange.git', branch: 'main'
            }
        }

        stage('AWS Configure') {
            steps {
                echo "Configuring AWS CLI..."
                sh '''
                    mkdir -p ~/.aws
                    echo "[default]" > ~/.aws/credentials
                    echo "aws_access_key_id=${AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials
                    echo "aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials
                    echo "[default]" > ~/.aws/config
                    echo "region=${AWS_DEFAULT_REGION}" >> ~/.aws/config
                '''
                sh 'aws sts get-caller-identity'  // validate AWS access
            }
        }

        stage('Terraform Init') {
            steps {
                dir('ci-pipeline/terraform') {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('ci-pipeline/terraform') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('ci-pipeline/terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('ci-pipeline/terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Fetch Terraform Output') {
            steps {
                dir('ci-pipeline/terraform') {
                    sh 'terraform output -raw ansible_inventory > ../ansible/inventory.ini'
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                dir('ci-pipeline/ansible') {
                    sh 'ansible-playbook -i ../ansible/inventory.ini playbook.yml'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check console logs.'
        }
    }
}
