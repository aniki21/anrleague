module ApplicationHelper
  def page_title
    title = []
    # do stuff
    title.push("ANR Leagues")

    return title.join(" | ")
  end

  def alert_flash(key)
    case key
    when "error"
      return "danger"
    else
      return key
    end
  end
end
