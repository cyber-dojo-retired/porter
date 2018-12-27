require_relative 'http_json_service'

class ExternalStorer

  def sha
    get(__method__)
  end

  # :nocov:
  def sample_id10
    get(__method__)
  end

  def sample_id2
    get(__method__)
  end
  # :nocov:

  def katas_completed(partial_id)
    get(__method__, partial_id)
  end

  def katas_completions(outer_id)
    get(__method__, outer_id)
  end

  def kata_exists?(kata_id)
    get(__method__, kata_id)
  end

  def kata_delete(kata_id)
    post(__method__, kata_id)
  end

  def kata_manifest(kata_id)
    get(__method__, kata_id)
  end

  def kata_increments(kata_id)
    get(__method__, kata_id)
  end

  def avatars_started(kata_id)
    get(__method__, kata_id)
  end

  def avatar_increments(kata_id, avatar_name)
    get(__method__, kata_id, avatar_name)
  end

  def tag_visible_files(kata_id, avatar_name, tag)
    get(__method__, kata_id, avatar_name, tag)
  end

  private

  include HttpJsonService

  def hostname
    'storer'
  end

  def port
    4577
  end

end
