@Library('jenkins.pipeline') _

env.LOG_LEVEL = "INFO"

def final AWS_SHARED_SERVICES_ACCOUNT_ID = "641202632344"
def final REGION = "us-west-2"
def final DEVOPS_BRANCH = "master"

def containerLabel
def yamlContent
def imageUniqueTag
def yamlContent

def dockerRepoName = "dump-collector"
def dockerRegistry = "${AWS_SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

node("master") {
    containerLabel = "jenkins-dumper-build-agent"
    logger.debug("Agent random name is: ${containerLabel}")
    getFileFromGit("devops", DEVOPS_BRANCH, "jenkins/docker_files/slave.yaml", "slave.yaml")
    yamlContent = readFile(file: "slave.yaml")
}

pipeline {

    agent {
        kubernetes {
            inheritFrom "${containerLabel}"
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
                    ecrFunctions.ecrLogin(AWS_SHARED_SERVICES_ACCOUNT_ID, REGION)
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
