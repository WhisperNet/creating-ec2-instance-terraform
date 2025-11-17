output public-ip {
  value       = module.nginx-webserver.public-ip
  description = "Public IP of the nginx server"
}