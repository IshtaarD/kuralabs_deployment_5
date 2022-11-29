pipeline {
  agent any
  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub')
  }
   stages {
    stage ('Build') {
      steps {
        sh '''#!/bin/bash
        python3 -m venv test3
        source test3/bin/activate
        pip install pip --upgrade
        pip install -r requirements.txt
        export FLASK_APP=application
        flask run &
        '''
    }
   }
    stage ('Test') {
      steps {
        sh '''#!/bin/bash
        source test3/bin/activate
        py.test --verbose --junit-xml test-reports/results.xml
        '''
        } 
    
      post{
        always {
          junit 'test-reports/results.xml'
        }
       
      }
    }
    stage ('Docker Build'){
        agent { label 'dockerAgent' }
        steps {
            sh 'sudo docker build -t ishtaard/gunicorn-flask:latest .'
        }
    }
    stage ('Docker Push'){
        agent { label 'dockerAgent' }
        steps {
            sh '''#!/bin/bash
            echo $DOCKERHUB_CREDENTIALS_PSW | sudo docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
            sudo docker push ishtaard/gunicorn-flask:latest
            docker logout
            '''
            
        }
    }
    stage ('Terraform ECS Deploy'){
      agent { label 'terraformAgent' }
      steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'),
        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
            dir('intTerraform') {
              sh ''' #!/bin/bash
              terraform init
              terraform plan -out plan.tfplan -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"
              terraform apply plan.tfplan
              '''
            }
        }
      }
    }
    stage ('Terraform ECS Destroy') {
      agent { label 'terraformAgent' }
      steps {
        withCredentials([string(credentialsId: 'AWS_ACCESS_KEY', variable: 'aws_access_key'), 
        string(credentialsId: 'AWS_SECRET_KEY', variable: 'aws_secret_key')]) {
            dir('intTerraform') {
              sh 'terraform destroy --auto-approve -var="aws_access_key=$aws_access_key" -var="aws_secret_key=$aws_secret_key"'
            }
        }
      }
   }
 }
}