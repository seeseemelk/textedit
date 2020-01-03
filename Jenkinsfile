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

  }
}