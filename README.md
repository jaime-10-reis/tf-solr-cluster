# tf-solr-cluster
Solr cluster with 3 servers and 3 zookeepers

0. Configure credentials

**Contents of file ~/.aws/credentials**

```
[default]
xaws_access_key_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xaws_secret_access_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


[vocareum]
aws_access_key_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
aws_secret_access_key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
aws_session_token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```
 
**Contents of file ~/.aws/config**

```
[default]
region = us-east-1
output = json
cli_history = enabled
cli_auto_prompt = on


[profile vocareum]
region = us-east-1
output = json
```


1. The first thing to do is run ```terraform init && terraform apply``` to create the S3 backend to store the Terraform state. Run this only once.

<img width="963" alt="image" src="https://user-images.githubusercontent.com/3796667/166132880-cf9ad5be-4e65-47e6-b3b8-0b17a8d7dab3.png">


2. Run ```terraform init && terraform apply``` to create the VPC. The Terraform state is stored in S3 in the bucket created in step 1.

<img width="963" alt="image" src="https://user-images.githubusercontent.com/3796667/166132954-6faa8249-fe99-4b94-ac1b-e25b6afacaec.png">

3. Run ```terraform init && terraform apply``` to create the Solr cloud with 3 servers and 3 Zookeepers. Make adjustments as needed. 

<img width="988" alt="image" src="https://user-images.githubusercontent.com/3796667/166133000-967800e5-7f44-4fd2-ab9e-d18bd81f8c8d.png">

4. Navigate to **http://<solr_public_ip>:8983** to checkout Solr. _Wait at least 5 minutes after terraform apply finishes in step 3._

<img width="1419" alt="image" src="https://user-images.githubusercontent.com/3796667/166133150-e3afc652-6936-4014-af18-ba58dc9394ba.png">

5. [Learn Apache Solr](https://www.google.com/search?q=learn+apache+solr&rlz=1C5CHFA_enPT818PT818&oq=learn+apache+Solr&aqs=chrome.0.0i512j0i22i30j0i390l3.4282j0j7&sourceid=chrome&ie=UTF-8)
