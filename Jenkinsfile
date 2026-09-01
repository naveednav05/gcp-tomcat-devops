pipeline {

    agent any

    stages {

        stage('Checkout') {

            steps {

                echo 'Checking out application source code'

            }

        }

        stage('Build WAR') {

            steps {

                sh 'mvn clean package'

            }

        }

        stage('Verify WAR') {

            steps {

                sh 'ls -lh target/'

            }

        }

    }

}
