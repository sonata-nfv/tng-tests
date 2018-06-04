pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Testing basic elements...'	
			dir ('tests/base_tests/')	{	

				sh './test_script.sh env-int3.yaml'
				sh 'ls -ltr'	
				sh 'tavern-ci test_01.get_packages.tavern.yml --stdout --debug'
				sh 'resulting xml'
				sh 'echo ../../results/base_tests/base_tests.xml'
		
			}
            }
        }

    }



    post {
        always {
            archiveArtifacts artifacts: 'results/**/*.xml'
            
        }
	success {
		  publishHTML target: [
			allowMissing: false,
			alwaysLinkToLastBuild: false,
			keepAll: true,
			reportDir: 'results/base_tests',
			reportFiles: 'index.html',
			reportName: 'Results Report'
		  ]	
	}
    }


}


