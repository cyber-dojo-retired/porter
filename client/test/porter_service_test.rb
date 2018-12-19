require_relative '../src/service_error'
require_relative 'test_base'

class PorterServiceTest < TestBase

  def self.hex_prefix
    'D06'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # sha
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '190',
  %w( sha ) do
    sha = porter.sha
    assert_equal 40, sha.size
    sha.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # port
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '7E1',
  %w( port of malformed id raises ) do
    error = assert_raises(ServiceError) {
      porter.port_one('345')
    }
    json = JSON.parse(error.message)
    assert_equal 'port_one', json['path']
    assert_equal({'id' => '345'}, JSON.parse(json['body']))
    assert_equal 'PorterService', json['class']
    assert_equal 'id:malformed:size==3 !10:', json['message']
    assert_equal 'Array', json['backtrace'].class.name
    assert_equal 'String', json['backtrace'][0].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test '7ED',
  %w( port of non-existent id returns empty string ) do
    id = porter.port_one('a4211p6A')
    assert_equal '', id
  end
=end

end
