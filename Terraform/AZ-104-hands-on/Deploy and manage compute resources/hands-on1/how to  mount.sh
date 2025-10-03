mount_azure_file_share:
  stage: configure
  script:
    - sudo mkdir -p /media/nfs-homelab
    - sudo mkdir -p /etc/smbcredentials
    - echo "username=$AZURE_FILE_USERNAME" | sudo tee /etc/smbcredentials/azfilesharehomelab.cred
    - echo "password=$AZURE_FILE_PASSWORD" | sudo tee -a /etc/smbcredentials/azfilesharehomelab.cred
    - sudo chmod 600 /etc/smbcredentials/azfilesharehomelab.cred
    - echo "//azfilesharehomelab.file.core.windows.net/nfs-homelab /media/nfs-homelab cifs nofail,credentials=/etc/smbcredentials/azfilesharehomelab.cred,dir_mode=0755,file_mode=0755,serverino,nosharesock,mfsymlinks,actimeo=30" | sudo tee -a /etc/fstab
    - sudo mount -a

sudo mkdir -p /media/nfs-homelab
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/azfilesharehomelab.cred" ]; then
    sudo bash -c 'echo "username=azfilesharehomelab" >> /etc/smbcredentials/azfilesharehomelab.cred'
    sudo bash -c 'echo "password=9h25jnMiWMNHRvKeCi+8ghtEUYw0I6V6Y+lsm2YEKplz+il4oRHx8bnEQN2Lx+Y/x9oNm1ur7enB+ASt0FLjTg==" >> /etc/smbcredentials/azfilesharehomelab.cred'
fi
sudo chmod 600 /etc/smbcredentials/azfilesharehomelab.cred

sudo bash -c 'echo "//azfilesharehomelab.file.core.windows.net/nfs-homelab /media/nfs-homelab cifs nofail,credentials=/etc/smbcredentials/azfilesharehomelab.cred,dir_mode=0755,file_mode=0755,serverino,nosharesock,mfsymlinks,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //azfilesharehomelab.file.core.windows.net/nfs-homelab /media/nfs-homelab -o credentials=/etc/smbcredentials/azfilesharehomelab.cred,dir_mode=0755,file_mode=0755,serverino,nosharesock,mfsymlinks,actimeo=30