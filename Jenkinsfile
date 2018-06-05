pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Testing upload package'	
			dir ('tests/SP/SP.int.1')	{	
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
			keepAll: false,
			reportDir: 'results/',
			reportFiles: 'index.html',
			reportName: 'Results Report'
		  ]	
	}





    }


}


