@Library('jenkins.pipeline') _

env.LOG_LEVEL = "INFO"

def imageUniqueTag
def yamlContent

node("master") {
    github.getFile("devops", "master", "jenkins/docker_files/slave.yaml", "slave.yaml")
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

    triggers {
        cron("0 0 1 * *")

        GenericTrigger([
            genericVariables         : [
                [key: 'ref', value: '$.ref', expressionType: 'JSONPath', defaultValue: null],
            ],
            genericHeaderVariables   : [[key: 'X-GitHub-Event', regexpFilter: 'push']],
            regexpFilterText         : '$ref',
            regexpFilterExpression   : '^refs/heads/main$',
            causeString              : 'Triggered by webhook',
            token                    : env.JOB_BASE_NAME,
            printPostContent         : 'true',
            printContributedVariables: 'true'
        ])
    }

    stages {
        stage("Init") {
            steps {
                script {
                    def shortCommit = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
                    imageUniqueTag = "${shortCommit}-${env.BUILD_NUMBER}"
                }
            }
        }

        stage("Build and push") {
            steps {
                script {
                    dockerFunctions.buildAndPushDockerImage([], constants.OPS_SHARED_SERVICES_ACCOUNT, constants.AWS_DEFAULT_REGION, "dump-collector", ["latest", imageUniqueTag])
                }
            }
        }
    }

    post {
        unsuccessful {
            script {
                slackNotifier.notifySlackFreeMessage("${env.JOB_NAME} failed\n${env.BUILD_URL}", "danger", "#devex_alerts")
            }
        }
    }
}
