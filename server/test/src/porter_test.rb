require_relative 'test_base'

class PorterTest < TestBase

  def self.hex_prefix
    '3BE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E5', %w(
  after port of storer id with no duplicate,
  saver has saved the practice-session with its original id
  ) do
    kata_id = '1F00C1BFC8'
    id6 = kata_id[0..5]
    assert storer.kata_exists?(kata_id)
    was = was_data(kata_id)
    refute saver.group_exists?(id6)

    gid = port(kata_id)

    assert saver.group_exists?(id6)
    now = now_data(id6)
    #refute storer.kata_exists?(kata_id) # TODO
    assert_ported(was, now)
    assert_equal id6, gid
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

  def was_data(kata_id)
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
    was
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def now_data(id6)
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
    now
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def assert_ported(was, now)
    assert was[:manifest]['visible_files'].keys.include?('output')
    was[:manifest]['visible_files'].delete('output')
    was[:manifest].delete('id') # 10-chars long
    refute now[:manifest]['visible_files'].keys.include?('output')
    now[:manifest].delete('id') #  6-chars long
    assert_equal was[:manifest], now[:manifest]

    assert_equal was[:increments], now[:increments]

    was_tag_files = was[:tag_files]
    now_tag_files = now[:tag_files]
    was_avatar_names = was_tag_files.keys
    now_avatar_names = now_tag_files.keys
    assert_equal was_avatar_names.sort, now_avatar_names.sort

    was_tag_files.each do |avatar_name, was_tags|
      now_tags = now_tag_files[avatar_name]
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
