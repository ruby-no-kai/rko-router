require "faraday"

module Helpers
  def connection
    Faraday::Connection.new
  end
end
