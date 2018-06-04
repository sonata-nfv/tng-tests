pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Testing basic elements...'				
				sh './main_script.sh env-int3.yaml'
				sh 'echo'
				sh 'pwd'
				sh 'tree'
				sh 'echo'
				sh 'cd tests/base_tests'
				sh 'pwd'
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


