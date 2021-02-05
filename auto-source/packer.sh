function run_aws_packer() {
	local function_name=run_packer packer_directory ami_name_prefix image_owners ami_description source_ami vpc_name \
	    bastion_name ssh_bastion_username ssh_bastion_private_key_file security_group_name subnet_name aws_region packer_version="1.5.6";
	import_args "$@";
	check_required_arguments $function_name packer_directory ami_name_prefix ami_description vpc_name \
	    bastion_name ssh_bastion_username ssh_bastion_private_key_file security_group_name subnet_name aws_region;

	local ssh_bastion_host vpc_id;
	export AWS_DEFAULT_REGION="$aws_region";
    export PACKER_VERSION="$packer_version";
	ensure_packer --packer_version "$packer_version";
	
    get_vpc_id --vpc_name "$vpc_name" --target_variable_name vpc_id;
    get_security_group_id --vpc_id "$vpc_id" --security_group_name $security_group_name --target_variable_name security_group_id;
    get_subnet_id --vpc_id "$vpc_id" --subnet_name $subnet_name --target_variable_name subnet_id;
    get_instance_public_dns --instance_name "$bastion_name" --vpc_id "$vpc_id" --target_variable_name ssh_bastion_host;

    log_info "Initializing Packer environment using $packer_directory.";
    export vpc_id security_group_id subnet_id ssh_bastion_host ssh_bastion_private_key_file;
    log_info "Using bastion $ssh_bastion_host and private key $ssh_bastion_private_key_file";

    if [ ! -f "$ssh_bastion_private_key_file" ]; then
      log_fatal "\Bastion private key file doesn't exist: $ssh_bastion_private_key_file.";
    fi;
    log_info "Using vpc '$vpc_id', security group '$security_group_id', subnet '$subnet_id' and bastion '$ssh_bastion_host'.";

    export packer_tmp_dir="/tmp/packer$$";
    export packer_target_dir="/tmp/packer$$";
    mkdir $packer_tmp_dir;

    if [ -d "$packer_directory/provisioner" ]; then
      cp -R $packer_directory/provisioner/* $packer_tmp_dir;
    fi;

    run_or_source_files --directory "$packer_directory" --filename_pattern 'init*';

    if [ -f "$INSTANCE_DIR/packer.json" ]; then
        local json_filename="$INSTANCE_DIR/packer.json";
        log_info "Using packer.json from the packet.";
        cat "$json_filename"
    else
        local json_filename="$packer_directory/packer.json";
        log_info "Packet doesn't contain a file name 'packer.json', so using $json_filename instead";
        [[ ! -f "$json_filename" ]] && log_error "File '$json_filename' must exist." && exit 1;

        if [ -n "$source_ami" ]; then
            if [[ "$source_ami" != ami-* ]]; then
                local owners_arg="";
                log_info "Looking for AMI with name starting with '$source_ami'";
                get_ami --ami_name_prefix "$source_ami" --owners "$image_owners" --target_variable_name source_ami;
            fi;
        fi;
        if [ -z "$source_ami" ]; then
          log_error "Unable to find an AMI with name starting with '$source_ami'";
        fi;
        log_info "Using source ami '$source_ami'";
        export source_ami;
    fi;

    extra_packer_options="";
    if [ "$debug_mode" == "1" ]; then
        extra_packer_options="-debug";
        export PACKER_LOG=1;
    fi;

    [[ "$do_encrypt_boot" == "1" ]] && export encrypt_boot="true" || export encrypt_boot="false";

    oldpwd="$(pwd)";

    cd $packer_tmp_dir

    $PACKER build $extra_packer_options -machine-readable $json_filename | tee result.out

    grep 'artifact,0,id' result.out | cut -d, -f6 | cut -d: -f2
    ami_id="$(grep 'artifact,0,id' result.out | cut -d, -f6 | cut -d: -f2)";

    echo "--------- ami: --$ami_id-- --------";
    cd $oldpwd;
}

