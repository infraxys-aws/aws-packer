#[[
log_info "Creating directory /tmp/packer/infraxys/$targetDirectory";
mkdir -p "/tmp/packer/infraxys/$targetDirectory";

eval "$pre_run_script";
]]#

#if ($instance.getAttribute("source_ami") == "")
source_ami="$(get_ami --ami_name_prefix $instance.parent.getAttribute("ami_name_prefix"))";
#[[
if [ -z "$source_ami" -o "$source_ami" == "-null-" -o "$source_ami" == "null" ]; then
    log_error "Unable to determine AMI. Aborting";
    exit 1;
fi;
log_info "Using source ami '$source_ami'";
]]#
#end

#[[
extra_packer_options="";
if [ "$debug_mode" == "1" ]; then
    extra_packer_options="-debug";
    export PACKER_LOG=1;
fi;

[[ "$do_encrypt_boot" == "1" ]] && export encrypt_boot="true" || export encrypt_boot="false";
set_default_ssh_options;
start_module --git_url "$packer_module_git_url" --git_branch "$packer_module_git_branch";
]]#