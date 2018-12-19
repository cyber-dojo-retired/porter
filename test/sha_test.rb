require_relative 'test_base'

class ShaTest < TestBase

  def self.hex_prefix
    'FB3'
  end

  def sha
    externals.env.sha
  end

  # - - - - - - - - - - - - - - - - -

  test '191',
  %w( sha of git commit for image ) do
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

end
