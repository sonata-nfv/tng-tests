pipeline {
  agent any
	parameters{
    	choice(choices: 'env-int3.yaml\nint-sp-ath.yaml\npre-int-sp-ath.yaml', description: 'What enviroment file do you want to use?', name: 'ENV_FILE')
	}
    stages {

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

	}
	post {
		always {
			junit 'results/*.xml'
			archiveArtifacts artifacts: 'results/*.xml'
		}
	}
	
}