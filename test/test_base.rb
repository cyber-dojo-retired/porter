require_relative 'hex_mini_test'
require_relative '../src/externals'

class TestBase < HexMiniTest

  def port_one(kata_id)
    porter.port_one(kata_id)
  end

  # - - - - - - - - - - - - - - - - -

  def externals
    @externals ||= Externals.new
  end

  # - - - - - - - - - - - - - - - - -

  def assert_ports_with_matching_id(id10)
    assert_ports(id10) do |id6,gid|
      assert_equal id6,gid,id10
    end
  end

  # - - - - - - - - - - - - - - - - -

  def assert_ports_with_different_id(id10)
    assert_ports(id10) do |id6,gid|
      refute_equal id6,gid,id10
    end
  end

  # - - - - - - - - - - - - - - - - -

  def assert_ports(id10)
    id6 = id10[0..5]
    assert storer.kata_exists?(id10), id10
    refute saver.group_exists?(id6), id10
    was = was_data(id10)
    gid = port_one(id10)
    yield id6,gid #refute_equal id6, gid, id10
    assert saver.group_exists?(gid), id10
    now = now_data(gid)
    refute storer.kata_exists?(id10), id10
    assert_ported(was, now, id10)
    print '.'
    STDOUT.flush
  end

  # - - - - - - - - - - - - - - - - -

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
    # runner_choice has been dropped
    was[:manifest].delete('runner_choice')
    # each manifest file now stored in hash
    update_files(was[:manifest]['visible_files'])
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

        assert_equal old_files.keys.sort, new_info['files'].keys.sort, "B1:#{diagnostic}"
        old_files.each do |filename,content|
          assert_equal content, new_info['files'][filename]['content'], "B2:#{diagnostic}"
        end

        if tag == 0
          # tag zero == creation event
          assert_nil new_info['stdout'], "C1:#{diagnostic}"
          assert_nil new_info['stderr'], "C2:#{diagnostic}"
          assert_nil new_info['status'], "C3:#{diagnostic}"
        else
          # every other event is a test event
          assert_equal old_stdout, new_info['stdout']['content'], "D1:#{diagnostic}"
          assert_equal '',         new_info['stderr']['content'], "D2:#{diagnostic}"
          assert_equal 0,          new_info['status'], "D3:#{diagnostic}"
        end
      end
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
        # TODO: do this in the port() call?
        outcome = increment.delete('outcome')
        unless outcome.nil?
          increment['colour'] = outcome
        end
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
        event['number'] = n # TODO: revist this. Better to drop from was_data?
        now_info = saver.kata_event(kid, n)
        now[:tag_files][avatar_name][n] = now_info
      end
      now[:increments][avatar_name] = events
    end
    now
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  def update_files(files)
    files.transform_values!{ |content| file(content) }
  end

  # - - - - - - - - - - - - - - - - - - -

  def file(content)
    { 'content' => content }
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

  # - - - - - - - - - - - - - - - - -

  def porter
    externals.porter
  end

  def saver
    externals.saver
  end

  def storer
    externals.storer
  end

end
