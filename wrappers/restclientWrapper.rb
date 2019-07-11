require 'rest-client'

class RestclientWrapper

  def get(url, headers = nil)
    begin
      begin
        tries ||= 10
        return RestClient.get(url, headers)
      rescue Zlib::GzipFile::Error
        (tries -= 1).zero? ? raise('Internet connection failed.') : retry
      end
    rescue URI::InvalidURIError
      raise "Incorrect page with url: #{url}\nPlease review.\n"
    end
  end

  def post(url, payload, headers = nil)
    begin
        response = RestClient.post(url, payload, headers)
        return response
    rescue RestClient::ExceptionWithResponse => err
        fail "Internet connection failed. Re-run tests again later." if err.response.nil?
        return err.response
    end
  end

end
