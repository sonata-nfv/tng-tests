pipeline {
  agent any
	parameters{
    	choice(choices: 'env-int3.yaml\nenv-test2.yaml\ntest3.yaml', description: 'What enviroment file do you want to use?', name: 'ENV_FILE')
	}
    stages {

		stage('test step 0'){
			steps {
				echo'Testing Base Tests'
				dir('tests/base_tests')
				{
				sh"./test_script.sh ${params.ENV_FILE}"
				}
			}
		}

		stage('test step 1'){
			parallel{
				stage('Test SP.int.1'){
					steps{
						echo'Testing SP 1'
						dir('tests/SP/SP.int.1')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}			
					}
				
				}
				stage('Test VnV.int.1'){
					steps{
						echo'Testing VnV 1'
						dir('tests/VnV/VNV.int.1')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}			
					}
				}
				stage('Test SDK.int.1'){
					steps{
						echo'Testing SDK 1'
						dir('tests/SDK/SDK.int.1')
						{
						sh"ls"
						}			
					}
				}				
			}
		}

		stage('test step 2'){
			parallel{
				stage('Test SP.int.2'){
					steps{
						echo'Testing SP 2'
						dir('tests/SP/SP.int.2')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}			
					}
				
				}
				stage('Test VnV.int.2'){
					steps{
						echo'Testing VnV 2'
						dir('tests/VnV/VNV.int.2')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}			
					}
				}
				stage('Test SDK.int.2'){
					steps{
						echo'Testing SDK 2'
						dir('tests/SDK/SDK.int.2')
						{
						sh"ls"
						}			
					}
				}				
				
			}
		}

		stage('test step 3'){
			parallel{
				stage('Test SP.int.3'){
					steps{
						echo'Testing SP 2'
						dir('tests/SP/SP.int.2')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}			
					}
				
				}
				stage('Test SDK.int.3'){
					steps{
						echo'Testing SDK 3'
						dir('tests/SDK/SDK.int.3')
						{
						sh"ls"
						}			
					}
				}				
				
			}
		}
		stage('test step 4'){
			parallel{
				stage('Test SP.int.10'){
					steps{
						echo'Testing SP 10'
						dir('tests/SP/SP.int.10')
						{
						sh"./test_script.sh ${params.ENV_FILE}"
						}			
					}
				
				}
				stage('Test SDK.int.4'){
					steps{
						echo'Testing SDK 4'
						dir('tests/SDK/SDK.int.4')
						{
						sh"ls"
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
	}
	
}