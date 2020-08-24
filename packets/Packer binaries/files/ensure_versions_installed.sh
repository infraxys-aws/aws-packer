log_info "Ensuring that the following versions of Packer are installed:
$versions";

for version in $versions; do
	[[ -n "$version" ]] && ensure_packer --packer_version "$version";
done;

log_info "Installation complete";