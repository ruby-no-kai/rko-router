require_relative "./spec_helper"

describe "http://2006.rubykaigi.org" do
  describe "/" do
    let(:res) { http_get("http://2006.rubykaigi.org/") }
    it "redirects to http://2009-2011.rubykaigi.org/2006/" do
      expect(res.code).to eq("301")
      expect(res["location"]).to eq("http://2009-2011.rubykaigi.org/2006/")
    end
  end
end
