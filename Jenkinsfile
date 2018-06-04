pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Testing basic elements...'				

				sh './tests/base_tests/test_script.sh env-int3.yaml'
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


