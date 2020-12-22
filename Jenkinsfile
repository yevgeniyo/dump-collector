
def containerLabel
def yamlContent
def imageUniqueTag

node("master") {
    containerLabel = "jenkins-slave-${UUID.randomUUID().toString()}"
    echo "Slave random name is: ${containerLabel}"
    yamlContent = readFile file: "slave.yaml"
    echo "Slave YAML is:\n${yamlContent}"
}

pipeline {

    agent {
        kubernetes {
            label "${containerLabel}"
            yaml yamlContent
        }
    }

    options {
        timeout(time: 10, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage("git clone") {
            steps {
                script {
                    def shortCommit = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
                    imageUniqueTag = "${shortCommit}-${env.BUILD_NUMBER}"
                }
            }
        }

        stage("build image") {
            steps {
                script {
                    container('docker') {
                        dir("jenkins/docker_files/apigateway-agent") {

                            sh """
                            docker ps -a
                            """
                        }

                    }
                }
            }
        }
    }
}