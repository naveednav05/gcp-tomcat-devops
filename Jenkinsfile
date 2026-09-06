pipeline {

    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    parameters {

        string(
            name: 'HANDOFF_NUMBER',
            defaultValue: 'HF-0098',
            description: 'Enter handoff number in format HF-0000'
        )

        booleanParam(
            name: 'REPLACE_HANDOFF',
            defaultValue: false,
            description: 'Replace existing handoff if it already exists'
        )
    }

    stages {

        stage('Validate Handoff') {
            steps {
                script {

                    if (!params.HANDOFF_NUMBER) {
                        error("HANDOFF_NUMBER parameter is empty or was not supplied.")
                    }

                    def handoff = params.HANDOFF_NUMBER.trim()

                    if (!(handoff ==~ /^HF-[0-9]{4}$/)) {
                        error(
                            "Invalid handoff number: '${handoff}'. " +
                            "Expected format: HF-0000. Example: HF-0098"
                        )
                    }

                    echo "======================================"
                    echo "Handoff Number : ${handoff}"
                    echo "Replace        : ${params.REPLACE_HANDOFF}"
                    echo "======================================"
                }
            }
        }


        stage('Check Existing Handoff') {
            steps {
                script {

                    def handoff = params.HANDOFF_NUMBER.trim()

                    echo "Checking Artifact Registry for ${handoff}..."

                    def output = sh(
                        script: """
                            gcloud artifacts versions list \
                              --project=gcp-gke-12345 \
                              --location=asia-south1 \
                              --repository=war-files \
                              --package=myapp \
                              --format="value(name.basename())"
                        """,
                        returnStdout: true
                    ).trim()

                    def versions = output ? output.readLines() : []

                    echo "Existing versions:"
                    echo versions.join('\n')

                    def handoffExists = versions.contains(handoff)

                    if (handoffExists) {

                        echo "⚠️ Handoff ${handoff} already exists."

                        if (!params.REPLACE_HANDOFF) {

                            error(
                                "Handoff ${handoff} already exists. " +
                                "Set REPLACE_HANDOFF=true to replace it."
                            )
                        }

                        echo "REPLACE_HANDOFF=true"
                        echo "Existing handoff will be replaced."

                    } else {

                        echo "✅ Handoff ${handoff} does not exist."
                        echo "New handoff will be uploaded."
                    }
                }
            }
        }


        stage('Checkout') {
            steps {

                checkout scm

                echo "Source code checked out successfully."
            }
        }


        stage('Build WAR') {
            steps {

                sh '''
                    echo "======================================"
                    echo "Building Maven WAR"
                    echo "======================================"

                    mvn clean package

                    echo ""
                    echo "Maven build completed successfully."
                '''
            }
        }


        stage('Verify WAR') {
            steps {

                sh '''
                    echo "======================================"
                    echo "Verifying WAR"
                    echo "======================================"

                    if [ ! -f target/myapp.war ]; then
                        echo "ERROR: target/myapp.war was not created."
                        exit 1
                    fi

                    echo ""
                    echo "WAR file:"
                    ls -lh target/myapp.war

                    echo ""
                    echo "SHA256:"
                    sha256sum target/myapp.war
                '''
            }
        }


        stage('Delete Existing Handoff') {
            steps {
                script {

                    def handoff = params.HANDOFF_NUMBER.trim()

                    /*
                     * Check again immediately before deleting.
                     * This prevents attempting to delete a handoff
                     * that does not actually exist.
                     */

                    def output = sh(
                        script: """
                            gcloud artifacts versions list \
                              --project=gcp-gke-12345 \
                              --location=asia-south1 \
                              --repository=war-files \
                              --package=myapp \
                              --format="value(name.basename())"
                        """,
                        returnStdout: true
                    ).trim()

                    def versions = output ? output.readLines() : []

                    def handoffExists = versions.contains(handoff)

                    if (handoffExists && params.REPLACE_HANDOFF) {

                        echo "======================================"
                        echo "Deleting Existing Handoff"
                        echo "======================================"

                        echo "Deleting: ${handoff}"

                        sh """
                            gcloud artifacts versions delete '${handoff}' \
                              --project=gcp-gke-12345 \
                              --location=asia-south1 \
                              --repository=war-files \
                              --package=myapp \
                              --quiet
                        """

                        echo "Existing handoff deleted successfully."

                    } else {

                        echo "Delete not required."

                        if (!handoffExists) {
                            echo "Handoff ${handoff} does not exist."
                        }

                        if (!params.REPLACE_HANDOFF) {
                            echo "REPLACE_HANDOFF=false."
                        }
                    }
                }
            }
        }


        stage('Upload WAR') {
            steps {
                script {

                    def handoff = params.HANDOFF_NUMBER.trim()

                    echo "======================================"
                    echo "Uploading WAR"
                    echo "======================================"

                    echo "Project    : gcp-gke-12345"
                    echo "Region     : asia-south1"
                    echo "Repository : war-files"
                    echo "Package    : myapp"
                    echo "Version    : ${handoff}"
                    echo "File       : target/myapp.war"

                    sh """
                        gcloud artifacts generic upload \
                          --project=gcp-gke-12345 \
                          --location=asia-south1 \
                          --repository=war-files \
                          --package=myapp \
                          --version='${handoff}' \
                          --source=target/myapp.war
                    """

                    echo ""
                    echo "WAR uploaded successfully."
                }
            }
        }


        stage('Verify Artifact') {
            steps {
                script {

                    def handoff = params.HANDOFF_NUMBER.trim()

                    echo "======================================"
                    echo "Verifying Artifact"
                    echo "======================================"

                    def output = sh(
                        script: """
                            gcloud artifacts versions list \
                              --project=gcp-gke-12345 \
                              --location=asia-south1 \
                              --repository=war-files \
                              --package=myapp \
                              --format="value(name.basename())"
                        """,
                        returnStdout: true
                    ).trim()

                    def versions = output ? output.readLines() : []

                    if (!versions.contains(handoff)) {

                        error(
                            "Artifact verification failed. " +
                            "Version ${handoff} was not found."
                        )
                    }

                    echo ""
                    echo "✅ Artifact verified successfully."

                    echo ""
                    echo "Artifact path:"
                    echo "war-files / myapp / ${handoff} / myapp.war"
                }
            }
        }
    }


    post {

        success {
            script {

                def handoff = params.HANDOFF_NUMBER.trim()

                currentBuild.description = "WAR: ${handoff}"

                echo ""
                echo "======================================"
                echo "          JOB 1 SUCCESS"
                echo "======================================"

                echo "Handoff : ${handoff}"

                echo ""
                echo "Artifact:"
                echo "war-files / myapp / ${handoff} / myapp.war"

                echo ""
                echo "Ready for Jenkins Job 2."

                echo "======================================"
            }
        }

        failure {

            echo ""
            echo "======================================"
            echo "          JOB 1 FAILED"
            echo "======================================"

            echo "Review the error above."

            echo "======================================"
        }
    }
}
