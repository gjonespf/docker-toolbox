#!groovy
def executeXplat(commandString) {
    if (isUnix()) {
        sh commandString
    } else {
        bat commandString
    }
}

node {
    agent { label 'xplat-cake' } 

    environment { 
        BUILD_HOST = 'Jenkins'
    }

    // pull request or feature branch
    if  (env.BRANCH_NAME != 'master') {
        checkout()
        init()
        build()
        // test whether this is a regular branch build or a merged PR build
        if (!isPRMergeBuild()) {
            codeTest()
        } 
        unitTest()
        doPackaging()
        publish()
        doArchiveArtifacts()
    } // master branch / production
    else { 
        checkout()
        init()
        build()
        //allTests()
        codeTest()
        unitTest()
        doPackaging()
        publish()
        // Generate releases?
        // Notifies?
        doArchiveArtifacts()
    }

    // post {
    //     always {
    //         archiveArtifacts allowEmptyArchive: true, artifacts: 'BuildArtifacts/**', fingerprint: true
    //     }
    // }
}


def isPRMergeBuild() {
    return (env.BRANCH_NAME ==~ /^PR-\d+$/)
}

def checkout () {
    stage ('Checkout') {
        // context="continuous-integration/jenkins/"
        // context += isPRMergeBuild()?"pr-merge/checkout":"branch/checkout"
        checkout scm
        // setBuildStatus ("${context}", 'Checking out completed', 'SUCCESS')
    }
}

def init () {
    stage ('Init') {
        echo 'Initializing...'
        //executeXplat("pwsh -ExecutionPolicy Bypass -Command \"& ./build.ps1 -Target Init \" ")
        if (isUnix()) 
        {
            echo 'Running on Unix...'
            sh "./build.sh -t \"Init\"" 
        } else  {
            echo 'Running on Windows...'
            bat "powershell -ExecutionPolicy Bypass -Command \"& './build.ps1' -Target \"Init\"\""
        }
    }
}

def build () {
    stage ('Build')
    {
        echo 'Building...'
        //executeXplat("pwsh -ExecutionPolicy Bypass -Command \"& ./build.ps1 -Target Build \" ")
        if (isUnix()) 
        {
            echo 'Running on Unix...'
            sh "./build.sh -t \"Build\"" 
        } else  {
            echo 'Running on Windows...'
            bat "powershell -ExecutionPolicy Bypass -Command \"& './build.ps1' -Target \"Build\"\""
        }
    }
}

def unitTest() {
    stage ('Unit tests') {
        echo 'Running unit tests...'
        //executeXplat("pwsh -ExecutionPolicy Bypass -Command \"& ./build.ps1 -Target UnitTest \" ")
        if (isUnix()) 
        {
            echo 'Running on Unix...'
            sh "./build.sh -t \"UnitTest\"" 
        } else  {
            echo 'Running on Windows...'
            bat "powershell -ExecutionPolicy Bypass -Command \"& './build.ps1' -Target \"UnitTest\"\""
        }
    }
}

def codeTest() {
    stage ('Code tests') {
        echo 'Running code tests...'
        //executeXplat("pwsh -ExecutionPolicy Bypass -Command \"& ./build.ps1 -Target CodeTest \" ")
        if (isUnix()) 
        {
            echo 'Running on Unix...'
            sh "./build.sh -t \"CodeTest\"" 
        } else  {
            echo 'Running on Windows...'
            bat "powershell -ExecutionPolicy Bypass -Command \"& './build.ps1' -Target \"CodeTest\"\""
        }
    }
}

def doPackaging() {
    stage ('Package') {
        echo 'Packaging...'
        //executeXplat("pwsh -ExecutionPolicy Bypass -Command \"& ./build.ps1 -Target Package \" ")
        if (isUnix()) 
        {
            echo 'Running on Unix...'
            sh "./build.sh -t \"Package\"" 
        } else  {
            echo 'Running on Windows...'
            bat "powershell -ExecutionPolicy Bypass -Command \"& './build.ps1' -Target \"Package\"\""
        }
    }
}

def publish() {
    stage ('Publish')
    {
        withCredentials([
            usernamePassword(credentialsId: 'e162c9e0-0792-472d-a01e-51f2b7427f2b', passwordVariable: 'OCTOAPIKEY', usernameVariable: 'OCTOSERVER'),
            usernamePassword(credentialsId: '74207640-6946-44f4-8175-171e9d807193', passwordVariable: 'OCTOCLOUDAPIKEY', usernameVariable: 'OCTOCLOUDSERVER'),
            usernamePassword(credentialsId: '74d7f630-d422-4324-89f2-6ebccc3b3687', passwordVariable: 'LocalNugetApiKey', usernameVariable: 'LocalNugetServerUrl'),
            usernamePassword(credentialsId: '74a39230-d94d-4660-b686-daf40f89e462', passwordVariable: 'LocalChocolateyApiKey', usernameVariable: 'LocalChocolateyServerUrl')
            ]) 
        {
            echo 'Publishing...'
            //executeXplat("pwsh -ExecutionPolicy Bypass -Command \"& ./build.ps1 -Target Publish \" ")
            if (isUnix()) 
            {
                sh "./build.sh -t \"Publish\"" 
            } else  {
                bat "powershell -ExecutionPolicy Bypass -Command \"& './build.ps1' -Target \"Publish\"\""
            }
        }
    }
}


def doArchiveArtifacts() {
    stage ('Archive') {
        echo 'Archiving artifacts...'
        //executeXplat("pwsh -ExecutionPolicy Bypass -Command \"& ./build.ps1 -Target Package \" ")
        archiveArtifacts allowEmptyArchive: true, artifacts: 'BuildArtifacts/**', fingerprint: true
    }
}
