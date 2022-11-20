pipeline {
    agent any
    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Branch name to clone from')
        string(name: 'GIT_URL', defaultValue: 'https://github.com/lemcode1/django-sample.git', description: 'GIT URL')
    }

    stages {
        stage('Clonig repo') {
            steps {
                echo 'Checking out the application code'
                checkout([$class: 'GitSCM', branches: [[name: "${BRANCH_NAME}"]], extensions: [[$class: 'CloneOption', noTags: false, reference: '', shallow: false, timeout: 60], [$class: 'CheckoutOption', timeout: 60]], userRemoteConfigs: [[credentialsId: 'Git_Credentials', url: "${GIT_URL}"]]])

            }
        }
        stage('Test the code') {
            steps {
                sh '''
                python3 -m venv ./venv --prompt django-app-env
                source venv/bin/activate
                python3 -m pip install -r requirements.txt
                python3 manage.py test
                rm -rf venv
                '''
            }
        }
        stage('Deploy the code') {
            steps {
                script {
                    sshPublisher(
                        continueOnError: false, failOnError: true,
                        publishers: [
                            sshPublisherDesc(
                                configName: "Web-Server",
                                verbose: true,
                                transfers: [
                                    sshTransfer(
                                        sourceFiles: "**/*, /root/django-app",
                                        execCommand: "chmod 777 /root/django-app/scripts/deploy.sh && /root/django-app/scripts/deploy.sh"
                                    )
                                ]
                            )
                        ]
                    )
                }
            }
        }
    }
}
