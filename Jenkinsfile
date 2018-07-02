pipeline {
  agent any
	parameters{
    	choice(choices: 'env-int3.yaml\nint-sp-ath.yaml\npre-int-sp-ath.yaml', description: 'What enviroment file do you want to use?', name: 'ENV_FILE')
	}
    stages {

		stage('Test SP.int.1'){
			steps{
				echo'Testing SP 1'
				dir('tests/SP/SP.int.1/script')
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