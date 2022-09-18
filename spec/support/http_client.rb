require 'net/http'
require 'net/https'
require 'uri'

module Helpers
  def http_get(url)
    uri = URI.parse(url)

    custom_target = ENV['TARGET_HOST']&.then { URI.parse(_1) }
    target = custom_target || uri

    http = Net::HTTP.new(target.host, target.port)
    http.use_ssl = true if target.scheme == 'https'

    http.start do
      headers = {
        'Host' => target.host,
        'x-rko-host' => uri.host,
        'x-rko-xfp' => uri.scheme,
      }
      http.get(uri.path, headers)
    end
  end
end
