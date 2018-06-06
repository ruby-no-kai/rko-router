require_relative "./spec_helper"

describe "http://sapporo.rubykaigi.org" do
  describe("/") do
    let(:res) { http_get("http://sapporo.rubykaigi.org/") }
    it "returns ok" do
      expect(res.code).to eq("200")
      expect(res["content-type"]).to include("text/html")
    end
  end
end
