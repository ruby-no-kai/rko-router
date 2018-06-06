require 'net/http'
require 'net/https'
require 'uri'

module Helpers
  def http_get(url)
    uri = URI.parse(url)
    target = URI.parse(ENV.fetch('TARGET_HOST', url))

    http = Net::HTTP.new(target.host, target.port)
    http.use_ssl = true if target.scheme == 'https'

    http.start do
      http.get(uri.path, {'x-rko-host' => uri.host, 'Host' => target.host})
    end
  end
end
