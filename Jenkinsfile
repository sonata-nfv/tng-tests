pipeline {
  agent any
	parameters{
    	choice(choices: 'multi-env.yaml\nint-sp-ath.yaml\npre-int-sp-ath.yaml', description: 'What enviroment file do you want to use?', name: 'ENV_FILE')
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
		stage('Test SP.int.5 - Add a Policy to a Service in the Catalogue'){
			steps{
				echo'Testing SP 5 - Add a Policy to a Service in the Catalogue'
				dir('tests/SP/SP.int.5/script')
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
		stage('Test VnV.int.1 - VNV Gatekeeper to LCM Package Callback'){
			steps{
				echo'Testing VnV- VNV Gatekeeper to LCM Package Callback '
				dir('tests/VnV/VNV.int.1')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test VnV.int.2 - VNV Test package specification'){
			steps{
				echo'Testing VnV- Test package specification '
				dir('tests/VnV/VNV.int.2')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test VnV.int.5 - VNV end-to-end'){
			steps{
				echo'Testing VnV- VNV end-to-end '
				dir('tests/VnV/VNV.int.5')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test SDK.int.2 - Create and validate project'){
			steps{
				echo'Testing SDK 2 - Valid package is stored'
				dir('tests/SDK/SDK.int.2/script')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test SDK.int.3 - Create project and package'){
			steps{
				echo'Testing SDK 3 - Create project and package '
				dir('tests/SDK/SDK.int.3/script')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}			
			}
		}
		stage('Test SDK.int.4 - Schemas and packages'){
			steps{
				echo'Testing SDK 4 - Schemas and packages '
				dir('tests/SDK/SDK.int.4/script')
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