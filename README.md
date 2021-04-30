# Trevor Dennis - Engineering Assessment

*The following project was created using Terraform version 0.15.0.*

Provider information will be needed to apply. Create a file in the project folder with the following provider infromation to set the region and AWS access. 
```
provider "aws" {
  region     = ""
  access_key = ""
  secret_key = ""
}
```

* From the terminal CD into the project folder and run the following to initialize the Terraform Environment.
     ```
     terraform init
     ```
* To plan the build run the following.
     ```
     terraform plan
     ```
* To apply the Terraform execution plan 
     ```
     terraform apply
     ```
* Open the created S3 bucket "rates-inbox" and upload json data in the following form.
    ```
    {"TimeStamp": N, "RateType": "S", "RateValue": N}
    ```
* The data can be found in the DynamoDB table "Rates."
* Once testing is complete or the configuration is no longer needed run the destroy command to clean up all the resources provisioned in AWS.
     ```
     terraform destroy
     ```

## Process flow

![alt text](https://github.com/trevtech84/trvr-ea/blob/main/flowchart.png?raw=true)

*Note: Missing API calls*

Once Terraform finishes building the environment, files with rates to be processed can be uploaded into the "rates-inbox" bucket. Files should have the .json extension. Other files without the .json will not be processed and will remain in the bucket root. Files should contain json data in the following form.
    ```
    {"TimeStamp": N, "RateType": "S", "RateValue": N}
    ```
Once each qualifying file is uploaded the lambda process_rate.py is triggered and gathers the .json file. The json file is then processed and the data is sent off to the dynamodb table "Rates'' for storage. The json file is then copied from the bucket root to the archive folder. Then the original file is deleted leaving the root clean of .json files.

## Steps yet to complete:
* Move specific components to their own modules.
* API endpoints.
    * Latest/most current interest rate.
    * List of all interest rates.
    * Request a rate from a given point in time.


## Considerations
* It would probably be better to move files to a different S3 bucket. Creating the archive folder in the same
bucket would allow files to be uploaded in the archive folder. Resulting in the lambda function kicking off again and creating a sub archive folder. Potentially leading to an endless rabbit hole. Copying files to another S3 bucket and potentially another region would allow for some redundancy incase of data loss in the primary location.
* Batch uploads do not always work. Uploading one file at a time is best.
* Service alerts
* Configure cloudwatch 
* The S3 bucket currently has "force_destroy = true." This was added to ease development workflow. Depending on the situation this should probably be removed from a live production deployment.
* Unit tests
* Files that are uploaded that do not qualify for the lambda function should be logged and moved or removed from the S3 bucket.
