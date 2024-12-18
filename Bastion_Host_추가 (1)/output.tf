output "public_ip" {
  value       = [
    aws_instance.ec2_3t_nginx_v1.public_ip,
    aws_instance.ec2_3t_nginx_v2.public_ip
  ]
  description = "The public IPs of the Nginx Instances"
}

output "public_dns" {
  value       = [
    aws_instance.ec2_3t_nginx_v1.public_dns,
    aws_instance.ec2_3t_nginx_v2.public_dns
  ]
  description = "The public DNS names of the Nginx Instances"
}

output "private_ip" {
  value       = [
    aws_instance.ec2_3t_nginx_v1.private_ip,
    aws_instance.ec2_3t_nginx_v2.private_ip
  ]
  description = "The private IPs of the Nginx Instances"
}

output "ssh_tunnel_command" {
  value = <<EOF
ssh -i ${aws_key_pair.aws-ssh-keypair.key_name}.pem -L 8080:${aws_instance.ec2_3t_tomcat.private_ip}:8080 ec2-user@${aws_instance.ec2_3t_nginx_v1.public_ip} -L 8081:${aws_instance.ec2_3t_nginx_v1.private_ip}:8080
EOF
}


