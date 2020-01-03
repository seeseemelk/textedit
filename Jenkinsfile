pipeline {
  agent any
  stages {
    stage('Test') {
      parallel {
        stage('DMD') {
          steps {
            sh 'dub test -b unittest-cov --compiler dmd textedit:textedit-core'
          }
        }

        stage('GDC') {
          steps {
            sh 'dub test --compiler gdc textedit:textedit-core'
          }
        }

        stage('LDC') {
          steps {
            sh 'dub test --compiler ldc textedit:textedit-core'
          }
        }

      }
    }

    stage('Build') {
      parallel {
        stage('DMD') {
          steps {
            sh 'dub build textedit:textedit-gtk --compiler dmd'
          }
        }

        stage('GDC') {
          steps {
            sh 'dub build textedit:textedit-gtk --compiler gdc'
          }
        }

        stage('LDC') {
          steps {
            sh 'dub build textedit:textedit-gtk --compiler ldc'
          }
        }

      }
    }

    stage('Publish Coverage') {
      environment {
        CODECOV_TOKEN = 'b8ddf220-3b8f-4c08-94cf-2b7a6630df54'
      }
      steps {
        sh 'bash -c "bash <(curl -s https://codecov.io/bash)"'
      }
    }

  }
}