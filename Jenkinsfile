pipeline {
    agent any
	    parameters {       
		choice(choices: 'env-int3.yaml\nenv-test2.yaml\ntest3.yaml', description: 'What enviroment file do you want to use?', name: 'ENV_FILE')
		}
    stages {
        stage('Build') {
            steps {
                echo 'Testing upload package'	
			dir ('tests/VnV/VNV.int.1')	{	
				sh "./test_script.sh ${params.ENV_FILE}"		
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


