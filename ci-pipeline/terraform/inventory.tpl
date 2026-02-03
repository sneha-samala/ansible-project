[frontend]
c8.local ansible_host=${frontend_ip} ansible_user=ec2-user

[backend]
u21.local ansible_host=${backend_ip} ansible_user=ubuntu
