#! /bin/sh
STATE="$(./gce.py | grep $CI_COMMIT_REF_NAME)"
if [ -z "$STATE" ]; then
   pwd
   terraform init
   terraform apply -var instance_name=$CI_COMMIT_REF_NAME -auto-approve exit 0
   sleep 300
   ansible-playbook main.yml   echo "empty"
else 
   echo "not empty"
fi  
