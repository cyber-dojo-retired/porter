# The main entry-point, from the shell, for port()
# The main entry-point, from web via the dispatcher, for ported_id()

# The intention is to...
#  o) run on an old (storer-based) server
#  o) bring down the server
#  o) run the port script to move katas from storer -> saver
#  o) upgrade the server (to saver-based)
#  o) run the new server

class Porter

  def initialize(externals)
    @externals = externals
  end

  def ready
    storer.sha
    saver.sha
  end

  #def ported_id(partial_id)
  #end

  def port(id)
    if !storer.kata_exists?(id)
      fail "malformed:id: !storer.kata_exists?(#{id})"
    end
    if saver.group_exists?(id[0..5])
      fail "malformed:id: saver.group_exists?(#{id[0..5]})"
    end
    if disk['/porter/mapped-ids'].exists?(id)
      fail "malformed:id: saver.group_exists?(#{id[0..5]}) {mapped}"
    end

    manifest = storer.kata_manifest(id)
    update_manifest(manifest)
    set_id(manifest)
    id6 = saver.group_create(manifest)
    remember_id_if_mapped(id, id6)

    storer.avatars_started(id).each do |avatar_name|
      kid = group_join(id6, avatar_name)
      increments = storer.avatar_increments(id, avatar_name)
      # skip [0] which is automatically added for creation event
      increments[1..-1].each do |increment|
        colour = increment['colour'] || increment['outcome']
        time = increment['time']
        if time.nil?
          # some increments.json files have "time":"null"
          # update_manifest() has already added 7th usec
          time = manifest['created']
        else
          # time-stamps now use 7th usec integer
          time << 0
        end
        # duration is now stored
        duration = 0.0
        index = increment['number']
        files = storer.tag_visible_files(id, avatar_name, index)
        # some increments have a manifest.json with no 'output'
        stdout = file(files.delete('output') || '')
        stderr = file('')
        status = 0
        update_files(files)
        saver.kata_ran_tests(kid, index, files, time, duration, stdout, stderr, status, colour)
      end
    end

    storer.kata_delete(id)

    id6
  end

  # - - - - - - - - - - - - - - - - - - -

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

  private

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
    if from_unique?(id6) && to_available?(id6)
      manifest['id'] = id6
    else
      # force saver to generate a new id
      manifest.delete('id')
    end
  end

  # - - - - - - - - - - - - - - - - - - -

  def from_unique?(id6)
    ported_ids = Dir.glob("/porter/mapped-ids/#{id6}**")
    storer_ids = storer.katas_completed(id6)
    ported_ids.size + storer_ids.size == 1
  end

  def to_available?(id6)
    !saver.group_exists?(id6)
  end

  # - - - - - - - - - - - - - - - - - - -

  def remember_id_if_mapped(kata_id, id6)
    if id6 != kata_id[0..5]
      disk['/porter/mapped-ids'].write(kata_id, id6)
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

  def disk
    @externals.disk
  end

  def storer
    @externals.storer
  end

  def saver
    @externals.saver
  end

end
