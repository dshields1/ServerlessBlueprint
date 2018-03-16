#!/bin/bash
echo Starting application bootstrap

read -p 'Project Name: ' projectName
lowerProjectName="$(echo $projectName | tr '[A-Z]' '[a-z]')"
stackSuffix='-FoundationStack'
bucketSuffix='-deployment-bucket'

read -p 'To use Github, enter `yes`: ' useGithub
if [ "$useGithub" == "yes" ]; then
    echo "Using Github!"
else
    echo "Using CodeCommit!"
fi

echo Creating $projectName$stackSuffix
if [ "$useGithub" == "yes" ]; then
    read -p 'Github repo name: ' githubRepoName
    read -p 'Github username: ' githubUsername
    read -p 'Github token: ' githubToken
    githubRepoUrl="https://github.com/$githubUsername/$githubRepoName.git"
    aws cloudformation --region us-east-1 create-stack --stack-name $projectName$stackSuffix --template-body file:///$PWD/aws-scaffold.yml --parameters ParameterKey=ProjectName,ParameterValue=$lowerProjectName ParameterKey=RepositoryType,ParameterValue=Github ParameterKey=GithubRepo,ParameterValue=$githubRepoName ParameterKey=GithubOwner,ParameterValue=$githubUsername ParameterKey=GithubToken,ParameterValue=$githubToken --capabilities CAPABILITY_IAM
else
    aws cloudformation --region us-east-1 create-stack --stack-name $projectName$stackSuffix --template-body file:///$PWD/aws-scaffold.yml --parameters ParameterKey=ProjectName,ParameterValue=$lowerProjectName --capabilities CAPABILITY_IAM
fi

echo Waiting for stack to finish
aws cloudformation --region us-east-1 wait stack-create-complete --stack-name $projectName$stackSuffix

echo Stack created successfully

echo Checking out source repo

if [ "$useGithub" == "yes" ]; then
    git clone $githubRepoUrl
    cd $githubRepoName
else
    git config --global credential.helper '!aws codecommit credential-helper $@'
    git config --global credential.UseHttpPath true
    git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/$lowerProjectName
    cd $lowerProjectName
    git checkout -b master
fi

cp -r ../blueprint/* .

sed -i -e 's/REPLACE_S3_BUCKET/'$lowerProjectName$bucketSuffix'/g' buildspec.yml

git add cloudformation/template.yml
git add src/.
git add buildspec.yml
git add package.json
git add tsconfig.json

git commit -m "Commit by ServerlessBlueprint."

git push

cd ..

if [ "$useGithub" == "yes" ]; then
    rm -r $githubRepoName
else
    rm -r $lowerProjectName
fi
