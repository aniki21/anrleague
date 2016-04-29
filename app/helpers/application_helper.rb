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

  def player_identity(identity,default="Unknown")
    return "<a class=\"nr-#{identity.icon_style}\" href=\"#{identity.nrdb_url}\" target=\"_blank\"> #{identity.display_name}</a>".html_safe unless identity.blank?
    return "<em>#{default}</em>".html_safe
  end
end
