require_relative 'test_base'

class PorterTest < TestBase

  def self.hex_prefix
    '3BE'
  end

  # - - - - - - - - - - - - - - - - - - - - - - -

  test '1E5', %w(
  after port of id with no duplicate, saver says kata exists with its original id
  ) do
    kata_id = '1F00C1BFC8'
    id = kata_id[0..5]
    refute saver.group_exists?(id)
    port(kata_id)
    assert saver.group_exists?(id)
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
