class Recaptcha
  require 'net/https'
  require 'uri'

  def self.validate_response(response,remote_ip=nil)
    begin
      postdata = {
        response: response,
        secret: ENV['RECAPTCHA_SECRET_KEY']
      }
      postdata[:remoteip] = remote_ip unless remote_ip.blank?

      # Configure the POST request
      uri = URI.parse("https://www.google.com/recaptcha/api/siteverify")
      http = Net::HTTP.new(uri.host,uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Send the POST request
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(postdata)
      response = http.request(request)
      return JSON.parse(response.body)

    rescue Exception => e
      return { success: false, "error-codes": [ e.message ] }
    end
  end

end
