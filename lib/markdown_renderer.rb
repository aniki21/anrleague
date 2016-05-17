class MarkdownRenderer < Redcarpet::Render::HTML
  def link(link, title, alt_text)
    "<a target=\"_blank\" href=\"#{link}\">#{alt_text}</a>"
  end
  def autolink(link, link_type)
    "<a target=\"_blank\" href=\"#{link}\">#{link}</a>"
  end

  def image(link,title,content)
    "<img src=\"#{link}\" style=\"max-width:100%;\" alt=\"#{content}\" title=\"#{content}\"/>"
  end

  def header(text,level)
    level += 1
    "<h#{level}>#{text}</h#{level}>"
  end
end
