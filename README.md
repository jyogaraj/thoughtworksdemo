# Thoughtworks demo

Used cloudformation + opsworks.

## Installation cmdline

### Requires
- AWS account
- AWS iam role with access to ec2, elb, iam, opswork, s3bucket


```bash
aws cloudformation package --template-file thoughtworks-demo-cf-template.yml --s3-bucket <bucketName> --output-template-file packaged-template.yml
```
```bash
 aws cloudformation deploy --template-file packaged-template.yml --stack-name thoughtworks-demo-stack  --capabilities CAPABILITY_IAM --tags purpose=demo demoby=yogaraj.jawahar@gmail.com
```

## Installation Manual

- Login to aws and navigate to cloudformation service
- create stack
- Upload template file thoughtworks-demo-cf-template.yml
- Give stackname and Instance types for db and webserver
- Create stack


## Usage

- You can see the progress in cloudfromation console [ https://console.aws.amazon.com/cloudformation/home?region=us-east-1 ], Will take 10 mins to spinup the stack
- Once done output section of stack gives website url.
- opswork stack can be viewed at https://console.aws.amazon.com/opsworks/home?region=us-east-1


## Info

- thoughtworks-demo-cf-template.yml is cloudformation template
- thoughtworksdemo/ is chef cookbook 