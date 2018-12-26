# The main entry-point, from web via the dispatcher, for ported_id()
# The main entry-point, from the shell, for port()

# The intention is to...
#  o) run on an old (storer-based) server
#  o) bring down the server
#  o) run the port script to move from storer -> saver
#  o) upgrade the server (to saver-based)
#  o) run the new server

# Use cases...
# [1] no clash on porter/storer, id6 free on saver
#     uses id6==id10[0..5] and ask saver to use that id
#
# [2] no clash on porter/storer, id6 not free on saver
#     ask saver to use new id6, id-map it
#
# ]3] clash on porter/storer
#     ask saver to use new id6, id-map it
#     In theory this id6 could equal id10[0..5] !!! (use case 1)
#     In practice, the chance is miniscule. Worth looping/asserting on?

class Porter

  def initialize(externals)
    @externals = externals
  end

  #def ported_id(partial_id)
  #end

  def port(id)
    if !storer.kata_exists?(id)
      fail "malformed:id:#{id} !exist"
    end

    manifest = storer.kata_manifest(id)
    update_manifest(manifest)
    set_id(manifest)
    id6 = saver.group_create(manifest) #[3]
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
    ported = Dir.glob("/porter/id-map/#{id6}**")
    storer_ids = storer.katas_completed(id6)
    ported.size + storer_ids.size == 1
    # && !saver.group_exists?(id6)
  end

  # - - - - - - - - - - - - - - - - - - -

  def force_saver_to_generate_a_new_id(manifest)
    manifest.delete('id')
  end

  # - - - - - - - - - - - - - - - - - - -

  def remember_mapping(kata_id, id6)
    if id6 != kata_id[0..5]
      IO.write("/porter/id-map/#{kata_id}", id6)
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
