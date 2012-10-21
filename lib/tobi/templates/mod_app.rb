require "<%= @src[:base_require] %>"
<%= @src[:view_template_require] %>
<%= @src[:css_template_require] %>

module <%= @app_name.capitalize %>
  class App < Sinatra::Base
    get '/' do
      @ua = request.user_agent
      <%= @src[:view_template] %> :index<%= @src[:locals] %>
    end
    <% if @src[:css_template] %>
    get '*.css' do |path|
      <%= @src[:css_template] %> path.to_sym
    end
    <% end %>
  end
end

<% if @src[:app_run] -%>
<%= @src[:app_run] %>
<% end -%>
