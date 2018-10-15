require_relative 'http_json_service'

class PorterService

  def sha
    get(__method__)
  end

  def port(kata_id, avatar_name)
    post(__method__, kata_id, avatar_name)
  end

  private

  include HttpJsonService

  def hostname
    'porter'
  end

  def port
    4517
  end

end
