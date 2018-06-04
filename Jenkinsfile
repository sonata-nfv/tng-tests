pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Testing basic elements...'	
			dir ('tests/base_tests/')	{	
				sh './test_script.sh env-int3.yaml'		
			}

                echo 'Testing slice manager'	
			dir ('tests/SP/SP.int.9')	{	
				sh './test_script.sh env-int3.yaml'		
			}


            }
        }

    }



    post {
        always {
            archiveArtifacts artifacts: 'results/**/*.xml'
	   sh 'cp results/**/*.xml results'	
	    junit 'results/*.xml'

       
        }


	success {
		  publishHTML target: [
			allowMissing: false,
			alwaysLinkToLastBuild: false,
			keepAll: true,
			reportDir: 'results/',
			reportFiles: 'index.html',
			reportName: 'Results Report'
		  ]	
	}





    }


}


