#!groovy

/*
The MIT License

Copyright (c) 2015-, CloudBees, Inc., and a number of other of contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

node('node') {


    currentBuild.result = "SUCCESS"

    try {

       stage('Checkout'){

          checkout scm
       }

       stage('Test'){

         env.NODE_ENV = "test"

         print "Environment will be : ${env.NODE_ENV}"

         sh './test.sh'
       }

       stage('Build Docker & Push'){
          print "Install docker"
          sh 'apt-get update'
          sh 'apt-get install -y docker.io'
          print "Connect to Registry "
          docker.withRegistry("https://index.docker.io/v1/", 'docker_login'){
            print "Build Image "
            def pcImg = docker.build("guismo/front-end:${env.BUILD_ID}", 'front-end')
            print 'Push to Repo'
            pcImg.push()
          }
       }

       stage('Deploy'){
         print "Install sshpass"
         sh "apt-get install -y sshpass"
         withCredentials([usernamePassword(credentialsId: 'ssh_login', usernameVariable: 'SSH_USER', passwordVariable: 'SSH_PASS')]) {
            print 'ssh to laptop and update deployment'
            sh "sshpass -p $SSH_PASS ssh -oStrictHostKeyChecking=no $SSH_USER@192.168.65.2 cp PereCastor/complete-demo.yaml PereCastor/patch.yaml"
            print "display build id"
            print "Build ID: ${env.BUILD_ID}"
            sh "sshpass -p $SSH_PASS ssh -oStrictHostKeyChecking=no $SSH_USER@192.168.65.2 rpl \"guismo/front-end:0.3.12\" \"guismo/front-end:${env.BUILD_ID}\" PereCastor/patch.yaml"
            print "Before apply"
            sh "sshpass -p $SSH_PASS ssh -oStrictHostKeyChecking=no $SSH_USER@192.168.65.2 /Users/gmorini/Downloads/google-cloud-sdk/bin/kubectl -n sock-shop apply -f PereCastor/patch.yaml"
         }

       }

       stage('Cleanup'){

         echo 'prune and cleanup'

         mail body: 'project build successful',
                     from: 'jenkins@cisco.com',
                     replyTo: 'gmorini@cisco.com',
                     subject: 'project build successful',
                     to: 'gmorini@cisco.com'
       }



    }
    catch (err) {

        currentBuild.result = "FAILURE"

            mail body: "project build error is here: ${env.BUILD_URL}" ,
            from: 'jenkins@cisco.com',
            replyTo: 'gmorini@cisco.com',
            subject: 'project build failed',
            to: 'gmorini@cisco.com'

        throw err
    }

}
