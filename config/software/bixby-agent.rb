
name "bixby-agent"
default_version ENV["BIXBY_GIT_REV"] || "LAST_TAG"
always_build true

dependencies %w{ rubygems bundler bixby-client }

source :git => "https://github.com/chetan/bixby-agent.git"

build do

  # swiped from 'chef' pkg in omnibus-software
  block do
    project = self.project
    if project.name == "bixby"
      project.build_version(Omnibus::BuildVersion.new(self.project_dir).semver)
    end
  end

  %w{facter mixlib-cli uuidtools god daemons}.each do |g|
    gem "install #{g} -v #{Bixby.gem_version(g)} --no-rdoc --no-ri", :env => Bixby.omnibus_env
  end

  gem "build bixby-agent.gemspec"

  cmd = cmd_str <<-EOF
    install bixby-agent-*.gem
    --no-rdoc --no-ri
    EOF

  gem cmd, :env => Bixby.omnibus_env

  # wrap ruby cocmmands
  %w{bixby-agent bundle facter gem irb rake ruby}.each do |b|
    block { Bixby.ruby_wrapper(b, install_dir) }
  end

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
