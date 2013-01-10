
name "bixby"

install_path 	"/opt/bixby"
build_version	Omnibus::BuildVersion.new.semver
build_iteration		"1"

dependencies %w{ preparation }
