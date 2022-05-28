This ansible playbook will create a EC2 instance and install the custom application via a script and create a AMI from that.
That AMI will be hosted to marketplace by initiating a change set.

You require Ansible & AWS cli to run this.

inside the app install role a placeholder script is added. 
replace that script with the script to install your application.
