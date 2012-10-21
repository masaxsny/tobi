$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../")
require "app.rb"
require "rack/test"

describe "App" do
  include Rack::Test::Methods

  def app
    <%= @src[:test_run] %>
  end

  describe "last_response.body" do
    before { get '/' }
    subject { last_response.body }
    it { should match /<h1>Hello!<\/h1>/ }
  end
end

