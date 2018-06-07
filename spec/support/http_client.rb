require 'net/http'
require 'net/https'
require 'uri'

module Helpers
  def http_get(url, proto: 'https')
    uri = URI.parse(url)
    target = URI.parse(ENV.fetch('TARGET_HOST', url))

    http = Net::HTTP.new(target.host, target.port)
    http.use_ssl = true if target.scheme == 'https'

    http.start do
      headers = {
        'Host' => target.host,
        'x-rko-host' => uri.host,
        'x-rko-xfp' => proto,
      }
      http.get(uri.path, headers)
    end
  end
end
