pipeline {
  agent any

  environment {
    ANSIBLE_HOST_KEY_CHECKING = 'False'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
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
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Ansible Configure') {
      steps {
        dir('ci-pipeline/ansible') {
          sh 'ansible-playbook -i inventory site.yml'
        }
      }
    }
  }
}
