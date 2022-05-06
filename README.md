1. Go into `ecs-cluster`. Run that as a terraform module to start up the cluster and a NLB. Please note down the NLB address.
2. Create the Temporal Images with your configurations and push them in ECR. Keep a note of the ECR URLs (we'll use them to start up the services)
3. Go into `temporal-cluster/database`. Run the terraform module to create the database. 
4. Go into `temporal-cluster/temporal`. RUn the module to start up the temporal services.

At this point the temporal services will not run properly because they are not auto-setup.

5. Go into `temporal-cluster/schema-migration`. Run the script `build_deploy.sh`. This will deploy the lambda to AWS. Go into AWS console and execute the lambda with the following inputs:
```
{
  "eventType": "migrate"
}
```
This will create the default database schema. 

Run the lambda with the following input next:
```
{
  "eventType": "createNamespace",
  "name": "testNamespace"
}
```
This will create a namespace.

You should be setup with this.
