#!groovy

pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                echo 'Stage: Checkout...'
                checkout scm
            }
        }
        stage('Build') {
            steps {
                echo 'Stage: Packaging 5GTANGO packages ...'
								// install the SDK to be able to package
                sh "pipeline/build/install-sdk.sh"
								// package all projects in 'packages/'
                sh "pipeline/build/pack.sh"
            }
        }
        stage('Test') {
            steps {
                echo 'Stage: Test...'
            }
        }
        stage('Publication') {
            when {
                // only push the master branch to DockerHub
                branch 'master'
            }
            steps {
                echo 'Stage: Publication...'
            }
        }
    }
    post {
        success {
            archiveArtifacts artifacts: 'packages/*.tgo'
        }
        failure {
                emailext(from: "jenkins@sonata-nfv.eu", 
                to: "manuel.peuster@upb.de", 
                subject: "FAILURE: ${env.JOB_NAME}/${env.BUILD_ID} (${env.BRANCH_NAME})",
                body: "${env.JOB_URL}")
        }
    }
}