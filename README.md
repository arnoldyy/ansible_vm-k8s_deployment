deploying k8s in VM
Test env: wsl ubuntu 24.02 WSL

to meet ansible env: ./ansible_deps/install_deps_virtual.sh
source venv/bin/activate

ensure ssh.service is enabled

``` make key connection
ssh-keygen -t rsa -b 4096
ssh-copy-id ubuntu@192.168.x.x
```