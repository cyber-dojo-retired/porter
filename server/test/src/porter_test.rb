require_relative 'test_base'

class PorterTest < TestBase

  def self.hex_prefix
    '3BE'
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

    was = {}
    was[:manifest] = storer.kata_manifest(kata_id)
    was[:increments] = storer.kata_increments(kata_id)
    was[:tag_files] = {}
    was[:increments].each do |avatar_name,increments|
      was[:tag_files][avatar_name] = {}
      increments.each do |increment|
        tag = increment['number']
        was_files = storer.tag_visible_files(kata_id, avatar_name, tag)
        was[:tag_files][avatar_name][tag] = was_files
      end
    end

    assert storer.kata_exists?(kata_id)
    refute saver.group_exists?(id6)

    gid = port(kata_id)

    assert saver.group_exists?(id6)
    #refute storer.kata_exists?(kata_id) # TODO

    assert_equal id6, gid

    now = {}
    now[:manifest] = saver.group_manifest(id6)
    now[:increments] = {}
    now[:tag_files] = {}
    joined = saver.group_joined(id6)
    joined.each do |index,id|
      avatar_name = avatars_names[index.to_i]
      now[:tag_files][avatar_name] = {}
      tags = saver.kata_tags(id)
      now[:increments][avatar_name] = tags
      tags.each do |tag|
        n = tag['number']
        now_info = saver.kata_tag(id, n)
        now[:tag_files][avatar_name][n] = now_info
      end
    end

    assert was[:manifest]['visible_files'].keys.include?('output')
    refute now[:manifest]['visible_files'].keys.include?('output')

    assert_equal was[:increments], now[:increments]

    #TODO: check manifests are the same

    assert_equal was[:tag_files].keys.sort, now[:tag_files].keys.sort
    was[:tag_files].each do |avatar_name, was_tags|
      now_tags = now[:tag_files][avatar_name]
      assert_equal was_tags.keys.sort, now_tags.keys.sort
      was_tags.keys.each do |n|
        old_files = was[:tag_files][avatar_name][n]
        assert old_files.keys.include?('output')
        stdout = old_files.delete('output')
        new_info = now[:tag_files][avatar_name][n]
        assert_equal old_files, new_info['files']
        assert_equal stdout, new_info['stdout']
      end
    end

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

  private

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

end
