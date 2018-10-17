require_relative 'test_base'

class PorterTest < TestBase

  def self.hex_prefix
    '3BE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E5', %w(
  after port of storer id which is unique in 1st 6 chars,
  saver has saved the practice-session with its original id
  ) do
    # 421F303E80 has
    # { "colour"=>"amber",
    #   "revert_tag" => nil,
    #   "time" => [2013, 2, 18, 14, 46, 15],
    #   "number" => 7
    # }
    kata_ids = Katas_old_ids - [ '421F303E80' ]
    kata_ids.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
      was = was_data(kata_id)
      id6 = kata_id[0..5]
      refute saver.group_exists?(id6), kata_id

      gid = port(kata_id)

      assert_equal id6, gid, kata_id
      assert saver.group_exists?(gid), kata_id
      now = now_data(gid)
      #refute storer.kata_exists?(kata_id) # TODO
      assert_ported(was, now, kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E6', %w(
  after port of storer id which is not unique in 1st 6 chars
  saver has saved the practice-session with a new id
  ) do
    Katas_dup_ids.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
      was = was_data(kata_id)

      gid = port(kata_id)

      id6 = kata_id[0..5]
      refute_equal id6, gid, kata_id
      assert saver.group_exists?(gid), kata_id
      now = now_data(gid)
      #refute storer.kata_exists?(kata_id) # TODO
      assert_ported(was, now, kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '55C', %w(
  katas with unique ids (in 1st 6 chars) have been tar-piped into storer
  ) do
    Katas_old_ids.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '55D', %w(
  katas with non-unique ids (in 1st 6 chars) have been tar-piped into storer
  ) do
    Katas_dup_ids.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
    end
  end

  private

  Katas_old_ids = %w(
    1F00C1BFC8
    5A0F824303
    420B05BA0A
    420F2A2979
    421F303E80
    420BD5D5BE
    421AFD7EC5
  )

  Katas_dup_ids = %w(
    0BA7E1E01B
    0BA7E16149
    463748A0E8
    463748D943
  )

  # - - - - - - - - - - - - - - - - - - - - - - -

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
      avatar_name = Avatars_names[index.to_i]
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

  def assert_ported(was, now, kata_id)
    assert was[:manifest]['visible_files'].keys.include?('output'), kata_id
    was[:manifest]['visible_files'].delete('output')
    was[:manifest].delete('id') # 10-chars long
    refute now[:manifest]['visible_files'].keys.include?('output'), kata_id
    now[:manifest].delete('id') #  6-chars long
    assert_equal was[:manifest], now[:manifest], kata_id

    assert_equal was[:increments], now[:increments], kata_id

    was_tag_files = was[:tag_files]
    now_tag_files = now[:tag_files]
    was_avatar_names = was_tag_files.keys
    now_avatar_names = now_tag_files.keys
    assert_equal was_avatar_names.sort, now_avatar_names.sort, kata_id

    was_tag_files.each do |avatar_name, was_tags|
      now_tags = now_tag_files[avatar_name]
      assert_equal was_tags.keys.sort, now_tags.keys.sort, kata_id+":#{avatar_name}:"
      was_tags.keys.each do |n|
        old_files = was[:tag_files][avatar_name][n]
        diagnostic = kata_id+":#{avatar_name}:#{n}:"
        assert old_files.keys.include?('output'), diagnostic
        stdout = old_files.delete('output')
        new_info = now[:tag_files][avatar_name][n]
        assert_equal old_files, new_info['files'], diagnostic
        assert_equal stdout, new_info['stdout'], diagnostic
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

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

end
