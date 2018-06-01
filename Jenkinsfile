pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'	
				sh 'cd /tests/base_tests'			
				sh 'echo'
				sh 'pwd'
				sh 'echo'
				sh './test_script.sh env-int3.yaml'
            }
        }

    }



    post {
        always {
            archiveArtifacts artifacts: 'results/**/*.xml'
            
        }
    }


}


