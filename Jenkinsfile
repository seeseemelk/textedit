pipeline {
  agent any
  stages {
    stage('Test') {
      steps {
        sh 'dub test -b unittest-cov textedit:textedit-core'
      }
    }

    stage('Build') {
      steps {
        sh 'dub build textedit:textedit-gtk'
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