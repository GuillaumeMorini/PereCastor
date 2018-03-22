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

       stage('Build Docker'){

            sh './dockerBuild.sh'
       }

       stage('Deploy'){

         echo 'Push to Repo'
         withCredentials([usernamePassword(credentialsId: 'docker_login', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh '''
              #set +x 
              echo "docker login" $DOCKER_USER $DOCKER_PASS
              ./dockerPushToRepo.sh $DOCKER_USER $DOCKER_PASS
            '''
         }

         echo 'ssh to laptop and update deployment'
         echo 'ssh deploy@192.168.65.2 kubectl get po -n sock-shop'

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
