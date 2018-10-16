require 'json'

class Porter

  def initialize(externals)
    @externals = externals
  end

  def port(kata_id)
    #...
    manifest = storer.kata_manifest(kata_id)
    id = manifest['id'][0..5]
    manifest['id'] = id
    id6 = saver.group_create(manifest)
    id6
  end

  private

  def storer
    @externals.storer
  end

  def saver
    @externals.saver
  end

end
