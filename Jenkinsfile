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
            description: 'Enter handoff number in format HF-0098'
        )

        booleanParam(
            name: 'REPLACE_HANDOFF',
            defaultValue: false,
            description: 'Delete and replace an existing handoff artifact'
        )
    }

    environment {

        PROJECT_ID      = 'gcp-gke-12345'
        REGION          = 'asia-south1'
        WAR_REPOSITORY  = 'war-files'
        PACKAGE_NAME    = 'myapp'
        WAR_NAME        = 'myapp.war'
    }

    stages {

        /*
         * ==========================================================
         * 1. VALIDATE HANDOFF NUMBER
         * ==========================================================
         */

        stage('Validate Handoff') {

            steps {

                script {

                    echo '=========================================='
                    echo '        HANDOFF VALIDATION'
                    echo '=========================================='

                    echo "Handoff Number : ${params.HANDOFF_NUMBER}"
                    echo "Replace        : ${params.REPLACE_HANDOFF}"

                    /*
                     * Expected format:
                     *
                     * HF-0001
                     * HF-0098
                     * HF-1234
                     *
                     * Exactly HF- followed by 4 digits.
                     */

                    if (!(params.HANDOFF_NUMBER ==~ /^HF-[0-9]{4}$/)) {

                        error """
INVALID HANDOFF NUMBER

Received:
${params.HANDOFF_NUMBER}

Expected format:
HF-0098

Examples:
HF-0001
HF-0098
HF-1234
"""
                    }

                    echo "Handoff format validated successfully."
                }
            }
        }


        /*
         * ==========================================================
         * 2. CHECK WHETHER HANDOFF ALREADY EXISTS
         * ==========================================================
         */

        stage('Check Existing Handoff') {

            steps {

                script {

                    echo '=========================================='
                    echo '       CHECKING ARTIFACT REGISTRY'
                    echo '=========================================='

                    def handoff = params.HANDOFF_NUMBER

                    /*
                     * Get all versions for the myapp package
                     * and check whether our handoff exists.
                     */

                    def existingVersion = sh(
                        script: """
                            gcloud artifacts versions list \
                                --project=${PROJECT_ID} \
                                --location=${REGION} \
                                --repository=${WAR_REPOSITORY} \
                                --package=${PACKAGE_NAME} \
                                --format="value(version)"
                        """,
                        returnStdout: true
                    ).trim()

                    def handoffExists = false

                    if (existingVersion) {

                        def versions = existingVersion.split("\\\\n")

                        for (def version : versions) {

                            if (version.trim() == handoff) {
                                handoffExists = true
                                break
                            }
                        }
                    }

                    /*
                     * --------------------------------------------------
                     * HANDOFF ALREADY EXISTS
                     * --------------------------------------------------
                     */

                    if (handoffExists) {

                        echo ""
                        echo "⚠️ EXISTING HANDOFF FOUND"
                        echo ""
                        echo "Handoff: ${handoff}"
                        echo ""

                        if (!params.REPLACE_HANDOFF) {

                            error """
HANDOFF ALREADY EXISTS

Handoff:
${handoff}

Artifact Registry:
${WAR_REPOSITORY}/${PACKAGE_NAME}/${handoff}

REPLACE_HANDOFF is FALSE.

The build has been stopped to prevent
accidental replacement.

If you intentionally want to replace this
handoff, run the job again with:

REPLACE_HANDOFF = TRUE
"""
                        }

                        /*
                         * ------------------------------------------------
                         * REPLACE ENABLED
                         * ------------------------------------------------
                         */

                        echo "⚠️ REPLACE_HANDOFF = TRUE"
                        echo ""
                        echo "Existing handoff will be deleted."
                        echo "A new WAR will then be uploaded."
                        echo ""

                        sh """
                            gcloud artifacts versions delete ${handoff} \
                                --project=${PROJECT_ID} \
                                --location=${REGION} \
                                --repository=${WAR_REPOSITORY} \
                                --package=${PACKAGE_NAME} \
                                --quiet
                        """

                        echo ""
                        echo "Existing handoff deleted successfully."
                    }

                    /*
                     * --------------------------------------------------
                     * HANDOFF DOES NOT EXIST
                     * --------------------------------------------------
                     */

                    else {

                        echo ""
                        echo "Handoff ${handoff} does not exist."
                        echo "Proceeding with new handoff build."
                    }
                }
            }
        }


        /*
         * ==========================================================
         * 3. CHECKOUT SOURCE CODE
         * ==========================================================
         */

        stage('Checkout Application') {

            steps {

                echo '=========================================='
                echo '       CHECKOUT APPLICATION'
                echo '=========================================='

                checkout scm

                sh '''
                    echo ""
                    echo "Git branch:"
                    git branch --show-current

                    echo ""
                    echo "Git commit:"
                    git rev-parse --short HEAD

                    echo ""
                    echo "Git repository:"
                    git remote -v

                    echo ""
                    echo "Workspace:"
                    pwd

                    echo ""
                    echo "Files:"
                    ls -la
                '''
            }
        }


        /*
         * ==========================================================
         * 4. BUILD WAR
         * ==========================================================
         */

        stage('Build WAR') {

            steps {

                echo '=========================================='
                echo '             BUILDING WAR'
                echo '=========================================='

                sh '''
                    mvn clean package
                '''
            }
        }


        /*
         * ==========================================================
         * 5. VERIFY WAR
         * ==========================================================
         */

        stage('Verify WAR') {

            steps {

                echo '=========================================='
                echo '             VERIFYING WAR'
                echo '=========================================='

                sh '''
                    if [ ! -f "target/myapp.war" ]; then
                        echo "ERROR: target/myapp.war was not created."
                        exit 1
                    fi

                    echo ""
                    echo "WAR file:"
                    ls -lh target/myapp.war

                    echo ""
                    echo "WAR checksum:"
                    sha256sum target/myapp.war
                '''
            }
        }


        /*
         * ==========================================================
         * 6. UPLOAD WAR TO ARTIFACT REGISTRY
         * ==========================================================
         */

        stage('Upload WAR') {

            steps {

                script {

                    def handoff = params.HANDOFF_NUMBER

                    echo '=========================================='
                    echo '         UPLOADING WAR'
                    echo '=========================================='

                    echo ""
                    echo "Handoff : ${handoff}"
                    echo "Package : ${PACKAGE_NAME}"
                    echo "WAR     : ${WAR_NAME}"
                    echo ""

                    sh """
                        gcloud artifacts generic upload \
                            --project=${PROJECT_ID} \
                            --location=${REGION} \
                            --repository=${WAR_REPOSITORY} \
                            --package=${PACKAGE_NAME} \
                            --version=${handoff} \
                            --source=target/${WAR_NAME}
                    """

                    echo ""
                    echo "WAR uploaded successfully."
                }
            }
        }


        /*
         * ==========================================================
         * 7. VERIFY ARTIFACT
         * ==========================================================
         */

        stage('Verify Artifact') {

            steps {

                script {

                    def handoff = params.HANDOFF_NUMBER

                    echo '=========================================='
                    echo '        VERIFYING ARTIFACT'
                    echo '=========================================='

                    def result = sh(
                        script: """
                            gcloud artifacts versions list \
                                --project=${PROJECT_ID} \
                                --location=${REGION} \
                                --repository=${WAR_REPOSITORY} \
                                --package=${PACKAGE_NAME} \
                                --format="value(version)"
                        """,
                        returnStdout: true
                    ).trim()

                    if (!result.split("\\\\n").collect { it.trim() }.contains(handoff)) {

                        error """
ARTIFACT VERIFICATION FAILED

Handoff ${handoff} was uploaded but could
not be found during verification.
"""
                    }

                    echo ""
                    echo "✅ Artifact verified successfully."
                    echo ""
                    echo "Repository : ${WAR_REPOSITORY}"
                    echo "Package    : ${PACKAGE_NAME}"
                    echo "Version    : ${handoff}"
                    echo "File       : ${WAR_NAME}"
                }
            }
        }
    }


    /*
     * ==============================================================
     * POST BUILD
     * ==============================================================
     */

    post {

        success {

            script {

                currentBuild.description =
                    "WAR: ${params.HANDOFF_NUMBER}"

                echo ""
                echo "=========================================="
                echo "       HANDOFF BUILD SUCCESSFUL"
                echo "=========================================="
                echo ""
                echo "Handoff Number : ${params.HANDOFF_NUMBER}"
                echo "WAR            : ${WAR_NAME}"
                echo "Package        : ${PACKAGE_NAME}"
                echo "Version        : ${params.HANDOFF_NUMBER}"
                echo "Repository     : ${WAR_REPOSITORY}"
                echo ""
                echo "Artifact:"
                echo "${PACKAGE_NAME}/${params.HANDOFF_NUMBER}/${WAR_NAME}"
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
            echo "Check the Jenkins console output."
            echo ""
            echo "=========================================="
        }
    }
}
