require "markdiff"
require "redcarpet"
require "sinatra"

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

get "/" do
  if params[:before] && params[:after]
    html_before = markdown.render(params[:before])
    html_after = markdown.render(params[:after])
    p html_before
    p html_after
    @diff = Markdiff::Differ.new.render(html_before, html_after)
  end
  erb :index
end
