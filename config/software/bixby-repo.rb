
name "bixby-repo"
version "master"

source :git => "https://github.com/chetan/bixby-repo.git"

build do

  block do
    # remove files we don't need
    %w{.git .test .gitignore Gemfile Gemfile.lock Rakefile README
       update_digests.sh}.each do |file|

      system("rm -rf #{project_dir}")
    end

    system("mkdir #{install_dir}/repo")
    system("cp -a #{project_dir} #{install_dir}/repo/vendor")
  end

end
