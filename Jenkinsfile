pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "us-east-1"
        TF_VAR_ami_id = "ami-0317b0f0a0144b137"
        TF_VAR_instance_type = "t3.micro"
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
                        sh '''
                           terraform apply -auto-approve \
                             -var="ami_id=${TF_VAR_ami_id}" \
                             -var="instance_type=${TF_VAR_instance_type}"
                        '''
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
                        script {

                            def backend_ip = sh(
                                script: "terraform -chdir=../terraform output -raw backend_ip",
                                returnStdout: true
                            ).trim()

                            if (!backend_ip) {
                                error "❌ Terraform output 'backend_ip' not found!"
                            }

                            writeFile file: "inventory", text: """
[backend]
${backend_ip}
"""

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
    }

    post {
        success {
            echo '🎉 Infrastructure provisioned and configured successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs.'
        }
    }
}
