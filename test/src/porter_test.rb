require_relative 'test_base'

class PorterTest < TestBase

  def self.hex_prefix
    '3BE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E4', %w(
  port of partial_id that does not exist returns empty string
  ) do
    partial_id = '9k81d4'
    id = port(partial_id)
    assert_equal '', id
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E5', %w(
  after port of partial_id which is unique in 1st 6 chars in storer,
  saver has saved the practice-session with an id equal to its original 1st 6 chars
  and the operation is idempotent
  ) do
    Katas_old_ids.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
      partial_id = kata_id[0..5]
      assert_equal [kata_id], storer.katas_completed(partial_id)
      was = was_data(kata_id)
      refute saver.group_exists?(partial_id), kata_id

      gid = port(partial_id)

      assert_equal partial_id, gid, kata_id
      assert saver.group_exists?(gid), kata_id
      now = now_data(gid)
      refute storer.kata_exists?(kata_id), kata_id
      assert_ported(was, now, kata_id)
      # Idempotent
      gid2 = port(partial_id)
      assert_equal gid, gid2, kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E3', %w(
  port of some newer partial_ids some of which include l (ell)
  ) do
    Katas_new_ids.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
      partial_id = kata_id[0..5]
      assert_equal [kata_id], storer.katas_completed(partial_id)
      was = was_data(kata_id)
      refute saver.group_exists?(partial_id), kata_id

      gid = port(partial_id)

      assert_equal partial_id, gid, kata_id
      assert saver.group_exists?(gid), kata_id
      now = now_data(gid)
      refute storer.kata_exists?(kata_id), kata_id
      assert_ported(was, now, kata_id)
      # Idempotent
      gid2 = port(partial_id)
      assert_equal gid, gid2, kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E6', %w(
  port of partial_id that has more than one match
  ports nothing and returns the empty string
  and the operation is idempotent
  ) do
    katas_dup_ids = %w( 0BA7E1E01B
                        0BA7E16149 )
    katas_dup_ids.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
      partial_id = kata_id[0..5]

      gid = port(partial_id)

      assert_equal '', gid, kata_id
      assert storer.kata_exists?(kata_id), kata_id
      # Idempotent
      gid2 = port(partial_id)
      assert_equal '', gid2, kata_id
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E7', %w(
  after port of partial_id which is unique in 1st 7 chars in storer
  saver has saved the practice-session with a new id
  and you cannot access the new practice-sesssion with partial_id's 1st 6 chars
  and the operation is idempotent
  ) do
    ids = {}
    katas_dup_ids = %w( 463748A0E8
                        463748D943 )
    katas_dup_ids.each do |kata_id|
      assert storer.kata_exists?(kata_id), kata_id
      partial_id = kata_id[0..6]
      assert_equal 7, partial_id.size
      assert_equal [kata_id], storer.katas_completed(partial_id)
      was = was_data(kata_id)

      gid = port(partial_id)

      assert_equal 6, gid.size
      id6 = kata_id[0..5]
      refute_equal id6, gid, kata_id # new-id
      assert saver.group_exists?(gid), kata_id
      now = now_data(gid)
      refute storer.kata_exists?(kata_id)
      assert_ported(was, now, kata_id)
      ids[kata_id] = gid

      dup_id = kata_id[0..5]
      assert_equal 6, dup_id.size
      gid = port(dup_id)
      assert_equal '', gid, kata_id
    end

    # Idempotent
    katas_dup_ids.each do |kata_id|
      (6..10).each do |n|
        partial_id = kata_id[0..n]
        gid = port(partial_id)
        assert_equal ids[kata_id], gid, kata_id
      end
    end
  end

  private

  # 421F303E80 has revert_tag entries in its increments
  Katas_old_ids = %w(
    1F00C1BFC8
    5A0F824303
    420B05BA0A
    420F2A2979
    421F303E80
    420BD5D5BE
    421AFD7EC5
  )

  Katas_new_ids = %w(
    9f8TeZMZAq
    9f67Q9PyZm
    9fcW44ltyz
    9fDYJR3BfG
    9fH6TumFV2
    9fSqUqMecK
    9fT2wMW0BM
    9fUSFm6hmT
    9fvMuUlKbh
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
    joined.each do |kid|
      index = saver.kata_manifest(kid)['group_index']
      avatar_name = Avatars_names[index.to_i]
      now[:tag_files][avatar_name] = {}
      events = saver.kata_events(kid)
      events.each_with_index do |event,n|
        event['number'] = n
        now_info = saver.kata_event(kid, n)
        now[:tag_files][avatar_name][n] = now_info
      end
      now[:increments][avatar_name] = events
    end
    now
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def assert_ported(was, now, kata_id)
    # manifest
    assert was[:manifest]['visible_files'].keys.include?('output'), kata_id
    was[:manifest]['visible_files'].delete('output')
    was[:manifest].delete('id') # 10-chars long
    refute now[:manifest]['visible_files'].keys.include?('output'), kata_id
    now[:manifest].delete('id') #  6-chars long
    was_created = was[:manifest].delete('created')
    now_created = now[:manifest].delete('created')
    assert_equal was_created << 0, now_created, kata_id
    assert_equal was[:manifest], now[:manifest], kata_id
    # increments
    was[:increments].values.each do |incs|
      # for a while I experimented with holding revert information
      incs = incs.map{ |inc| inc.delete('revert_tag'); inc }
      incs.each_with_index do |inc,index|
        # time-stamps now use 7th usec integer
        inc['time'] << 0
        # duration is now stored on test events
        unless index == 0
          inc['duration'] = 0.0
        end
      end
    end

    assert_equal was[:increments], now[:increments], kata_id
    # tag_files
    was_tag_files = was[:tag_files]
    now_tag_files = now[:tag_files]
    was_avatar_names = was_tag_files.keys
    now_avatar_names = now_tag_files.keys
    assert_equal was_avatar_names.sort, now_avatar_names.sort, kata_id
    was_tag_files.each do |avatar_name, was_tags|
      now_tags = now_tag_files[avatar_name]
      assert_equal was_tags.keys.sort, now_tags.keys.sort, kata_id+":#{avatar_name}:"
      was_tags.keys.each do |tag|
        old_files = was[:tag_files][avatar_name][tag]
        diagnostic = kata_id+":#{avatar_name}:#{tag}:"
        assert old_files.keys.include?('output'), "A:#{diagnostic}"
        old_stdout = old_files.delete('output')
        new_info = now[:tag_files][avatar_name][tag]
        assert_equal old_files, new_info['files'], "B:#{diagnostic}"
        if tag == 0
          # tag zero == creation event
          assert_nil new_info['stdout'], "C:#{diagnostic}"
          assert_nil new_info['stderr'], "D:#{diagnostic}"
          assert_nil new_info['status'], "E:#{diagnostic}"
        else
          # every other event is a test event
          assert_equal old_stdout, new_info['stdout'], "F:#{diagnostic}"
          assert_equal '',         new_info['stderr'], "G:#{diagnostic}"
          assert_equal 0,          new_info['status'], "H:#{diagnostic}"
        end
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
