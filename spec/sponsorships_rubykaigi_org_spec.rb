require_relative "./spec_helper"

describe "http://sponsorships.rubykaigi.org" do
  describe("/") do
    let(:res) { http_get("http://sponsorships.rubykaigi.org/") }
    it "redirects" do
      expect(res.code).to eq("302")
    end
  end
end
