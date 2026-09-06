pipeline {

    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        PROJECT_ID = 'gcp-gke-12345'
        REGION = 'asia-south1'
        WAR_REPOSITORY = 'war-files'
        PACKAGE_NAME = 'myapp'
        WAR_NAME = 'myapp.war'
    }

    stages {

        stage('Validate Handoff') {
            steps {

                script {

                    echo "=========================================="
                    echo "HANDOFF VALIDATION"
                    echo "=========================================="

                    echo "Handoff Number : ${params.HANDOFF_NUMBER}"
                    echo "Replace        : ${params.REPLACE_HANDOFF}"

                    if (!(params.HANDOFF_NUMBER ==~ /^HF-[0-9]{4}$/)) {
                        error """
                        Invalid handoff number: ${params.HANDOFF_NUMBER}

                        Expected format:
                        HF-0098

                        Example:
                        HF-0001
                        HF-0123
                        HF-9999
                        """
                    }

                    echo "Handoff format is valid."
                }
            }
        }


        stage('Check Existing Handoff') {
            steps {

                script {

                    echo "=========================================="
                    echo "CHECKING ARTIFACT REGISTRY"
                    echo "=========================================="

                    def version = params.HANDOFF_NUMBER

                    def result = sh(
                        script: """
                            gcloud artifacts versions list \
                              --project=${PROJECT_ID} \
                              --location=${REGION} \
                              --repository=${WAR_REPOSITORY} \
                              --package=${PACKAGE_NAME} \
                              --filter="name:${version}" \
                              --format="value(name)"
                        """,
                        returnStdout: true
                    ).trim()

                    if (result) {

                        echo "Handoff ${version} already exists."

                        if (!params.REPLACE_HANDOFF) {

                            error """
                            Handoff ${version} already exists in Artifact Registry.

                            Replace existing handoff is NOT enabled.

                            Build stopped to prevent accidental overwrite.
                            """
                        }

                        echo "Replace option enabled."
                        echo "Existing handoff will be replaced."

                    } else {

                        echo "Handoff ${version} does not exist."
                        echo "This is a new handoff."
                    }
                }
            }
        }


        stage('Checkout Application') {
            steps {

                echo "=========================================="
                echo "CHECKOUT APPLICATION"
                echo "=========================================="

                checkout scm

                sh '''
                    echo "Git branch:"
                    git branch --show-current

                    echo ""
                    echo "Git commit:"
                    git rev-parse --short HEAD

                    echo ""
                    echo "Application files:"
                    ls -la
                '''
            }
        }


        stage('Build WAR') {
            steps {

                echo "=========================================="
                echo "BUILDING WAR"
                echo "=========================================="

                sh '''
                    mvn clean package
                '''
            }
        }


        stage('Verify WAR') {
            steps {

                echo "=========================================="
                echo "VERIFYING WAR"
                echo "=========================================="

                sh '''
                    ls -lh target/myapp.war

                    echo ""
                    echo "WAR checksum:"
                    sha256sum target/myapp.war
                '''
            }
        }


        stage('Upload WAR') {
            steps {

                script {

                    echo "=========================================="
                    echo "UPLOADING WAR"
                    echo "=========================================="

                    def version = params.HANDOFF_NUMBER

                    sh """
                        gcloud artifacts generic upload \
                          --project=${PROJECT_ID} \
                          --location=${REGION} \
                          --repository=${WAR_REPOSITORY} \
                          --package=${PACKAGE_NAME} \
                          --version=${version} \
                          --source=target/${WAR_NAME}
                    """

                    echo "WAR upload completed."
                }
            }
        }


        stage('Verify Artifact') {
            steps {

                script {

                    echo "=========================================="
                    echo "VERIFYING ARTIFACT"
                    echo "=========================================="

                    def version = params.HANDOFF_NUMBER

                    sh """
                        gcloud artifacts versions list \
                          --project=${PROJECT_ID} \
                          --location=${REGION} \
                          --repository=${WAR_REPOSITORY} \
                          --package=${PACKAGE_NAME}
                    """

                    echo ""
                    echo "Handoff ${version} successfully published."
                }
            }
        }
    }


    post {

        success {

            script {

                currentBuild.description =
                    "WAR: ${params.HANDOFF_NUMBER}"

                echo ""
                echo "=========================================="
                echo "          BUILD SUCCESSFUL"
                echo "=========================================="
                echo ""
                echo "Handoff Number : ${params.HANDOFF_NUMBER}"
                echo "WAR            : ${WAR_NAME}"
                echo "Package        : ${PACKAGE_NAME}"
                echo "Version        : ${params.HANDOFF_NUMBER}"
                echo ""
                echo "Artifact:"
                echo "war-files / ${PACKAGE_NAME} / ${params.HANDOFF_NUMBER} / ${WAR_NAME}"
                echo ""
                echo "=========================================="
            }
        }

        failure {

            echo ""
            echo "=========================================="
            echo "             BUILD FAILED"
            echo "=========================================="
            echo ""
            echo "Handoff Number : ${params.HANDOFF_NUMBER}"
            echo ""
            echo "Check the Jenkins console log."
            echo ""
            echo "=========================================="
        }
    }
}
