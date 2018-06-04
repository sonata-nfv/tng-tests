pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Testing basic elements...'	
			dir ('tests/base_tests/')	{	

				sh 'ls -ltr'	
				sh './test_script.sh env-int3.yaml'

		
			}
            }
        }

    }



    post {
        always {
            archiveArtifacts artifacts: 'results/**/*.xml'
	    junit 'results/**/*.xml'
            
        }

    }


}


