require_relative 'test_base'

class ShaTest < TestBase

  def self.hex_prefix
    'A8C'
  end

  # - - - - - - - - - - - - - - - - -

  test 'C6D',
  %w( smoke test storer service ) do
    assert_equal 40, storer.sha.size
  end

  test 'C6E',
  %w( smoke test saver service ) do
    assert_equal 40, saver.sha.size
  end

end
