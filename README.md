# Trevor Dennis - Engineering Assessment

Terraform version 0.15.0

Once the repo has been downloaded a provider.tf file will need to be added to the project folder with the following information. 

A provider.tf file with the following information will be needed in the project folder.
provider "aws" {
  region     = ""
  access_key = ""
  secret_key = ""
}

* From within the project folder run the following to initalize the Terraform Environemnt.
     ```
     terraform init
     ```
* To plan the build run the following.
     ```
     terraform plan
     ```
* Now apply the Terraform execution plan 
     ```
     terraform apply
     ```
* Open the created S3 bucket "rates-inbox" and upload json data in the following form.
    {"TimeStamp": N, "RateType": "S", "RateValue": N}
* The data can be found in the DynamoDB table "Rates."
* Once testing is complete or the configuration is no longer needed run the destroy command to clean up all the resources provisioned in AWS.
     ```
     terraform destroy
     ```

## Process flow

Once Terraform finishes bulding the envrionment, files with rates to be processed can be uploaded into the "rates-inbox" bucket. Files should should have the .json extension. Files should contain json data in the following form.
    {"TimeStamp": N, "RateType": "S", "RateValue": N}
Once each qualifying file is uploaded the lambda process_rate.py is triggerd and gathers the .json file. The json file is then processed and the data is sent off to the dynamodb table "Rates" for storage. The json file is then copied from the bucket root to the archive folder. Then the original file is deleted leaving the root clean of .json files.

## Steps yet to complete:
* API end points.
    * Latest/most current interest rate.
    * List of all interest rates.
    * Request a rate from a given point in time.


## Considerations
* It would probably be better to move files to a different S3 bucket. Creating the arcive folder in the same
bucket would allow files to be uploaded in the archive folder. Resulting in the lambda function kicking off again and creating a sub archive folder. Potentially leading to an endless rabbit hole. Copying files to another S3 bucket and potentially another region would allow for some redundancy incase of data loss in the primary location.
* Batch uploades do not always work. Uploading one file at a time is best.
* Service alerts
* Configure cloudwatch 
* The S3 bucket currently has "force_destroy = true." This was added to ease development workflow. Depending on the situation this should probably be removed from a live production deployment.
