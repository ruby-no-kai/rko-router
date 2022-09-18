require_relative "./spec_helper"

describe "http://rubykaigi.org" do
  let(:latest_year) { "2022" }

  describe "(https) /" do
    let(:res) { http_get("https://rubykaigi.org/") }
    it "redirects to latest_year" do
      expect(res.code).to eq("302")
      expect(res["location"]).to eq("https://rubykaigi.org/#{latest_year}/")
    end
  end

  describe "(http) /" do
    let(:res) { http_get("http://rubykaigi.org/") }
    it "redirects to latest_year" do
      expect(res.code).to eq("302")
      expect(res["location"]).to eq("https://rubykaigi.org/#{latest_year}/")
    end
  end

  [*(2006..2009), *(2014..2017)].each do |year|
    describe "/#{year}/" do
      let(:res) { http_get("https://rubykaigi.org/#{year}/") }
      it "should be available" do
        expect(res.code).to eq("200")
      end
    end

    describe "/#{year}" do
      let(:res) { http_get("https://rubykaigi.org/#{year}") }
      it "should return 301 for trailing slash" do
        expect(res.code).to eq("301")
        expect(res['location']).to eq("https://rubykaigi.org/#{year}/")
      end
    end

    context "http" do
      describe "/#{year}" do
        let(:res) { http_get("http://rubykaigi.org/#{year}") }
        it "should return 301 for https" do
          expect(res.code).to eq("301")
          expect(res['location']).to eq("https://rubykaigi.org/#{year}")
        end
      end

      describe "/#{year}/" do
        let(:res) { http_get("http://rubykaigi.org/#{year}/") }
        it "should return 301 for https" do
          expect(res.code).to eq("301")
          expect(res['location']).to eq("https://rubykaigi.org/#{year}/")
        end
      end
    end
  end

  describe "/2013/" do
    let(:res) { http_get("https://rubykaigi.org/2013/") }
    it "should render the top page" do
      expect(res.code).to eq("200")
      expect(res.body).to include("<title>RubyKaigi 2013, May 30 - Jun 1</title>")
    end
  end

  describe "/2012/" do
    let(:res) { http_get("https://rubykaigi.org/2012/") }
    it "should render the special 200 (not 404) page" do
      expect(res.code).to eq("200")
      expect(res.body).to include("<title>RubyKaigi 2012: 404 Kaigi Not Found</title>")
    end
  end

  describe "/2011" do
    let(:res) { http_get("https://rubykaigi.org/2011") }
    it "redirects to /2011/" do
      expect(res.code).to eq("301")
      expect(res["location"]).to eq("https://rubykaigi.org/2011/")
    end
  end

  describe "/2011/" do
    let(:res) { http_get("https://rubykaigi.org/2011/") }
    it "should render the top page" do
      expect(res.code).to eq("200")
      expect(res.body).to include("<title>RubyKaigi 2011(July 16 - 18)</title>")
    end
  end

  describe "/2010" do
    let(:res) { http_get("https://rubykaigi.org/2010") }
    it "redirects to /2010/" do
      expect(res.code).to eq("301")
      expect(res["location"]).to eq("https://rubykaigi.org/2010/")
    end
  end

  describe "/2010/en/" do
    let(:res) { http_get("https://rubykaigi.org/2010/en/") }
    it "should render the top page" do
      expect(res.code).to eq("200")
      expect(res.body).to include("<title>RubyKaigi 2010, August 27-29</title>")
    end
  end

  describe "/2009" do
    let(:res) { http_get("https://rubykaigi.org/2009") }
    it "redirects to /2009/" do
      expect(res.code).to eq("301")
      expect(res["location"]).to eq("https://rubykaigi.org/2009/")
    end
  end

  describe "/2009/en/" do
    let(:res) { http_get("https://rubykaigi.org/2009/en/") }
    it "should render the top page" do
      expect(res.code).to eq("200")
      expect(res.body).to include("<title>RubyKaigi2009</title>")
    end
  end

  describe "/2005" do
    let(:res) { http_get("http://rubykaigi.org/2005") }
    it "should be 404" do
      expect(res.code).to eq("404")
    end
  end

  describe "/2005/en" do
    let(:res) { http_get("http://rubykaigi.org/2005/en") }
    it "should be 404" do
      expect(res.code).to eq("404")
    end
  end

  describe "/2019/" do
    context "https" do
      let(:res) { http_get("https://rubykaigi.org/2019/") }
      it "should be 200" do
        expect(res.code).to eq("200")
      end
    end

    context "http" do
      let(:res) { http_get("http://rubykaigi.org/2019/") }
      it "should force https" do
        expect(res.code).to eq("301")
        expect(res["location"]).to eq("https://rubykaigi.org/2019/")
      end
    end
  end

  # TODO consider ja locale case
end
