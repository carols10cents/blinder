module ApplicationHelper
  def markdown(content)
    Kramdown::Document.new(content).to_html
  end
end
