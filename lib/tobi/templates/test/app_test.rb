$LOAD_PATH.unshift(File.dirname(__FILE__) + "/../")
require "app.rb"
require "test/unit"
require "rack/test"

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    <%= @src[:test_run] %>
  end

  def test_root
    get '/'
    assert_match /<h1>Hello!<\/h1>/, last_response.body
  end
end

