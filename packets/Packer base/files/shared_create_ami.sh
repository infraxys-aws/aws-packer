#!/usr/bin/env bash

set -eo pipefail;

vpc_name="$instance.getAttribute("vpc_name")";
security_group_name="$instance.parent.getAttribute("security_group_name")";
subnet_name="$instance.parent.getAttribute("subnet_name")";
aws_region="$instance.parent.getAttribute("aws_region")";
bastion_name="$instance.parent.getAttribute("bastion_name")";
ssh_bastion_username="$instance.parent.getAttribute("ssh_bastion_username")";
ssh_bastion_private_key_file="$instance.parent.getAttribute("ssh_bastion_private_key_file")";
packer_directory="$instance.getAttribute("packer_directory")";
image_owners="$instance.getAttribute("image_owners")";
vault_config_variable="$instance.getAttribute("vault_config_variable")";

if [ -n "${D}aws_core_vault_config_variable" ]; then
	[[ -z "${D}AWS_PROFILE" ]] && log_fatal "AWS_PROFILE should be set to retrieve the SSH config and keys.";
	generate_ssh_config_for_vpc --vpc_name "$instance.parent.getAttribute("vpc_name")";
	get_ssh_keys_from_vault --vault_config_variable "${D}vault_config_variable";
fi;
#[[

run_aws_packer --packer_directory "$default_module_dir/$packer_directory" \
    --packer_version "$packer_version" \
	--vpc_name "$vpc_name" \
	--security_group_name "$security_group_name" \
	--subnet_name "$subnet_name" \
	--aws_region "$aws_region" \
	--source_ami "$source_ami" \
    --ami_name_prefix "$ami_name_prefix" \
    --image_owners "$image_owners" \
    --ami_description "$ami_description" \
    --bastion_name "$bastion_name" \
    --ssh_bastion_username "$ssh_bastion_username" \
    --ssh_bastion_private_key_file "$ssh_bastion_private_key_file";

]]#
