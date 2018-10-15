require_relative 'base58'
require 'json'

# Checks for arguments synactic correctness

class WellFormedArgs

  def initialize(s)
    @args = JSON.parse(s)
  rescue
    raise ArgumentError.new('json:malformed')
  end

  # - - - - - - - - - - - - - - - -

  def kata_id
    @arg_name = __method__.to_s
    unless Base58.string?(arg) && arg.size == 10
      malformed
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def avatar_name
    @arg_name = __method__.to_s
    # TODO: checking
    arg
  end

  private

  attr_reader :args, :arg_name

  def arg
    args[arg_name]
  end

  # - - - - - - - - - - - - - - - -

  def malformed
    raise ArgumentError.new("#{arg_name}:malformed")
  end

end