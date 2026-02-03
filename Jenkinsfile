pipeline {
    agent any

    environment {
        // AWS credentials for Terraform
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        // SSH key for Ansible EC2 access
        SSH_PRIVATE_KEY       = credentials('ec2-user')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']], // matches your repo branch
                    userRemoteConfigs: [[url: 'https://github.com/shaikhshahbazz/ansible-project.git']]
                ])
            }
        }

        stage('Terraform Init') {
            steps {
                dir('ci-pipeline/terraform') {
                    withEnv(["AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}"]) {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('ci-pipeline/terraform') {
                    withEnv(["AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY_ID}", "AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY}"]) {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Prepare Ansible Variables') {
            steps {
                dir('ci-pipeline/ansible') {
                    sh 'echo "ansible_host=127.0.0.1" > ansible_vars.yml'
                }
            }
        }

        stage('Ansible Configure') {
            steps {
                dir('ci-pipeline/ansible') {
                    withCredentials([sshUserPrivateKey(credentialsId: 'ec2-user', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                        sh """
                            ansible-playbook -i inventory site.yml -e @ansible_vars.yml \
                            --private-key $SSH_KEY -u $SSH_USER
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}
