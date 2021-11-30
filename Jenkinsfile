
def containerLabel
def yamlContent
def imageUniqueTag

def dockerRepoName = "dump-collector"
def dockerRegistry = "641202632344.dkr.ecr.us-west-2.amazonaws.com"

node("master") {
    containerLabel = "jenkins-slave-${UUID.randomUUID().toString()}"
    echo "Slave random name is: ${containerLabel}"
    yamlContent = readFile file: "${env.WORKSPACE}@script/slave.yaml"
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
                        sh """
                        docker build --no-cache -t ${dockerRepoName}:latest .
                        eval \$(aws ecr get-login --no-include-email --region us-west-2)
                        docker tag ${dockerRepoName}:latest ${dockerRegistry}/${dockerRepoName}:stable
                        docker push ${dockerRegistry}/${dockerRepoName}:stable
                        docker tag ${dockerRegistry}/${dockerRepoName}:stable \
                          ${dockerRegistry}/${dockerRepoName}:${imageUniqueTag}
                        docker push ${dockerRegistry}/${dockerRepoName}:${imageUniqueTag}
                        docker rmi ${dockerRegistry}/${dockerRepoName}:${imageUniqueTag} \
                          ${dockerRegistry}/${dockerRepoName}:stable -f
                        """

                    }
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
