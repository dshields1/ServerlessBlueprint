#!/bin/bash
echo Starting application bootstrap

read -p 'Project Name: ' projectName
lowerProjectName="$(echo $projectName | tr '[A-Z]' '[a-z]')"
stackSuffix='-FoundationStack'
bucketSuffix='-deployment-bucket'

echo Creating $projectName$stackSuffix
aws cloudformation --region us-east-1 create-stack --stack-name $projectName$stackSuffix --template-body file:///$PWD/aws-scaffold.yml --parameters ParameterKey=ProjectName,ParameterValue=$lowerProjectName --capabilities CAPABILITY_IAM

echo Waiting for stack to finish
aws cloudformation --region us-east-1 wait stack-create-complete --stack-name $projectName$stackSuffix

echo Stack created successfully

echo Checking out source repo

git config --global credential.helper '!aws codecommit credential-helper $@' 
git config --global credential.UseHttpPath true 

git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/$lowerProjectName

cd $lowerProjectName
git checkout -b master

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

rm -r $lowerProjectName