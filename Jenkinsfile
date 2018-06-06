pipeline {
  agent any
	parameters{
    	choice(choices: 'env-int3.yaml\nenv-test2.yaml\ntest3.yaml', description: 'What enviroment file do you want to use?', name: 'ENV_FILE')
	}
    stages {
        stage('Run Tests') {
            parallel {
			

                stages('SP tests') {
					stage('Testing SP 1'){
						steps {
							echo'Testing SP 1'
							dir('tests/SP/SP.int.1')
							{
							sh"./test_script.sh ${params.ENV_FILE}"
							}
						}
					}
					stage('Testing SP 2'){
						steps {
							echo'Testing SP 2'
							dir('tests/SP/SP.int.2')
							{
							sh"./test_script.sh ${params.ENV_FILE}"
							}
						}
					}	
					stage('Testing SP 3'){
						steps {
							echo'Testing SP 3'
							dir('tests/SP/SP.int.3')
							{
							sh"./test_script.sh ${params.ENV_FILE}"
							}
						}
					}
				}
				
                stages('VnV tests') {
					stage('Testing VnV 1'){
						steps {
							echo'Testing VnV 1'
							dir('tests/VnV/VNV.int.1')
							{
							sh"./test_script.sh ${params.ENV_FILE}"
							}
						}
					}
					stage('Testing VnV 2'){
						steps {
							echo'Testing VnV 2'
							dir('tests/VnV/VNV.int.2')
							{
							sh"./test_script.sh ${params.ENV_FILE}"
							}
						}
					}	

				}				

            }
        }
    }
}