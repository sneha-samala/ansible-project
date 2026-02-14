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

        stage('Ansible Configure') {
            steps {
                dir('ci-pipeline/ansible') {
                    withCredentials([
                        sshUserPrivateKey(
                            credentialsId: 'ssh',   // from your screenshot: jenkins-1.pem (ssh)
                            keyFileVariable: 'SSH_KEY',
                            usernameVariable: 'SSH_USER'
                        )
                    ]) {
                        script {
                            def backend_ip = sh(
                                script: "terraform -chdir=../terraform output -raw backend_ip",
                                returnStdout: true
                            ).trim()

                            if (!backend_ip) {
                                error "Terraform output 'backend_ip' not found!"
                            }

                            sh """
                              chmod 600 \$SSH_KEY
                              export ANSIBLE_HOST_KEY_CHECKING=False

                              ansible-playbook \
                                -i inventory \
                                site.yml \
                                --user=\$SSH_USER \
                                --private-key=\$SSH_KEY \
                                --extra-vars "backend_ip=${backend_ip}"
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo '🎉 Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs.'
        }
    }
}
