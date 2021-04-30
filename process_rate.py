import boto3
import json
import urllib.parse

def lambda_handler(event, context):
    s3 = boto3.resource('s3')
    # Get bucket name
    bucket = event['Records'][0]['s3']['bucket']['name']
    # Get bucket key
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    #Get s3 object
    content_object = s3.Object(bucket, key)
    #Change from dict to str
    file_content = content_object.get()['Body'].read().decode('utf-8')
    #Read json file
    rate = json.loads(file_content)
    #Get DB
    dynamodb = boto3.resource('dynamodb')
    #Set table var
    table = dynamodb.Table('Rates')
    #Write .json contents into DB 
    table.put_item(Item=rate)
    #Create folder and archive processed file into it.
    s3 = boto3.client('s3')
    #Move rate file to the archive folder
    s3.put_object(Bucket=bucket, Key='archive/'+key+'.archive', Body=file_content)
    #Delete original upload
    s3.delete_object(Bucket=bucket, Key=key)
    return key