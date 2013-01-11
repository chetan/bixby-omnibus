
module Bixby
  def self.bundles
    return @bundles if @bundles

    path = File.join(OMNIBUS_ROOT, "tmp", "bixby-agent", "Gemfile.lock")
    specs = Bundler::LockfileParser.new(Bundler.read_file(path)).specs
    @bundles = {}
    specs.each{ |s| @bundles[s.name] = s.version.to_s }
    return @bundles
  end
  def self.gem_version(name)
    bundles[name]
  end
end
