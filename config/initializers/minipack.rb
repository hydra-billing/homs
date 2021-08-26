Minipack.configuration do |c|
  # By default c.cache is set to `false`, which means an application always parses a
  # manifest.json. In development, you should set cache false usually.
  # Instead, setting it `true` which caches the manifest in memory is recommended basically.
  c.cache = !Rails.env.development?

  # Register a path to a manifest file here. Right now you have to specify an absolute path.
  c.manifest = Rails.root.join('public', 'assets', 'packs', 'manifest.json')
end
