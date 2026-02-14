pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/sneha-samala/ansible-project.git',
                    branch: 'main'
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

        stage('Terraform Apply') {
            steps {
                dir('ci-pipeline/terraform') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-key'
                    ]]) {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Fetch Terraform Output') {
            steps {
                dir('ci-pipeline/terraform') {
                    script {
                        def backend_ip = sh(
                            script: "terraform output -raw backend_ip",
                            returnStdout: true
                        ).trim()

                        if (!backend_ip) {
                            error "❌ backend_ip output not found in Terraform!"
                        }

                        writeFile file: "../ansible/inventory", text: """
[backend]
${backend_ip}
"""
                        echo "✅ Backend IP: ${backend_ip}"
                    }
                }
            }
        }

        stage('Ansible Configure') {
            steps {
                dir('ci-pipeline/ansible') {
                    withCredentials([
                        sshUserPrivateKey(
                            credentialsId: 'ssh',
                            keyFileVariable: 'SSH_KEY',
                            usernameVariable: 'SSH_USER'
                        )
                    ]) {
                        sh """
                            chmod 600 \$SSH_KEY
                            export ANSIBLE_HOST_KEY_CHECKING=False

                            ansible-playbook \
                              -i inventory \
                              site.yml \
                              --user=\$SSH_USER \
                              --private-key=\$SSH_KEY
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo '🎉 Infrastructure provisioned and configured successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check console logs.'
        }
    }
}
