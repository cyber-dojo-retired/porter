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

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E8',
  'all of katas from 7E dir port' do
    Katas_lot_ids.each do |id8|
      kata_id = "7E#{id8}"
      assert_now_ported(kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E9', %w(
  ids from 7E dir that initially failed to port
  because they were missing entries in storer's Updater.cache ) do
    kata_ids = %w(
      7E010BE86C 7E2AEE8E64 7E9B1F7E60 7E218AC28C
      7E6DEF1D86 7EA354ED66 7EC98B56F7 7EA0979D3E
    )
    kata_ids.each do |kata_id|
      assert_now_ported(kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EA', %w(
  ids from 7E dir that initially failed to port
  because 'colour' used to be called 'outcome' ) do
    kata_ids = %w(
      7E53666BFE
    )
    kata_ids.each do |kata_id|
      assert_now_ported(kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EC', %w(
  ids from 7E dir that initially failed to port
  because they hold a bunch of now-dead diff/fork-related properties
  ) do
    kata_ids = %w(
      7EBAEC5207
    )
    kata_ids.each do |kata_id|
      assert_now_ported(kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test '1ED', %w(
  ids from 7E dir that still fail to port
  because they are missing entries in storer's Updater.cache
  for a display_name of 'C (gcc), Unity'
  ) do
    kata_ids = %w(
      7E246F2339
      7E12E5A294
    )
    kata_ids.each do |kata_id|
      assert_now_ported(kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EE', %w(
  ids from 7E dir that still fail to port
  because they are missing entries in storer's Updater.cache
  for a display_name of 'Clojure, .test'
  ) do
    kata_ids = %w(
      7E53732F00
    )
    kata_ids.each do |kata_id|
      assert_now_ported(kata_id)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EF', %w(
  ids from 7E dir that still fail to port
  because they are missing entries in storer's Updater.cache
  for a display_name of 'Java Countdown, Round 1'
  ) do
    kata_ids = %w(
      7EC7A19DF3
    )
    kata_ids.each do |kata_id|
      assert_now_ported(kata_id)
    end
  end
=end

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

  Katas_lot_ids = %w(
    008106FA  0E07819D  181C942D  28C99316  3A4F041F  4D7ED256  5AFAD6AE  67F75639  76FA23C1  8605DDAD  959F6648  A77B4561  C01B91D8  D419DCD2  E7FA5AD3  F77EC8E1
    00B1D93B  0E5B88DD  19B33D7B  2916FE85  3A840F4B  4DED8DB3  5B32D2E8  67FSj31H  772B63A9  861A5D3F  95B38286  A80E4BF7  C127F070  D45373B2  E804C1FC  F83B36CB
    00F95958  0EF315BC  19C43F9E  29AFBFDF  3A952CE4  4F347A86  5BD04E30  685E917E  77A59A56  864B0356  95BC7C52  A8154E55  C12844BE  D4E3CED4  E873D932  F97A2986
              0EFE74DE  19E207CF  2AC4A534  3ABA0CD6  4F34AC14  5BFCA700  68C0F4E9  77E9358A  88195F6B  95D00711  A81E7D52  C1C40775  D6067829  E9A5786F  FA6F0070
    01420D71  0F3B1D3A  1A184CDA            3B34E472  4F3D19C2  5C62F7DF  690B718B  7952036A  892B4983  96241733  A939DB5C  C225A08D  D6673584  E9E1412E  FAD12722
    015114BE  0F4233D6  1C448B38  2B334227  3CD90A34  4FCFB531  5D102F3B  6A564284  79538A0E  89E63028  9833A6E2  AA562E09  C29AA348  D690CCD2  E9F75038  FAD311AE
    023E03C6  0F4EE6FC  1C47C4DB  2C4D4D3E  3CDD4E48  4FD57C8D  5D1BFDC0  6A6BEF3E  79A4C145  8A40D4DA  98CEC137  B02277EE  C35D73C1  D79C8D7F  EA34C01C  FD2868C1
    02AB6A91  0FAA990D  1C78157D  2CD1E382  3D232C52  4bqFhb2V  5D834FA3  6A801188  79E84B97  8A5A0627  99B495D6  B0952CE7  C46CEE61  D79E9756  EA5ECDA0  FDB3E862
    032CF7E3  103DF0F9  1CBA7D9F  2DCD9590  3D95F161  515C334D  5DE51CD7  6AA0EC09  7A149DCE  8C9D7077            B191966E  C4C93129  D7C30135  EAC0A9E8  FE2FEBE3
    03EDA863  1071601E  1D85C3D7  2EA79B5F  3EC9525D  52B527CD  5EC931D1  6B242263  7A9EA057  8DEC30F0  9B90E5DE  B1BC4852  C4C9E1E2  D7FA07AC  EC56B044  FE804006
    057AFE03  10B944D0  1EAAC422  2F79C251  3ECE77A9  530755CD  5F358470  6BB7DDF5  7BD8A101  8E5863DF  9E97EB65  B1D97A29  C6573965  D811E78C  ED1EC42D  FEC26126
    06277C1C  10D16900  1EC9C3A8  2F7C830F  3F568683  531B039C  5F90E39E  6C859982  7CA676AC  8EE39CA0  9EF0D01A  B2FF9609  C6800449  D8577122  ED535D9E  FFA62580
    06785274  10D8CE1B  1F851720  2F910370  3j2Z9Sj8  533A588C  5FC7DAD9  6D539FAC  7D132066  8F31F388  9EF37995  B4B1B2A6  C72270E6  D9898118  ED8CCD46  FFCFAFDE
    0696F5DC  111917DB            2FFDAE37  405024DA  5346F93B  607A7D4A            7D572FF7  8FC34443  9QbcSCVP  B51DAC6B  C774D784  DADEC1E1  EEFCDBB1  FGQqCuEX
    0881FE34  125FE2C0  219B99CD  300955BE  408B9613            6130A7C1  6E62D04F  7DA0ABBC  8FD10B71  A0848C2E  B533B68B            DB283ADB  EF6E7695  GjVZMCDZ
    099B4EC7  128C3868  21FA94D6  304A8A6D  42DBB3B3            62964BB1  6E9716EA  7E284444  8FE55EAD            B54E6117  C80FA747  DB9DCD27  EFECC4A1  QTQMEshA
    09F5FE58  12C8EA0B  23B94CF9  30EAB7AA  447BD5AF  5373E92E  629BBE69  6ED5C6CA  7E561237  9072A092  A0FB06FD  B5C804F1  C815D88C  DBE40112  F10AA011  SbmmhNa2
    0A09DB61                      3111B25D  44AA7C39  538316BE  63084C58  6EE78703  7F945BFD  908E3BFD  A14BE348  B7CA3E28  C8A5B05A  DE5F4D8B  F16DE02B  TmFETnjF
    0A391733  13054D12  247C6BD0  3116093D  4690F16E  53C43FA3  63747DD5  6FC08BE1  7FD2174C  915F4648  A1AEEFF0  B86C2F1A            DECFB2FA  F1952423  UTn9vRnh
    0A4AA106  135ECC7F  24C6D19D  32302D0A  46C1DD20  5481A0C1  63A200D1  6FFD415F  80B10C09  91B1D5B9  A1B3BD61  B8CAF506  CC2AF900  E00F6BAD  F1FCAC41  XQCUgE6X
    0B0D1CEE  139B6EF5  25B505FE  32D0E088  46FAB1D6  54EEA09E  63FD7C70  70DA54D5  80D843CD  923B483A  A1F1156E  B8EBC8CE  CC730314  E0BA6D8E  F34F02CC  gRub0Npu
    0BA75784  13D7EEBD  25B6041C  32EDF160  47235B72  56A73903  64383C7B  716276F5  816E752A  925FC0DC  A2940C07  B91FE41F  CCCC6552  E0D87F95  F351CE0A  l9ek9hLs
    0BF19313  140AA120  25C97E54  34054EFC  475A5B44  56E94254  64DDB159  720C6645  81D19DEA  9260969B  A2A53133  B9E8F50D  CD3DE0DE  E1051BDA  F41AC08C  z6f8wU0Y
    0C9DE0EF  15A2EF11  25CA46C1  34D8ADF1  49D2DB4A  571B110E  64E2746B  72F8C591  826E3F04  928FE25B  A353AB8E  BA14CB3E  CD4D9FA6  E1A1C789  F4383019
    0CC2FB53  15CDA906  25E01E78  36808A17  4A13E93F  578BBCCA  654B6EF0  7387869A  833AA261  93E91D15            BA62476E  CD9D04BD  E3C8784C  F45D7138
    0CF21BAD  165C955E  26D56373  36AAB648  4A1CCC9C  584B6F66  6586B314  742C2675  8365290E  94DEF04C  A3FD8E5F            CF59E029  E4063596  F527416F
    0D0A4886  1692195F  2778164D  37756AD2  4A36BD2B  58F61F6E  65E7A255  75CCFEA3  8500D911  94F4BA12  A3FE98BE  BC86BE9B  D033C364  E407E6DE  F532777C
    0D13E48A  16BA0373  27F678DE  37DAAC9E  4B1D8DFE  590B174A  66559E37  75D5934C  85379FAF  95005587  A51320BA  BE9FE0E5  D0535AB7  E4B26397  F55ED28B
    0D2F3194  16ED319C  28466FD2  38AAC3CF  4B9BFBD4  59C27E0F  669C3AEB  76342B48  8581DFB0  95306961  A6700AAB  BECAEFDB  D0C4DF34  E6751180  F58F8AB0
    0D765A90  171FDB64  2863E6A9  398F7704  4BF3B28D  59D021AC  669F16C5  765504FC  858DC488  956D2594  A67112D9  BF808432  D1BEE8D8  E6ED12A4  F5ABD99B
    0E053773  178841DC  287FB26D  3A12B5C8  4C9A6703  5A20C89C  66C88C8E  76C031C0  85F60165  9582EF66  A69171F0  BFB98CDC  D36899C7  E74E0206  F71DFC54
  )

  # - - - - - - - - - - - - - - - - - - - - - - -

  def assert_now_ported(kata_id)
    assert storer.kata_exists?(kata_id), kata_id
    was = was_data(kata_id)

    gid = port(kata_id)

    assert saver.group_exists?(gid), kata_id
    now = now_data(gid)
    refute storer.kata_exists?(kata_id), kata_id
    assert_ported(was, now, kata_id)
    # Idempotent
    gid2 = port(kata_id)
    assert_equal gid, gid2, kata_id
    print '.'
    STDOUT.flush
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

  def was_data(kata_id)
    was = {}
    was[:manifest] = storer.kata_manifest(kata_id)
    was[:increments] = storer.kata_increments(kata_id)
    was[:tag_files] = {}
    was[:increments].each do |avatar_name,increments|
      was[:tag_files][avatar_name] = {}
      increments.each do |increment|
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
        event['number'] = n
        now_info = saver.kata_event(kid, n)
        now[:tag_files][avatar_name][n] = now_info
      end
      now[:increments][avatar_name] = events
    end
    now
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
