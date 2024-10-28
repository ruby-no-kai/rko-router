require_relative "./spec_helper"

describe "http://rubykaigi.org" do
  let(:latest_year) { "2025" }

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

  describe "(https) /go/policies" do
    let(:res) { http_get("https://rubykaigi.org/go/policies") }
    it "redirects to latest_year" do
      expect(res.code).to eq("302")
      expect(res["location"]).to eq("https://rubykaigi.org/#{latest_year}/policies")
    end
  end

  describe "(http) /go/policies" do
    let(:res) { http_get("http://rubykaigi.org/go/policies") }
    it "redirects to latest_year" do
      expect(res.code).to eq("302")
      expect(res["location"]).to eq("https://rubykaigi.org/#{latest_year}/policies")
    end
  end

  describe "(https) /2024/" do
    let(:res) { http_get("https://rubykaigi.org/2024/") }
    it "should render the top page" do
      expect(res.code).to eq("200")
    end
  end

  describe "(http) /2024/" do
    let(:res) { http_get("http://rubykaigi.org/2024/") }
    it "redirects to https" do
      expect(res.code).to eq("301")
      expect(res["location"]).to eq("https://rubykaigi.org/2024/")
    end
  end

  describe "(http) /2021" do
    let(:res) { http_get("http://rubykaigi.org/2021") }
    it "redirects to 2021-takeout" do
      expect(res.code).to eq("302")
      expect(res["location"]).to eq("https://rubykaigi.org/2021-takeout/")
    end
  end

  describe "(https) /2021" do
    let(:res) { http_get("https://rubykaigi.org/2021") }
    it "redirects to 2021-takeout" do
      expect(res.code).to eq("302")
      expect(res["location"]).to eq("https://rubykaigi.org/2021-takeout/")
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

  HOSTED_YEARS = [
    *(2006..2020),
    '2020-takeout',
    '2021-takeout',
    *(2022..2023),
  ]

  describe "force_https" do
    HOSTED_YEARS.each do |year|
      describe "/#{year}" do
        let(:res) { http_get("http://rubykaigi.org/#{year}/") }
        it "force https" do
          expect(res.code).to eq("301")
          expect(res["location"]).to eq("https://rubykaigi.org/#{year}/")
        end
      end

      describe "/#{year}/something" do
        let(:res) { http_get("http://rubykaigi.org/#{year}/something") }
        it "force https" do
          expect(res.code).to eq("301")
          expect(res["location"]).to eq("https://rubykaigi.org/#{year}/something")
        end
      end
    end
  end

  describe "trailing slash" do
    HOSTED_YEARS.each do |year|
      describe "(http) /#{year}" do
        let(:res) { http_get("http://rubykaigi.org/#{year}") }
        # this is because trailing slash may be enforced by backend (e.g. github pages) and force_https rewrite rule is prioritized over proxy_pass
        it "prioritizes force https" do
          expect(res.code).to eq("301")
          expect(res["location"]).to eq("https://rubykaigi.org/#{year}")
        end
      end


      describe "(https) /#{year}" do
        let(:res) { http_get("https://rubykaigi.org/#{year}") }
        it "adds trailing slash" do
          expect(res.code).to eq("301")
          expect(res["location"]).to eq("https://rubykaigi.org/#{year}/")
        end
      end
    end
  end

  HOSTED_YEARS.each do |year|
    describe "/#{year}/" do
      let(:res) { http_get("https://rubykaigi.org/#{year}/") }
      it "is available" do
        expect(res.code).to eq("200")
      end
    end
  end

  # TODO consider ja locale case
end
