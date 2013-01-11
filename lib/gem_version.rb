
module Bixby
  def self.bundle
    @bundle ||= Bundler.setup
  end
  def self.gem_version(name)
    bundle.gems.to_hash[name].first.version.to_s
  end
end
