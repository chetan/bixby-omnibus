
name "bixby-agent"
version ENV["BIXBY_GIT_REV"] || "LAST_TAG"
always_build true

dependencies %w{ rubygems bundler curl api-auth
                 bixby-common bixby-client }

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
      project.build_version(Omnibus::BuildVersion.new(self.project_dir).semver)
    end
  end

  %w{sinatra thin multi_json oj curb facter mixlib-cli mixlib-shellout
     highline uuidtools logging }.each do |g|
    gem "install #{g} -v #{Bixby.gem_version(g)} --no-rdoc --no-ri", :env => env
  end

  gem "build bixby-agent.gemspec"

  cmd = cmd_str <<-EOF
    install bixby-agent-*.gem
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
