@Library('jenkins.pipeline') _

env.LOG_LEVEL = "INFO"

def final DEVOPS_BRANCH = "master"

def containerLabel
def imageUniqueTag
def yamlContent

def dockerRepoName = "dump-collector"
def dockerRegistry = "${constants.OPS_SHARED_SERVICES_ACCOUNT}.dkr.ecr.${constants.AWS_DEFAULT_REGION}.amazonaws.com"

node("master") {
    github.getFile("devops", DEVOPS_BRANCH, "jenkins/docker_files/slave.yaml", "slave.yaml")
    yamlContent = readFile(file: "slave.yaml").replaceAll("#ECR#", constants.OPS_SHARED_SERVICES_ACCOUNT)
}

pipeline {

    agent {
        kubernetes {
            inheritFrom "jenkins-dumper-build-agent"
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
                    dockerFunctions.runDockerDaemon()
                }
            }
        }

        stage("build image") {
            steps {
                script {
                    ecrFunctions.ecrLogin(constants.OPS_SHARED_SERVICES_ACCOUNT, constants.AWS_DEFAULT_REGION)
                    sh """
                        docker build . --no-cache -t ${dockerRegistry}/${dockerRepoName}:${imageUniqueTag}
                        docker push ${dockerRegistry}/${dockerRepoName}:${imageUniqueTag}
                    """
                }
            }
        }
    }
    post {
        always {
            deleteDir()
            cleanWs deleteDirs: true, notFailBuild: true
        }
    }
}
