pipeline {
    agent any

    environment {
        TF_DIR = "ci-pipeline/terraform"
        ANSIBLE_DIR = "ci-pipeline/ansible"
    }

    stages {

        stage('Terraform Init') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Ansible Configure') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ansible-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {
                    dir("${ANSIBLE_DIR}") {
                        sh '''
                        chmod 600 $SSH_KEY
                        export ANSIBLE_HOST_KEY_CHECKING=False

                        ansible-playbook \
                          -i inventory \
                          site.yml \
                          --user=ec2-user \
                          --private-key=$SSH_KEY
                        '''
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
            echo "❌ Pipeline failed. Check logs above."
        }
    }
}
