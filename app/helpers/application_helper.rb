module ApplicationHelper
  def page_title
    title = []
    # do stuff
    title.push("ANR Leagues")

    return title.join(" | ")
  end
end
