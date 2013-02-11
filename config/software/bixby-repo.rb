
name "bixby-repo"
version "master"

source :git => "https://github.com/chetan/bixby-repo.git"

build do

  system("cp -a #{project_dir} #{install_dir}/repo")

  # remove files we don't need
  %w{.git .test .gitignore Gemfile Gemfile.lock Rakefile README
     update_digests.sh}.each do |file|

    system("rm -rf #{install_dir}/#{file}")
  end

end
