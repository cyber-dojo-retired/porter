require_relative 'rack_dispatcher_externals_stub'
require_relative 'rack_dispatcher_stub'
require_relative 'rack_request_stub'
require_relative 'test_base'
require_relative '../../src/rack_dispatcher'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'FF0'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  class ThrowingRackDispatcherStub
    def port(_kata_id)
      fail ArgumentError, 'wibble'
    end
  end

  test 'F1A',
  'dispatch returns 500 status when implementation raises' do
    @stub = ThrowingRackDispatcherStub.new
    assert_dispatch_raises('port',
      { kata_id:'12345abcde' }.to_json,
      500,
      'wibble')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5A',
  'dispatch raises when method name is unknown' do
    assert_dispatch_raises('xyz',
      {}.to_json,
      400,
      'xyz:unknown:')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5C',
  'dispatch raises when json is malformed' do
    assert_dispatch_raises('port',
      'xxx',
      400,
      'json:malformed')
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # image
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E41',
  'dispatch to sha' do
    assert_dispatch('sha', {}.to_json,
      "hello from #{stub_name}.sha"
    )
  end


  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # porter
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E5B',
  'dispatch raises when any argument is malformed' do
    assert_dispatch_raises('port',
      { kata_id: 'df/de' }.to_json,  # !Base58
      400,
      'kata_id:malformed'
    )
    assert_dispatch_raises('port',
      { kata_id: '12345abcd' }.to_json, # !10 chars
      400,
      'kata_id:malformed'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test 'E60',
  'dispatch to port' do
    assert_dispatch('port',
      { kata_id: '12345abcde' }.to_json,
      "hello from #{stub_name}.port"
    )
  end

  private

  def stub_name
    stub.class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch(name, args, stubbed)
    assert_rack_call(name, args, { name => stubbed })
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_dispatch_raises(name, args, status, message)
    response,stderr = with_captured_stderr { rack_call(name, args) }
    body = args
    assert_equal status, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_exception(response[2][0], name, body, message)
    assert_exception(stderr,         name, body, message)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_exception(s, name, body, message)
    json = JSON.parse(s)
    exception = json['exception']
    refute_nil exception
    assert_equal name, exception['path']
    assert_equal body, exception['body']
    assert_equal 'PorterService', exception['class']
    assert_equal message, exception['message']
    assert_equal 'Array', exception['backtrace'].class.name
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_rack_call(name, args, expected)
    response = rack_call(name, args)
    assert_equal 200, response[0]
    assert_equal({ 'Content-Type' => 'application/json' }, response[1])
    assert_equal [to_json(expected)], response[2], args
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def stub
    @stub ||= RackDispatcherStub.new
  end

  def rack_call(name, args)
    externals_stub = RackDispatcherExternalsStub.new(stub)
    rack = RackDispatcher.new(externals_stub, RackRequestStub)
    env = { path_info:name, body:args }
    rack.call(env)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def to_json(body)
    JSON.generate(body)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def with_captured_stderr
    begin
      old_stderr = $stderr
      $stderr = StringIO.new('', 'w')
      response = yield
      return [ response, $stderr.string ]
    ensure
      $stderr = old_stderr
    end
  end

end
