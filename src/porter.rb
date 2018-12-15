
class Porter

  def initialize(externals)
    @externals = externals
  end

  def port_all
  end

  def port(id)
    if !storer.kata_exists?(id)
      fail "malformed:id:#{id} !exist"
    end

    manifest = storer.kata_manifest(id)
    update_manifest(manifest)
    set_id(manifest)
    id6 = saver.group_create(manifest)

    remember_mapping(id, id6)

    storer.avatars_started(id).each do |avatar_name|
      kid = group_join(id6, avatar_name)
      increments = storer.avatar_increments(id, avatar_name)
      increments[1..-1].each do |increment|
        colour = increment['colour'] || increment['outcome']
        time = increment['time']
        # time-stamps now use 7th usec integer
        time << 0
        # duration is now stored
        duration = 0.0
        index = increment['number']
        files = storer.tag_visible_files(id, avatar_name, index)
        stdout = file(files.delete('output'))
        stderr = file('')
        status = 0
        update_files(files)
        saver.kata_ran_tests(kid, index, files, time, duration, stdout, stderr, status, colour)
      end
    end

    storer.kata_delete(id)

    id6
  end

  private

  def update_manifest(manifest)
    # output is now stdout/stderr/status which
    # are separated from files
    manifest['visible_files'].delete('output')
    # time-stamps now use 7th usec integer
    manifest['created'] << 0
    # runner_choice is now dropped
    manifest.delete('runner_choice')
    # each file is now stored in a hash
    manifest['visible_files'].transform_values!{ |content|
      { 'content' => content }
    }
  end

  # - - - - - - - - - - - - - - - - - - -

  def update_files(files)
    files.transform_values!{ |content| file(content) }
  end

  # - - - - - - - - - - - - - - - - - - -

  def file(content, truncated = false)
    { 'content' => content,
      'truncated' => truncated
    }
  end

  # - - - - - - - - - - - - - - - - - - -

  def set_id(manifest)
    id6 = manifest['id'][0..5]
    if unique?(id6)
      manifest['id'] = id6
    else
      force_saver_to_generate_a_new_id(manifest)
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def unique?(id6)
    ported = Dir.glob("/id-map/#{id6}**")
    ids = storer.katas_completed(id6)
    ported.size + ids.size == 1
  end

  # - - - - - - - - - - - - - - - - - - -

  def force_saver_to_generate_a_new_id(manifest)
    manifest.delete('id')
  end

  # - - - - - - - - - - - - - - - - - - -

  def remember_mapping(kata_id, id6)
    if id6 != kata_id[0..5]
      IO.write("/id-map/#{kata_id}", id6)
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def group_join(id, avatar_name)
    index = Avatars_names.index(avatar_name)
    indexes = (0..63).to_a
    indexes.delete(index)
    indexes.unshift(index)
    saver.group_join(id, indexes)
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
