AWS School Management System — Terraform



A cloud-hosted School Management System webpage deployed on AWS using Terraform Infrastructure as Code (IaC).



Project Overview



This project demonstrates how to provision AWS infrastructure and deploy a static website on an EC2 instance using Terraform.



The website is stored in a private Amazon S3 bucket and downloaded automatically by the EC2 instance during initialization.



Architecture



&#x20;                 Internet

&#x20;                     |

&#x20;              Internet Gateway

&#x20;                     |

&#x20;                 AWS VPC

&#x20;                10.0.0.0/16

&#x20;                     |

&#x20;             Public Subnets

&#x20;              /          \\

&#x20;         Subnet 1       Subnet 2

&#x20;         10.0.1.0/24    10.0.2.0/24

&#x20;              |

&#x20;          EC2 Instance

&#x20;          Amazon Linux 2023

&#x20;              |

&#x20;            Nginx

&#x20;              |

&#x20;      School Management Website

&#x20;              |

&#x20;         Private S3 Bucket

&#x20;         School.html



AWS Services Used



Service



Purpose



Amazon VPC



Isolated cloud network



Public Subnets



Network placement for resources



Internet Gateway



Internet connectivity



Route Table



Routes internet-bound traffic



Security Group



Controls inbound and outbound traffic



Amazon EC2



Hosts the website



Amazon S3



Stores the website HTML file



AWS IAM Role



Grants EC2 permission to access S3



IAM Instance Profile



Attaches the IAM role to EC2



Terraform



Provisions infrastructure as code



Technologies



Terraform



AWS



Amazon Linux 2023



Nginx



Amazon S3



AWS IAM



Git and GitHub



Project Structure



terraform-school-management-system/

│

├── main.tf

├── School.html

├── .gitignore

└── .terraform.lock.hcl



Deployment



Prerequisites



AWS account



AWS CLI configured with appropriate credentials



Terraform installed



Git installed



GitHub CLI installed



1\. Clone the repository



git clone https://github.com/talha-zahoor-isra/terraform-school-management-system.git

cd terraform-school-management-system



2\. Initialize Terraform



terraform init



3\. Validate configuration



terraform validate



4\. Review infrastructure changes



terraform plan



5\. Deploy infrastructure



terraform apply



Review the plan and enter yes when prompted.



Website Access



After deployment, locate the EC2 instance's public IPv4 address in the AWS Console.



Open the following URL in your browser:



http://YOUR-EC2-PUBLIC-IP



Security Configuration



HTTP access is allowed on port 80.



SSH access on port 22 is restricted to a specified public IP address.



The S3 bucket blocks public access.



EC2 uses an IAM role instead of storing AWS access keys on the instance.



IAM permissions are restricted to reading the website object from S3.



Terraform state files and private credentials are excluded from Git.



Note: Update the SSH security group CIDR if your public IP address changes.



Learning Outcomes



Through this project, I gained practical experience with:



AWS networking and VPC configuration.



Terraform resource provisioning and dependency management.



EC2 instance deployment and initialization.



IAM roles and least-privilege permissions.



Private S3 object access.



Nginx web server configuration.



Git and GitHub version control.



Author



Talha Zahoor



GitHub: https://github.com/talha-zahoor-isra



Project Repository: https://github.com/talha-zahoor-isra/terraform-school-management-system

