server 'ec2-52-67-178-12.sa-east-1.compute.amazonaws.com', user: 'ubuntu', roles: %w{app db web}
set :ssh_options, {
  keys: %w(~/.ssh/keys/personal-aws.pem),
  auth_methods: %w(publickey)
}
