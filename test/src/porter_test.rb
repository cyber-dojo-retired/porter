require_relative 'test_base'

class PorterTest < TestBase

  def self.hex_prefix
    '3BE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E4', %w(
  port of id that does not exist raises
  ) do
    id = '9k81d40123'
    error = assert_raises(RuntimeError) { port(id) }
    assert_equal "malformed:id:#{id} !exist", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E2', %w(
  port of id that has already been ported raises
  ) do
    id = '9f8TeZMZAq'
    port(id)
    error = assert_raises(RuntimeError) { port(id) }
    assert_equal "malformed:id:#{id} !exist", error.message
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E5', %w(
  after port of id which is unique in 1st 6 chars in storer,
  saver has saved the practice-session
  with an id equal to its original 1st 6 chars
  ) do
    Katas_old_ids.each do |id10|
      assert_ports_with_matching_id(id10)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E6', %w(
  after port of id that has more than one 6-char match in storer
  saver has saved the practice-session
  with an id unequal to its original 1st 6 chars
  ) do
    dup = '0BA7E1'
    id1 = dup+'E01B'
    id2 = dup+'6149'
    assert_equal [id1,id2].sort, storer.katas_completed(dup).sort
    assert_ports_with_different_id(id1)
    assert_ports_with_different_id(id2)

    dup = '7E5373'
    id1 = dup+'2F00'
    id2 = dup+'E92E'
    assert_equal [id1,id2].sort, storer.katas_completed(dup).sort
    assert_ports_with_different_id(id1)
    assert_ports_with_different_id(id2)

    dup = '463748'
    id1 = dup+'A0E8'
    id2 = dup+'D943'
    assert_equal [id1,id2].sort, storer.katas_completed(dup).sort
    assert_ports_with_different_id(id1)
    assert_ports_with_different_id(id2)
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E3', %w(
  port of newer ids some of which include l (ell, lowercase L)
  ) do
    Katas_new_ids.each do |id10|
      assert_ports_with_matching_id(id10)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E9', %w(
  ids from 7E dir that initially failed to port
  because they have a display_name
  that was missing from storer's Updater.cache ) do
    kata_ids = [
      '7E010BE86C', # 'Java, JUnit-Mockito'
      '7E2AEE8E64', # 'Java, JUnit-Mockito'
      '7E9B1F7E60', # 'Scala, scalatest'
      '7E218AC28C', # 'Scala, scalatest'
      '7E6DEF1D86', # 'Scala, scalatest'
      '7EA354ED66', # 'Ruby, Approval'
      '7EC98B56F7', # 'Java, JUnit-Mockito'
      '7EA0979D3E', # 'Java, Approval'
      '7E246F2339', # 'C (gcc), Unity'
      '7E12E5A294', # 'C (gcc), Unity'
    ]
    kata_ids.each do |id10|
      assert_ports_with_matching_id(id10)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EA', %w(
  id from 7E dir that initially failed to port
  because in storer 'colour' used to be called 'outcome' ) do
    assert_ports_with_matching_id('7E53666BFE')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EC', %w(
  id from 7E dir that initially failed to port
  because it holds a bunch of now-dead diff/fork related properties
  which storer was not deleting
  ) do
    assert_ports_with_matching_id('7EBAEC5207')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1EF', %w(
  id from 7E dir that initially failed to port
  because it is for (modern) custom start-points,
  whose manifest does contain an 'image_name'
  but does not contain a 'runner_choice',
    eg 'Java Countdown, Round 1',
  and storer was failing to cater for this
  ) do
    assert_ports_with_matching_id('7EC7A19DF3')
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '120', %w(
  ids from 4D that initially failed to port
  ) do
    # "display_name"=>"git, bash"
    assert_ports_with_matching_id('4D29143FE1')
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
    9f67Q9PyZm
    9fcW44ltyz
    9fDYJR3BfG
    9fH6TumFV2
    9fSqUqMecK
    9fT2wMW0BM
    9fUSFm6hmT
    9fvMuUlKbh
  )

end
