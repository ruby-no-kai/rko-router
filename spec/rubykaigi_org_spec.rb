require_relative "./spec_helper"

describe "http://rubykaigi.org" do
  describe "/" do
    let(:res) { connection.get("http://rubykaigi.org/") }
    it "redirects to /?locale=en" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://rubykaigi.org/2014")
    end
  end

  describe "/?locale=en" do
    let(:res) { connection.get("http://rubykaigi.org/?locale=en") }
    it "redirects to /2014" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://rubykaigi.org/2014")
    end
  end

  describe "/?locale=ja" do
    let(:res) { connection.get("http://rubykaigi.org/?locale=ja") }
    it "redirects to /2014" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://rubykaigi.org/2014")
    end
  end

  describe "/2013" do
    let(:res) { connection.get("http://rubykaigi.org/2013") }
    it "should render the top page" do
      expect(res.status).to eq(200)
      expect(res.body).to include("<title>RubyKaigi 2013, May 30 - Jun 1</title>")
    end
  end

  describe "/2012" do
    let(:res) { connection.get("http://rubykaigi.org/2012") }
    it "should render the special 404 page" do
      expect(res.status).to eq(404)
      expect(res.body).to include("<title>RubyKaigi 2012: 404 Kaigi Not Found</title>")
    end
  end

  describe "/2011" do
    let(:res) { connection.get("http://rubykaigi.org/2011") }
    it "redirects to /2011/en" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://rubykaigi.org/2011/en")
    end
  end

  describe "/2011/en" do
    let(:res) { connection.get("http://rubykaigi.org/2011/en") }
    it "should render the top page" do
      expect(res.status).to eq(200)
      expect(res.body).to include("<title>RubyKaigi 2011(July 16 - 18)</title>")
    end
  end

  describe "/2010" do
    let(:res) { connection.get("http://rubykaigi.org/2010") }
    it "redirects to /2010" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://rubykaigi.org/2010/en")
    end
  end

  describe "/2010/en" do
    let(:res) { connection.get("http://rubykaigi.org/2010/en") }
    it "should render the top page" do
      expect(res.status).to eq(200)
      expect(res.body).to include("<title>RubyKaigi 2010, August 27-29</title>")
    end
  end

  describe "/2009" do
    let(:res) { connection.get("http://rubykaigi.org/2009") }
    it "redirects to /2009" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://rubykaigi.org/2009/en")
    end
  end

  describe "/2009/en" do
    let(:res) { connection.get("http://rubykaigi.org/2009/en") }
    it "should render the top page" do
      expect(res.status).to eq(200)
      expect(res.body).to include("<title>RubyKaigi2009</title>")
    end
  end

  describe "/2008" do
    let(:res) { connection.get("http://rubykaigi.org/2008") }
    it "redirects to /2008" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://rubykaigi.org/2008/en")
    end
  end

  describe "/2008/en" do
    let(:res) { connection.get("http://rubykaigi.org/2008/en") }
    it "should redirect to http://jp.rubyist.net/RubyKaigi2008" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://jp.rubyist.net/RubyKaigi2008")
    end
  end

  describe "/2007" do
    let(:res) { connection.get("http://rubykaigi.org/2007") }
    it "redirects to /2007" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://rubykaigi.org/2007/en")
    end
  end

  describe "/2007/en" do
    let(:res) { connection.get("http://rubykaigi.org/2007/en") }
    it "should redirect to http://jp.rubyist.net/RubyKaigi2007" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://jp.rubyist.net/RubyKaigi2007")
    end
  end

  describe "/2006" do
    let(:res) { connection.get("http://rubykaigi.org/2006") }
    it "redirects to /2006" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://rubykaigi.org/2006/en")
    end
  end

  describe "/2006/en" do
    let(:res) { connection.get("http://rubykaigi.org/2006/en") }
    it "should redirect to http://jp.rubyist.net/RubyKaigi2006" do
      expect(res.status).to eq(302)
      expect(res.headers["location"]).to eq("http://jp.rubyist.net/RubyKaigi2006")
    end
  end

  describe "/2005" do
    let(:res) { connection.get("http://rubykaigi.org/2005") }
    it "redirects to /2005" do
      expect(res.status).to eq(302) # NOTE 404 may be better
      expect(res.headers["location"]).to eq("http://rubykaigi.org/2005/en")
    end
  end

  describe "/2005/en" do
    let(:res) { connection.get("http://rubykaigi.org/2005/en") }
    it "should redirect to http://jp.rubyist.net/RubyKaigi2005" do
      expect(res.status).to eq(302) # NOTE 404 may be better
      expect(res.headers["location"]).to eq("http://jp.rubyist.net/RubyKaigi2005")
    end
  end

  # TODO consider ja locale case
end
