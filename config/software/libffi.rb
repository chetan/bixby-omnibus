
# not actually used, just here for reference

name "libffi"
version "3.0.11"
md5 = "f69b9693227d976835b4857b1ba7d0e3"

dependencies [ ]

source :url => "ftp://sourceware.org/pub/libffi/libffi-#{version}.tar.gz",
       :md5 => md5

relative_path "#{name}-#{version}"

configure_env = {
  "LDFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "CFLAGS" => "-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include",
  "LD_RUN_PATH" => "#{install_dir}/embedded/lib"
}

build do
  command "./configure --prefix=#{install_dir}/embedded", :env => configure_env
  command "make -j #{max_build_jobs}", :env => {"LD_RUN_PATH" => "#{install_dir}/embedded/lib"}
  command "make install"
end
