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
                    }
                    post {
                        always {
							archiveArtifacts artifacts: 'results/**/*.xml'
							sh 'cp results/**/*.xml results'
							junit 'results/*.xml'
                        }
						success{
							publishHTMLtarget: [
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
                stage('VnV tests') {

                    steps {
						echo'Testing VnV 1'
						dir('tests/VnV/VNV.int.1')
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
						success{
							publishHTMLtarget: [
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
        }
    }
}