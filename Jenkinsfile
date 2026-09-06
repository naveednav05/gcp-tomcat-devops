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

    environment {

        PROJECT_ID      = 'gcp-gke-12345'
        REGION          = 'asia-south1'
        WAR_REPOSITORY  = 'war-files'
        PACKAGE_NAME    = 'myapp'
        WAR_FILE        = 'myapp.war'

        HANDOFF         = ''
        HANDOFF_EXISTS  = 'false'
    }

    stages {

        /*
         * =========================================================
         * 1. VALIDATE HANDOFF NUMBER
         * =========================================================
         */
        stage('Validate Handoff') {

            steps {

                script {

                    def handoff = params.HANDOFF_NUMBER?.trim()

                    if (!(handoff ==~ /^HF-[0-9]{4}$/)) {

                        error(
                            "Invalid HANDOFF_NUMBER '${handoff}'. " +
                            "Expected format: HF-0000, example: HF-0098"
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


        /*
         * =========================================================
         * 2. CHECK WHETHER HANDOFF ALREADY EXISTS
         * =========================================================
         */
        stage('Check Existing Handoff') {

            steps {

                script {

                    echo "Checking Artifact Registry for ${env.HANDOFF}..."

                    def versionsOutput = sh(
                        script: """
                            gcloud artifacts versions list \
                              --project=${env.PROJECT_ID} \
                              --location=${env.REGION} \
                              --repository=${env.WAR_REPOSITORY} \
                              --package=${env.PACKAGE_NAME} \
                              --format="value(name.basename())" \
                              2>/dev/null
                        """,
                        returnStdout: true
                    ).trim()

                    def existingVersions = versionsOutput
                        ? versionsOutput.readLines()
                        : []

                    def handoffExists =
                        existingVersions
                            .collect { it.trim() }
                            .contains(env.HANDOFF)

                    env.HANDOFF_EXISTS = handoffExists.toString()

                    if (handoffExists) {

                        echo "⚠️ Handoff ${env.HANDOFF} already exists."

                        if (!params.REPLACE_HANDOFF) {

                            error(
                                "Handoff ${env.HANDOFF} already exists. " +
                                "Set REPLACE_HANDOFF=true if you want to replace it."
                            )
                        }

                        echo "REPLACE_HANDOFF=true"
                        echo "Existing handoff will be replaced after successful build."

                    } else {

                        echo "✅ Handoff ${env.HANDOFF} does not exist."

                        echo "New handoff will be uploaded."

                    }
                }
            }
        }


        /*
         * =========================================================
         * 3. CHECKOUT SOURCE CODE
         * =========================================================
         */
        stage('Checkout') {

            steps {

                checkout scm

                echo "Source code checked out successfully."
            }
        }


        /*
         * =========================================================
         * 4. BUILD WAR
         * =========================================================
         */
        stage('Build WAR') {

            steps {

                sh '''
                    echo "======================================"
                    echo "Building Maven WAR"
                    echo "======================================"

                    mvn clean package

                    echo ""
                    echo "Maven build completed."
                '''
            }
        }


        /*
         * =========================================================
         * 5. VERIFY WAR
         * =========================================================
         */
        stage('Verify WAR') {

            steps {

                sh """
                    echo "Checking WAR file..."

                    if [ ! -f "target/${WAR_FILE}" ]; then
                        echo "ERROR: target/${WAR_FILE} not found."
                        exit 1
                    fi

                    echo ""
                    echo "WAR file found:"
                    ls -lh "target/${WAR_FILE}"

                    echo ""
                    echo "WAR checksum:"
                    sha256sum "target/${WAR_FILE}"
                """
            }
        }


        /*
         * =========================================================
         * 6. DELETE OLD HANDOFF
         *
         * IMPORTANT:
         * Delete ONLY when:
         *
         * REPLACE_HANDOFF = true
         * AND
         * HANDOFF_EXISTS  = true
         *
         * This fixes the previous failure.
         * =========================================================
         */
        stage('Delete Existing Handoff') {

            when {

                allOf {

                    expression {
                        return params.REPLACE_HANDOFF
                    }

                    expression {
                        return env.HANDOFF_EXISTS == 'true'
                    }
                }
            }

            steps {

                sh """
                    echo "======================================"
                    echo "Deleting existing handoff"
                    echo "======================================"

                    echo "Handoff: ${HANDOFF}"

                    gcloud artifacts versions delete "${HANDOFF}" \
                      --project=${PROJECT_ID} \
                      --location=${REGION} \
                      --repository=${WAR_REPOSITORY} \
                      --package=${PACKAGE_NAME} \
                      --quiet

                    echo ""
                    echo "Existing handoff deleted successfully."
                """
            }
        }


        /*
         * =========================================================
         * 7. UPLOAD WAR
         * =========================================================
         */
        stage('Upload WAR') {

            steps {

                sh """
                    echo "======================================"
                    echo "Uploading WAR to Artifact Registry"
                    echo "======================================"

                    echo "Project      : ${PROJECT_ID}"
                    echo "Repository   : ${WAR_REPOSITORY}"
                    echo "Package      : ${PACKAGE_NAME}"
                    echo "Version      : ${HANDOFF}"
                    echo "File         : ${WAR_FILE}"

                    gcloud artifacts generic upload \
                      --project=${PROJECT_ID} \
                      --location=${REGION} \
                      --repository=${WAR_REPOSITORY} \
                      --package=${PACKAGE_NAME} \
                      --version=${HANDOFF} \
                      --source="target/${WAR_FILE}"

                    echo ""
                    echo "WAR uploaded successfully."
                """
            }
        }


        /*
         * =========================================================
         * 8. VERIFY ARTIFACT
         * =========================================================
         */
        stage('Verify Artifact') {

            steps {

                script {

                    echo "Verifying uploaded artifact..."

                    def versionsOutput = sh(
                        script: """
                            gcloud artifacts versions list \
                              --project=${PROJECT_ID} \
                              --location=${REGION} \
                              --repository=${WAR_REPOSITORY} \
                              --package=${PACKAGE_NAME} \
                              --format="value(name.basename())" \
                              2>/dev/null
                        """,
                        returnStdout: true
                    ).trim()

                    def versions = versionsOutput
                        ? versionsOutput.readLines().collect { it.trim() }
                        : []

                    if (!versions.contains(env.HANDOFF)) {

                        error(
                            "Artifact verification failed. " +
                            "Handoff ${env.HANDOFF} was not found."
                        )
                    }

                    echo "======================================"
                    echo "Artifact verified successfully"
                    echo "======================================"

                    echo ""
                    echo "Handoff Number : ${env.HANDOFF}"

                    echo ""
                    echo "Artifact:"
                    echo "war-files / myapp / ${env.HANDOFF} / myapp.war"
                }
            }
        }
    }


    /*
     * =============================================================
     * POST ACTIONS
     * =============================================================
     */
    post {

        success {

            script {

                currentBuild.description =
                    "WAR: ${env.HANDOFF}"

                echo ""
                echo "======================================"
                echo "        JOB 1 SUCCESS"
                echo "======================================"

                echo "Handoff Number : ${env.HANDOFF}"

                echo ""
                echo "WAR Artifact:"
                echo "war-files / myapp / ${env.HANDOFF} / myapp.war"

                echo ""
                echo "Next step:"
                echo "Jenkins Job 2 can use ${env.HANDOFF}"

                echo "======================================"
            }
        }

        failure {

            echo ""
            echo "======================================"
            echo "        JOB 1 FAILED"
            echo "======================================"

            echo "Check the stage above for the failure."

            echo "======================================"
        }
    }
}
