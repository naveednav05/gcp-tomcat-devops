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
            description: 'Replace an existing handoff after the new WAR is successfully built'
        )
    }

    environment {

        PROJECT_ID     = 'gcp-gke-12345'
        REGION         = 'asia-south1'
        WAR_REPOSITORY = 'war-files'
        PACKAGE_NAME   = 'myapp'
        WAR_NAME       = 'myapp.war'
    }

    stages {

        stage('Validate Handoff') {

            steps {

                script {

                    echo '=========================================='
                    echo '        HANDOFF VALIDATION'
                    echo '=========================================='

                    echo "Handoff Number : ${params.HANDOFF_NUMBER}"
                    echo "Replace        : ${params.REPLACE_HANDOFF}"

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

                    echo "Handoff format is valid."
                }
            }
        }


        stage('Check Existing Handoff') {

            steps {

                script {

                    echo '=========================================='
                    echo '       CHECKING ARTIFACT REGISTRY'
                    echo '=========================================='

                    def handoff = params.HANDOFF_NUMBER

                    def versionsOutput = sh(
                        script: """
                            gcloud artifacts versions list \
                                --project=${PROJECT_ID} \
                                --location=${REGION} \
                                --repository=${WAR_REPOSITORY} \
                                --package=${PACKAGE_NAME} \
                                --format="value(name.basename())"
                        """,
                        returnStdout: true
                    ).trim()

                    def handoffExists = false

                    if (versionsOutput) {

                        def versions = versionsOutput.split("\\n")

                        for (def version : versions) {

                            if (version.trim() == handoff) {
                                handoffExists = true
                                break
                            }
                        }
                    }

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

Artifact:
${WAR_REPOSITORY}/${PACKAGE_NAME}/${handoff}

REPLACE_HANDOFF is FALSE.

Build stopped to prevent accidental replacement.

If you intentionally want to replace this handoff,
run the job again with:

REPLACE_HANDOFF = TRUE
"""
                        }

                        echo "Existing handoff found."
                        echo "Replacement has been requested."
                        echo "The existing artifact will NOT be deleted yet."
                        echo "It will only be deleted after the new WAR builds successfully."

                    } else {

                        echo ""
                        echo "Handoff ${handoff} does not exist."
                        echo "Proceeding as a new handoff."
                    }
                }
            }
        }


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
                    echo "Workspace:"
                    pwd

                    echo ""
                    echo "Application files:"
                    ls -la
                '''
            }
        }


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


        stage('Delete Existing Handoff') {

            when {

                expression {
                    return params.REPLACE_HANDOFF
                }
            }

            steps {

                script {

                    def handoff = params.HANDOFF_NUMBER

                    /*
                     * We only reach this stage if:
                     *
                     * 1. REPLACE_HANDOFF = true
                     * 2. The new WAR was successfully built
                     * 3. WAR verification succeeded
                     */

                    echo '=========================================='
                    echo '       REPLACING EXISTING HANDOFF'
                    echo '=========================================='

                    echo ""
                    echo "⚠️ Existing handoff will now be deleted."
                    echo ""
                    echo "Handoff : ${handoff}"
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
                    echo "Existing ${handoff} artifact deleted."
                }
            }
        }


        stage('Upload WAR') {

            steps {

                script {

                    def handoff = params.HANDOFF_NUMBER

                    echo '=========================================='
                    echo '            UPLOADING WAR'
                    echo '=========================================='

                    echo ""
                    echo "Repository : ${WAR_REPOSITORY}"
                    echo "Package    : ${PACKAGE_NAME}"
                    echo "Version    : ${handoff}"
                    echo "WAR        : ${WAR_NAME}"
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


        stage('Verify Artifact') {

            steps {

                script {

                    def handoff = params.HANDOFF_NUMBER

                    echo '=========================================='
                    echo '           VERIFYING ARTIFACT'
                    echo '=========================================='

                    def versionsOutput = sh(
                        script: """
                            gcloud artifacts versions list \
                                --project=${PROJECT_ID} \
                                --location=${REGION} \
                                --repository=${WAR_REPOSITORY} \
                                --package=${PACKAGE_NAME} \
                                --format="value(name.basename())"
                        """,
                        returnStdout: true
                    ).trim()

                    def versions = versionsOutput ?
                        versionsOutput.split("\\n").collect { it.trim() } :
                        []

                    if (!versions.contains(handoff)) {

                        error """
ARTIFACT VERIFICATION FAILED

Handoff ${handoff} was uploaded but could not
be found during verification.
"""
                    }

                    echo ""
                    echo "✅ Artifact verified successfully."
                    echo ""
                    echo "Repository : ${WAR_REPOSITORY}"
                    echo "Package    : ${PACKAGE_NAME}"
                    echo "Version    : ${handoff}"
                    echo "WAR        : ${WAR_NAME}"
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
            echo "No successful handoff was reported."
            echo ""
            echo "Check the Jenkins console output."
            echo ""
            echo "=========================================="
        }
    }
}
