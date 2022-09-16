require_relative "./spec_helper"

describe "http://sponsorship.rubykaigi.org" do
  describe("/") do
    let(:res) { http_get("http://sponsorship.rubykaigi.org/") }
    it "redirects" do
      expect(res.code).to eq("302")
      expect(res['location']).to eq("https://sponsorships.rubykaigi.org")
    end
  end
end
