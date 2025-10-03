Please follow this instruction!

1. Set environment variable for service principal auth
   
    ``` export AZ_APP_ID="your-app-id" ```
       
    ``` export AZ_PASSWORD="your-client-secret" ```
       
    ``` export AZ_TENANT_ID="your-tenant-id" ```


2. Run az login with service principal
   
   ``` # az login --service-principal -u "881f3a90-70fc-4a5c-af8e-dc9c44d97f31" -p " baf8Q~F759OM.o_Qxi7CgT7m94ZM2Mxg2HUCkazh" --tenant "b1300899-1d95-488c-aa1b-cd5323c7676b" ```


3. Run python script to generate .tfvars file
   
   ``` # python3 generate_tfvars.py ```


4. Run terraform to apply changes

   ``` # terraform apply -var-file="users.tfvars" -var-file="groups.tfvars" -var-file="memberships.tfvars" ```

5. Run python script to generate membership.tfvars file
   
   ``` # python3 generate_tfvars.py ```

6. Run terraform to apply changes

   ``` # terraform apply -var-file="users.tfvars" -var-file="groups.tfvars" -var-file="memberships.tfvars" ```

   