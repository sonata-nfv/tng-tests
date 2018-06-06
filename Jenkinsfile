pipeline {
  agent any
	parameters{
    	choice(choices: 'env-int3.yaml\nenv-test2.yaml\ntest3.yaml', description: 'What enviroment file do you want to use?', name: 'ENV_FILE')
	}
    stages {
        stage('Run Tests') {
            parallel {
                stage('SP tests') {

                    steps {
						echo'Testing SP 1'
						dir('tests/SP/SP.int.1')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}
						echo'Testing SP 2'
						dir('tests/SP/SP.int.2')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}		
						echo'Testing SP 3'
						dir('tests/SP/SP.int.3')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}					
                    }
                    post {
                        always {
							archiveArtifacts artifacts: 'results/**/*.xml'
							sh 'cp results/**/*.xml results'
							junit 'results/*.xml'
                        }

                    }
					
                }
                stage('VnV tests') {

                    steps {
						echo'Testing VnV 1'
						dir('tests/VnV/VNV.int.1')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}
						echo'Testing VnV 2'
						dir('tests/VnV/VNV.int.2')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}
                    }
                    post {
                        always {
							archiveArtifacts artifacts: 'results/**/*.xml'
							sh 'cp results/**/*.xml results'
							junit 'results/*.xml'
                        }

                    }
                }
            }
	stage('SDK tests'){
		steps{
			echo 'SDK tests'
		}
	}
        }
    }
}