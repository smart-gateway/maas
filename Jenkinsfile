def REPOS = [https://github.com/intel-innersource/frameworks.automation.sec.code.puppet.github-runner/tree/main
    'primary',
    'niwc',
    'lenovo',
    'wsr',
    'ido',
    'lab01',
    'lab02',
    'lab03',
    'echo',
]
pipeline {
    agent {
        kubernetes {
            cloud 'amr-pre'
        }
    }
    stages {
        stage('Invoke GitHub Actions Workflow') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'smart-gateway-general', usernameVariable: 'GH_USER', passwordVariable: 'GH_PASS')]) {
                    script {
                        REPOS.each { repo ->
                            try {
                                def url = "https://api.github.com/repos/smart-gateway/edge-${repo}-control/actions/workflows/deploy.yml/dispatches"
                                def response = sh(script: "curl -H 'Accept: application/vnd.github.v3+json' -H \"authorization: Bearer $GH_PASS\" -d '{\"ref\":\"production\"}' '${url}'", returnStdout: true).trim()
                                echo "Response: ${response}"
                            } catch (Exception e) {
                                echo "Failed to invoke GitHub Actions Workflow: ${e.getMessage()}"
                                currentBuild.result = 'FAILURE'
                            }
                        }
                    }
                }
                
            }
        }
    }
}
