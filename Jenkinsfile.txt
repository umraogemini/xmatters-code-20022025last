pipeline {
    agent any
    environment {
        GCP_CREDENTIALS = credentials('gcp-service-account-key') // Service account JSON key
        TF_VAR_project_id = 'hsbc-12609073-peakplat-dev' // Replace with your GCP project ID
        TF_VAR_xmatters_webhook_url = 'https://hap-api.hsbc.co.uk/api/sendAlert?@aboutSource=GCP' // Replace with your xMatters webhook URL
    }

    stages {
        stage('Checkout Code') {
            steps {
                git 'https://alm-github.systems.uk.hsbc/bff/infrastructure-as-code.git' // Replace with your Git repository
            }
        }

        stage('Initialize Terraform') {
            steps {
                sh "terraform init"
            }
        }

        stage('Plan Terraform') {
            steps {
                sh "terraform plan -out=tfplan"
            }
        }

        stage('Apply Terraform') {
            steps {
                sh "terraform apply -auto-approve tfplan"
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
