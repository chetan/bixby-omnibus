
name "bixby-agent"
version ENV["BIXBY_GIT_REV"] || "master"
always_build true

dependencies %w{ rubygems bundler curl systemu bixby-common }

source :git => "https://github.com/chetan/bixby-agent.git"

# setup ENV for compilation
env = {
  "CFLAGS"  =>     "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "LDFLAGS" => "-Wl,-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include"
}

build do

  # swiped from 'chef' pkg in omnibus-software
  block do
    project = self.project
    if project.name == "bixby"
      git_cmd = "git describe --tags"
      src_dir = self.project_dir
      shell = Mixlib::ShellOut.new(git_cmd,
                                   :cwd => src_dir)
      shell.run_command
      shell.error!
      build_version = shell.stdout.chomp

      project.build_version   build_version
      project.build_iteration ENV["BIXBY_PACKAGE_ITERATION"].to_i || 1
    end
  end

  # install all runtime deps into install_dir
  bundle "install --without development test", :env => env

  # install all deps (including dev and test) into vendor for building gem
  bundle "install --deployment --without ''", :env => env
  rake "build", :env => env

  cmd = cmd_str <<-EOF
    install pkg/bixby-agent-*.gem
    -n #{install_dir}/bin
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => env

  #
  # TODO: the "clean up" section below was cargo-culted from the
  # clojure version of omnibus that depended on the build order of the
  # tasks and not dependencies. if we really need to clean stuff up,
  # we should probably stick the clean up steps somewhere else
  #

  # clean up
  ["docs",
   "share/man",
   "share/doc",
   "share/gtk-doc",
   "ssl/man",
   "man",
   "info"].each do |dir|
    command "rm -rf #{install_dir}/embedded/#{dir}"
  end

end
