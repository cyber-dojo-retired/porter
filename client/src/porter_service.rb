require_relative 'http_json_service'

class PorterService

  def sha
    get(__method__)
  end

  def port(partial_id)
    post(__method__, partial_id)
  end

  private

  include HttpJsonService

end
