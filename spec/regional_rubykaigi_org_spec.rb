require_relative "./spec_helper"

describe "http://regional.rubykaigi.org" do
  describe "(http) /" do
    let(:res) { http_get("http://regional.rubykaigi.org/") }
    it "redirects to https" do
      expect(res.code).to eq("301")
      expect(res["location"]).to eq("https://regional.rubykaigi.org/")
    end
  end

  %w(
    /
    /oedo03/
    /osaka01/
    /kansai2017/
    /kansai06/
    /kansai05/
    /chuork01/
    /shibuya01/
    /tokyu12/
    /tokyu11/
    /tokyu09/
    /tokyu08/
    /kana01/
    /oedo04/
    /hamamatsu01/
    /oedo05/
    /oedo06/
    /oedo10/
    /tokyo12/
    /tokyo11/
    /tokyu10/
    /kwsk01/
  ).each do |path|
    describe(path) do
      let(:res) { http_get("https://regional.rubykaigi.org#{path}") }
      it "returns ok" do
        pending 'kanrk05.herokuapp.com is down' if path == '/kansai05/'
        pending 'http://rubykaigi-hamamatsu.s3-website-ap-northeast-1.amazonaws.com/hamamatsu01/ returns C-T:application/javascript' if path == '/hamamatsu01/'
        pending 'asakusa.github.io returns 301 (#110)' if path == '/oedo05/'
        pending 'asakusa.github.io returns 301 (#110)' if path == '/oedo06/'
        pending 'asakusa.github.io returns 301 (#110)' if path == '/oedo10/'

        expect(res.code).to eq("200")
        expect(res["content-type"]).to include("text/html")
      end
    end
  end

  %w(
    /matrk08/ matsue.rubyist.net
    /matsue08/ matsue.rubyist.net
    /matrk07/ matsue.rubyist.net
    /matsue07/ matsue.rubyist.net
    /okrk01/ ruby.okinawa
  ).each_slice(2) do |path, host|
    describe(path) do
      let(:res) { http_get("https://regional.rubykaigi.org#{path}") }
      it "redirects to matsue.rubyist.net" do
        expect(res.code.to_i).to be_between(300, 399)
        expect(res["location"]).to include(host)
      end
    end
  end
end
