@org.jenkinsci.plugins.workflow.libs.Library('jenkins.pipeline')

def containerLabel
def yamlContent
def imageUniqueTag

def final jenkinsPipelineLib = library("jenkins.pipeline@master").com.nextinsurance.pipeline
def final utility = jenkinsPipelineLib.Utility.new(this, this.steps)


node("master") {
    containerLabel = "jenkins-slave-${UUID.randomUUID().toString()}"
    echo "Slave random name is: ${containerLabel}"
//     jenkinsPipelinelib =
//             utility.setEnvironment()
//     def yamlFileName = "slave.yaml"
//     utility.getFileFromGit("dump-collector", "master", "${yamlFileName}", "slave.yaml")
//     yamlContent = readFile(file: "slave.yaml")
//     yamlContent = readYaml file: "slave.yaml"
//     echo yamlContent
}

pipeline {

    agent {
        kubernetes {
            label "${containerLabel}"
            yaml readYaml file: "slave.yaml"
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