# Serverless Blueprint
Quick setup for a full CI/CD serverless application on AWS.

## What is it?

This package creates a simple TypeScript serverless application and all the infrastructure for continuous deployment of that application.

The code is stored in a CodeCommit repository. CodePipeline tracks changes to that repository and runs builds through CodeBuild and then deploys all of the resources through CloudFormation. The application starts with a Hello World Lambda Function and an API Gateway endpoint for calling that function. 


## Setup
Download and setup the AWS CLI tool if you haven't already.

`$ git clone https://github.com/dshields1/ServerlessBlueprint.git`
`$ cd ServerlessBlueprint`
`$ ./blueprint.sh`


## Future Improvements

1. Move to a node command line tool instead of a bash script
2. Add a test stage to pipeline, or test in the build action
3. Add more sample resources to the base application