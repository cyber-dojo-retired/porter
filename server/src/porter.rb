require 'json'

class Porter

  def initialize(externals)
    @externals = externals
  end

  def port(partial_id)
    id6 = partial_id[0..5]

    if saver.group_exists?(id6)
      # unique kata-id, already ported
      return id6
    end

    filename = "/id-map/#{partial_id}"
    if File.exist?(filename)
      # non-unique kata-id, already ported
      return IO.read(filename)
    end

    kata_id = storer.katas_completed(partial_id)
    unless kata_id.size == 10
      # zero matches, or more than 1 match
      return ''
    end

    manifest = storer.kata_manifest(kata_id)
    set_id(manifest)
    manifest['visible_files'].delete('output')
    id6 = saver.group_create(manifest)

    remember_mapping(id6, partial_id)

    storer.avatars_started(kata_id).each do |avatar_name|
      kid = group_join(id6, avatar_name)

      increments = storer.avatar_increments(kata_id, avatar_name)
      increments[1..-1].each do |increment|
        colour = increment['colour']
        time = increment['time']
        tag = increment['number']
        files = storer.tag_visible_files(kata_id, avatar_name, tag)
        stdout = files.delete('output')
        stderr = ''
        status = 0
        saver.kata_ran_tests(kid, tag, files, time, stdout, stderr, status, colour)
      end
    end

    storer.kata_delete(kata_id)

    id6
  end

  private

  def set_id(manifest)
    id6 = manifest['id'][0..5]
    if unique?(id6)
      manifest['id'] = id6
    else
      force_saver_to_generate_a_new_id(manifest)
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def force_saver_to_generate_a_new_id(manifest)
    manifest.delete('id')
  end

  # - - - - - - - - - - - - - - - - - - -

  def unique?(id6)
    ported = Dir.glob("/id-map/#{id6}**")
    if ported != []
      false
    else
      id = storer.katas_completed(id6)
      id.length == 10
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def remember_mapping(id6, partial_id)
    if id6 != partial_id[0..5]
      IO.write("/id-map/#{partial_id}", id6)
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_join(id, avatar_name)
    index = Avatars_names.index(avatar_name)
    indexes = (0..63).to_a.shuffle
    indexes.delete(index)
    indexes.unshift(index)
    _,kid = saver.group_join(id, indexes)
    kid
  end

  # - - - - - - - - - - - - - - - - - - -

  Avatars_names =
    %w(alligator antelope     bat       bear
       bee       beetle       buffalo   butterfly
       cheetah   crab         deer      dolphin
       eagle     elephant     flamingo  fox
       frog      gopher       gorilla   heron
       hippo     hummingbird  hyena     jellyfish
       kangaroo  kingfisher   koala     leopard
       lion      lizard       lobster   moose
       mouse     ostrich      owl       panda
       parrot    peacock      penguin   porcupine
       puffin    rabbit       raccoon   ray
       rhino     salmon       seal      shark
       skunk     snake        spider    squid
       squirrel  starfish     swan      tiger
       toucan    tuna         turtle    vulture
       walrus    whale        wolf      zebra
    )

  # - - - - - - - - - - - - - - - - - - -

  def storer
    @externals.storer
  end

  def saver
    @externals.saver
  end

end
