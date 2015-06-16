## This file was auto-generated by CloudCoreo CLI
## This file was automatically generated using the CloudCoreo CLI
##
## This config.rb file exists to create and maintain services not related to compute.
## for example, a VPC might be maintained using:
##
## coreo_aws_vpc_vpc "my-vpc" do
##   action :sustain
##   cidr "12.0.0.0/16"
##   internet_gateway true
## end
##

coreo_aws_ec2_securityGroups "${CONSUL_SERVER_SG_NAME}-elb" do
  action :sustain
  description "load balance the consul ui"
  vpc "${VPC_NAME}"
  allows [ 
          { 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => [1199],
            :cidrs => ${VPN_ACCESS_CIDRS},
          },{ 
            :direction => :egress,
            :protocol => :tcp,
            :ports => ["0..65535"],
            :cidrs => ${VPN_ACCESS_CIDRS},
          }
    ]
end

coreo_aws_ec2_elb "${CONSUL_SERVER_SG_NAME}-elb" do
  action :sustain
  type "private"
  vpc "${VPC_NAME}"
  subnet "${PRIVATE_SUBNET_NAME}"
  security_groups ["${CONSUL_SERVER_SG_NAME}-elb"]
  listeners [
             {
               :elb_protocol => 'tcp', 
               :elb_port => 8500, 
               :to_protocol => 'tcp', 
               :to_port => 8500
             }
            ]
  health_check_protocol 'http'
  health_check_path "/ui"
  health_check_port "8500"
  health_check_timeout 5
  health_check_interval 30
  health_check_unhealthy_threshold 5
  health_check_healthy_threshold 2
end

coreo_aws_route53_record "${CONSUL_SERVER_SG_NAME}" do
  action :sustain
  type "CNAME"
  zone "${DNS_ZONE}"
  values ["STACK::coreo_aws_ec2_elb.${CONSUL_SERVER_SG_NAME}-elb.dns_name"]
end

coreo_aws_ec2_securityGroups "${CONSUL_SERVER_SG_NAME}" do
  action :sustain
  description "consul server security group"
  vpc "${VPC_NAME}"
  allows [ 
         { 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => [8500],
            :groups => ["${CONSUL_SERVER_SG_NAME}-elb"],
          },
          { 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => [8300,8301,8302,8400,8500,8600],
            :cidrs => ${CONSUL_INGRESS_CIDRS}
          },
          { 
            :direction => :ingress,
            :protocol => :udp,
            :ports => [8301, 8302, 8600],
            :cidrs => ${CONSUL_INGRESS_CIDRS}
          },
          { 
            :direction => :ingress,
            :protocol => :tcp,
            :ports => [22],
            :cidrs => ${CONSUL_INGRESS_CIDRS}
          },
          { 
            :direction => :egress,
            :protocol => :udp,
            :ports => ['0..65535'],
            :cidrs => ['0.0.0.0/0']
          },
          { 
            :direction => :egress,
            :protocol => :tcp,
            :ports => ['0..65535'],
            :cidrs => ['0.0.0.0/0']
          }
    ]
end

coreo_aws_iam_policy "${CONSUL_NAME}" do
  action :sustain
  policy_name "ConsulServerIAMPolicy"
  policy_document <<-EOH
{
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
          "*"
      ],
      "Action": [ 
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
      ]
    }
  ]
}
EOH
end

coreo_aws_iam_instance_profile "${CONSUL_NAME}" do
  action :sustain
  policies ["${CONSUL_NAME}"]
end

coreo_aws_ec2_instance "${CONSUL_NAME}" do
  action :define
  image_id "${CONSUL_AMI}"
  size "${CONSUL_SIZE}"
  security_groups ["${CONSUL_SERVER_SG_NAME}"]
  role "${CONSUL_NAME}"
  ssh_key "${CONSUL_KEY}"
end

coreo_aws_ec2_autoscaling "${CONSUL_NAME}" do
  action :sustain 
  minimum ${CONSUL_GROUP_SIZE_MIN}
  maximum ${CONSUL_GROUP_SIZE_MAX}
  server_definition "${CONSUL_NAME}"
  subnet "${PRIVATE_SUBNET_NAME}"
  elbs ["${CONSUL_SERVER_SG_NAME}-elb"]
end
