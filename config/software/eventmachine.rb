
name "eventmachine"
version Bixby.gem_version(name)

dependencies %w{ rubygems }

build do
  build_gem(name, version)

  block do

    # fix weird ext location
    em_dir = Dir.glob("#{install_dir}/embedded/lib/ruby/gems/*/gems/eventmachine-*/lib").first
    opt_dir = File.join(em_dir, "opt")

    if File.directory? opt_dir then
      files = `find #{em_dir}/lib/ -type f -name '*.so'`.split(/\n/)
      files.each do |file|
        if File.dirname(file) != em_dir then
          system("mv #{file} #{em_dir}/")
        end
      end
      system("rm -rf #{opt_dir}")
    end

  end

end
