pipeline {
    agent any
	    parameters {       
		choice(choices: 'env-int3.yaml\nenv-test2.yaml\ntest3.yaml', description: 'What enviroment file do you want to use?', name: 'ENV_FILE')
		}
    stages {
        stage('run tests') {


		parallel {


			stage('SP tests'){
		            steps {
		                	echo 'Testing SP 1'	
					dir ('tests/SP/SP.int.1')	{	
						sh "./test_script.sh ${params.ENV_FILE}"		
					}
					echo 'Testing SP 2'
					dir ('tests/SP/SP.int.2')	{	
						sh "./test_script.sh ${params.ENV_FILE}"		
					}
					echo 'Testing SP 3'
					dir ('tests/SP/SP.int.3')	{	
						sh "./test_script.sh ${params.ENV_FILE}"		
					}
					echo 'Testing SP 10'
					dir ('tests/SP/SP.int.10')	{	
						sh "./test_script.sh ${params.ENV_FILE}"		
					}

			}


			stage('VnV tests'){
		            steps {
		                	echo 'Testing VnV 1'	
					dir ('tests/VnV/VNV.int.1')	{	
						sh "./test_script.sh ${params.ENV_FILE}"		
					}
		                	echo 'Testing VnV 2'	
					dir ('tests/VnV/VNV.int.2')	{	
						sh "./test_script.sh ${params.ENV_FILE}"		
					}
			}



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
}

