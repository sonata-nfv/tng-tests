pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'				
				sh './tests/base_tests/test_script.sh env-int3.yaml'
            }
        }

    }



    post {
        always {
            archiveArtifacts artifacts: 'results/**/*.xml'
            
        }
    }


}


