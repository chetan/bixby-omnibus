
require 'bundler/setup'
require 'omnibus'

OMNIBUS_ROOT = File.expand_path(File.dirname(__FILE__))
require File.join(OMNIBUS_ROOT, "lib/patch_omnibus_http")
require File.join(OMNIBUS_ROOT, "lib/patch_omnibus_build_gem")
require File.join(OMNIBUS_ROOT, "lib/gem_version")

Omnibus.setup do |o|
  ##
  # Config Section
  ##
  o.config.install_dir = '/opt/bixby'

  #Omnibus::S3Tasks.define!
  #Omnibus::CleanTasks.define!
end

# rake clean task
require 'rake/clean'
config = Omnibus.config
::CLEAN.include("#{config.source_dir}/*",
                "#{config.build_dir}/*",
                "#{config.package_dir}/*")

::CLOBBER.include("#{config.install_dir}/*",
                  "#{config.cache_dir}/*")

# setup omnibus
overrides = Omnibus::Overrides.overrides

Omnibus.projects("config/projects/*.rb")
Omnibus.software(
  overrides,
  "config/software/*.rb",
  File.join(Bundler.definition.specs["omnibus-software"][0].gem_dir, "config/software/*.rb")
)
