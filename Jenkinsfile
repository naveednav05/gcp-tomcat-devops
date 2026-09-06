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
            description: 'Enter handoff number. Format: HF-0000'
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

                    def handoff = params.HANDOFF_NUMBER.trim()

                    if (!(handoff ==~ /^HF-[0-9]{4}$/)) {

                        error(
                            "Invalid handoff '${handoff}'. " +
                            "Expected format HF-0000, example HF-0098."
                        )
                    }

                    env.HANDOFF = handoff

                    echo "======================================"
                    echo "Handoff Number : ${env.HANDOFF}"
                    echo "Replace        : ${params.REPLACE_HANDOFF}"
                    echo "======================================"
                }
            }
        }


        stage('Check Existing Handoff') {

            steps {

                script {

                    echo "Checking Artifact Registry..."

                    def output = sh(
                        script: '''
                            gcloud artifacts versions list \
                              --project=gcp-gke-12345 \
                              --location=asia-south1 \
                              --repository=war-files \
                              --package=myapp \
                              --format="value(name.basename())" \
                              2>/dev/null
                        ''',
                        returnStdout: true
                    ).trim()

                    def versions = []

                    if (output) {
                        versions = output.readLines()
                    }

                    def exists = versions.contains(env.HANDOFF)

                    env.HANDOFF_EXISTS = exists ? 'true' : 'false'

                    echo "Existing versions:"
                    echo "${versions}"

                    echo "Handoff ${env.HANDOFF} exists: ${env.HANDOFF_EXISTS}"

                    if (exists && !params.REPLACE_HANDOFF) {

                        error(
                            "Handoff ${env.HANDOFF} already exists. " +
                            "Set REPLACE_HANDOFF=true to replace it."
                        )
                    }

                    if (exists && params.REPLACE_HANDOFF) {

                        echo "⚠️ Existing handoff found."
                        echo "Replacement requested."
                        echo "Old artifact will be deleted AFTER successful WAR build."
                    }

                    if (!exists) {

                        echo "✅ Handoff does not exist."
                        echo "New artifact will be uploaded."
                    }
                }
            }
        }


        stage('Checkout') {

            steps {

                checkout scm

                echo "Git checkout completed."
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

                        echo "ERROR: target/myapp.war does not exist."

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

            when {

                expression {
                    return params.REPLACE_HANDOFF &&
                           env.HANDOFF_EXISTS == 'true'
                }
            }

            steps {

                script {

                    def handoff = env.HANDOFF

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
                }
            }
        }


        stage('Upload WAR') {

            steps {

                script {

                    def handoff = env.HANDOFF

                    echo "======================================"
                    echo "Uploading WAR"
                    echo "======================================"

                    echo "Project    : gcp-gke-12345"
                    echo "Region     : asia-south1"
                    echo "Repository : war-files"
                    echo "Package    : myapp"
                    echo "Version    : ${handoff}"
                    echo "WAR        : target/myapp.war"

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
                    echo "WAR upload completed successfully."
                }
            }
        }


        stage('Verify Artifact') {

            steps {

                script {

                    def handoff = env.HANDOFF

                    echo "======================================"
                    echo "Verifying Artifact Registry"
                    echo "======================================"

                    def output = sh(
                        script: '''
                            gcloud artifacts versions list \
                              --project=gcp-gke-12345 \
                              --location=asia-south1 \
                              --repository=war-files \
                              --package=myapp \
                              --format="value(name.basename())" \
                              2>/dev/null
                        ''',
                        returnStdout: true
                    ).trim()

                    def versions = []

                    if (output) {
                        versions = output.readLines()
                    }

                    if (!versions.contains(handoff)) {

                        error(
                            "Artifact verification failed. " +
                            "Version ${handoff} was not found in Artifact Registry."
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

                currentBuild.description =
                    "WAR: ${env.HANDOFF}"

                echo ""
                echo "======================================"
                echo "          JOB 1 SUCCESS"
                echo "======================================"

                echo "Handoff : ${env.HANDOFF}"

                echo ""
                echo "Artifact:"
                echo "war-files / myapp / ${env.HANDOFF} / myapp.war"

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
