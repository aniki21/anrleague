class Recaptcha
  require 'net/https'
  require 'uri'

  def self.valid_response?(response,remote_ip=nil)

    postdata = {
      response: response,
      secret: ENV['RECAPTCHA_PRIVATE_KEY']
    }

    postdata[:remoteip] = remote_ip unless remote_ip.blank?

    uri = URI.parse("https://www.google.com/recaptcha/api/siteverify")
    http = Net::HTTP.new(uri.host,uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(postdata)
    response = http.request(request)
    JSON.parse(response.body) rescue false
  end

end
