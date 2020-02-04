#!/usr/bin/env bash

set -eo pipefail;

vpc_name="$instance.byVelocity("vpc_velocity_name").getAttribute("vpc_name")";
security_group_name="$instance.parent.getAttribute("security_group_name")";
subnet_name="$instance.parent.getAttribute("subnet_name")";
aws_region="$instance.parent.getAttribute("aws_region")";
bastion_name="$instance.parent.getAttribute("bastion_name")";
ssh_bastion_username="$instance.parent.getAttribute("ssh_bastion_username")";
ssh_bastion_private_key_file="$instance.parent.getAttribute("ssh_bastion_private_key_file")";
#if ($instance.getAttribute("source_ami") == "")
parent_ami_prefix="$instance.parent.getAttribute("ami_name_prefix")";
#else
parent_ami_prefix="";
#end
#[[

run_aws_packer --packer_directory "$default_module_dir/packer" \
	--vpc_name "$vpc_name" \
	--security_group_name "$security_group_name" \
	--subnet_name "$subnet_name" \
	--aws_region "$aws_region" \
    --ami_name_prefix "$ami_name_prefix" \
    --ami_description "$ami_description" \
    --parent_ami_prefix "$parent_ami_prefix" \
    --bastion_name "$bastion_name" \
    --ssh_bastion_username "$ssh_bastion_username" \
    --ssh_bastion_private_key_file "$ssh_bastion_private_key_file";

]]#
