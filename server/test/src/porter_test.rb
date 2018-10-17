require_relative 'test_base'

class PorterTest < TestBase

  def self.hex_prefix
    '3BE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def avatars_names
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
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E5', %w(
  after port of storer id with no duplicate,
    saver says kata exists with its original id,
    there is no 'output' file in the manifest,
    all the avatars increments have been copied,
    all the avatars tag_visible_files have been copied,
    and there is no 'output' file in the tag_visible_files
  ) do
    kata_id = '1F00C1BFC8'
    id6 = kata_id[0..5]

    old_manifest = storer.kata_manifest(kata_id)
    assert old_manifest['visible_files'].keys.include?('output')
    old_increments = storer.kata_increments(kata_id)
    refute saver.group_exists?(id6)

    gid = port(kata_id)

    assert_equal id6, gid
    assert saver.group_exists?(id6)

    new_manifest = saver.group_manifest(id6)
    refute new_manifest['visible_files'].keys.include?('output')
    new_increments = {}
    joined = saver.group_joined(id6)
    joined.each do |index,id|
      avatar_name = avatars_names[index.to_i]
      new_increments[avatar_name] = saver.kata_tags(id)
    end
    assert_equal new_increments, old_increments

    #TODO: assert the tag_visible_files are the same
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '55C', %w(
  data_has_been_tar_piped_into_storer
  ) do
    katas_old = %w(
    1F00C1BFC8 5A0F824303 420B05BA0A 420F2A2979 421F303E80 420BD5D5BE 421AFD7EC5
    )
    katas_old.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
    end

    katas_dup = %w( 0BA7E1E01B 0BA7E16149 463748A0E8 463748D943 )
    katas_dup.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
    end
  end

end
