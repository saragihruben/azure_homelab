Please follow this instruction!

1. Set environment variable for service principal auth
   
    ``` export AZ_APP_ID="your-app-id" ```
       
    ``` export AZ_PASSWORD="your-client-secret" ```
       
    ``` export AZ_TENANT_ID="your-tenant-id" ```


2. Run az login with service principal
   
   ``` # az login --service-principal -u "xxxxxxxxxxxxxxxxxxxxxxxxxxxx" -p " xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" --tenant "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" ```


3. Run python script to generate .tfvars file
   
   ``` # python3 generate_tfvars.py ```


4. Run terraform to apply changes

   ``` # terraform apply -var-file="users.tfvars" -var-file="groups.tfvars" -var-file="memberships.tfvars" ```

5. Run python script to generate membership.tfvars file
   
   ``` # python3 generate_tfvars.py ```

6. Run terraform to apply changes

   ``` # terraform apply -var-file="users.tfvars" -var-file="groups.tfvars" -var-file="memberships.tfvars" ```

   
