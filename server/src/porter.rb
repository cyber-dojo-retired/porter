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
    manifest['visible_files'].delete('output')
    id6 = saver.group_create(manifest)

    storer.avatars_started(kata_id).each do |avatar_name|
      index = Avatars_names.index(avatar_name)
      indexes = (0..63).to_a.shuffle
      indexes.delete(index)
      indexes.unshift(index)
      _,kid = saver.group_join(id, indexes)

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

    id6
  end

  private

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

  def storer
    @externals.storer
  end

  def saver
    @externals.saver
  end

end
