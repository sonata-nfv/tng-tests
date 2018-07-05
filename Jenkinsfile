pipeline {
  agent any
	parameters{
    	choice(choices: 'env-int3.yaml\nint-sp-ath.yaml\npre-int-sp-ath.yaml', description: 'What enviroment file do you want to use?', name: 'ENV_FILE')
	}
    stages {

		stage('Clean WS') {
		    steps {
		        step([$class: 'WsCleanup'])
		        checkout scm
		    }
        	}

		stage('Test SP.int.1 - Valid package is stored'){
			steps{
				echo'Testing SP 1 - Valid package is stored'
				dir('tests/SP/SP.int.1/script')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test SP.int.2 - Invalid package is not stored'){
			steps{
				echo'Testing SP 2- Invalid package is not stored'
				dir('tests/SP/SP.int.2')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test SP.int.3 - Query available services'){
			steps{
				echo'Testing SP 3 - Query available services'
				dir('tests/SP/SP.int.3/script')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test SP.int.4 - Add an SLA Template to a Service in the Catalogue'){
			steps{
				echo'Testing SP 4 - Add an SLA Template to a Service in the Catalogue'
				dir('tests/SP/SP.int.4')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test SP.int.7 - Instantiate a service'){
			steps{
				echo'Testing SP 7 - Instantiate a service'
				dir('tests/SP/SP.int.7/script')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test SP.int.9 - Gatekeeper read functions and services records'){
			steps{
				echo'Testing SP 9- Gatekeeper read functions and services records'
				dir('tests/SP/SP.int.9')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test SP.int.10 - Terminate a service'){
			steps{
				echo'Testing SP 10- Terminate a service'
				dir('tests/SP/SP.int.10')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test SDK.int.2 - Create and validate project'){
			steps{
				echo'Testing SP 1 - Valid package is stored'
				dir('tests/SDK/SDK.int.2/script')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}

	}
	post {
		always {
			junit 'results/*.xml'
			archiveArtifacts artifacts: 'results/*.xml'
		}
	}
	
}