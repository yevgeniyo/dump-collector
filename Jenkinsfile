@Library('jenkins.pipeline') _

env.LOG_LEVEL = "INFO"

def final AWS_SHARED_SERVICES_ACCOUNT_ID = "641202632344"
def final REGION = "us-west-2"

def containerLabel
def yamlContent
def imageUniqueTag

def dockerRepoName = "dump-collector"
def dockerRegistry = "${AWS_SHARED_SERVICES_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

node("master") {
    containerLabel = "jenkins-dumper-build-agent"
    logger.debug("Slave random name is: ${containerLabel}")
    yamlContent = readFile file: "${env.WORKSPACE}@script/slave.yaml"
    logger.debug("Slave YAML is:\n${yamlContent}")
}

pipeline {

    agent {
        kubernetes {
            inheritFrom "${containerLabel}"
            yaml """
apiVersion: v1
kind: Pod
metadata:
  annotations:
    karpenter.sh/do-not-evict: "true"
spec:
  serviceAccount: jenkins-nonadmin-agent-sa
  dnsConfig:
    options:
      - name: ndots
        value: "1"
  tolerations:
  - key: "isJenkinsSlave"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  nodeSelector:
    isJenkinsSlave: "true"
  containers:
  - name: jnlp
    image: 641202632344.dkr.ecr.us-west-2.amazonaws.com/jnlp:577ff3d8-130
    imagePullPolicy: Always
    resources:
        limits:
          memory: "2Gi"
          cpu: "1"
        requests:
          memory: "2Gi"
          cpu: "1"
    tty: true
    env:
    - name: ENVIRONMENT
      value: dev
    volumeMounts:
      - name: dockersock
        mountPath: "/var/run/docker.sock"
  volumes:
    - name: dockersock
      hostPath:
       path: /var/run/docker.sock
"""
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
                    ecrFunctions.ecrLogin(AWS_SHARED_SERVICES_ACCOUNT_ID, REGION)
                    sh """
                        docker build . --no-cache -t ${dockerRegistry}/${dockerRepoName}:${imageUniqueTag} \
                        docker push ${dockerRegistry}/${dockerRepoName}:${imageUniqueTag}
                        docker rmi ${dockerRegistry}/${dockerRepoName}:${imageUniqueTag}
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
