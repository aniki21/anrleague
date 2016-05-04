module ApplicationHelper
  def page_title
    title = []
    
    title.push(@page_title) unless @page_title.blank?

    title.push(SITE_NAME)

    return title.join(" | ")
  end

  def paginate(collection)
    will_paginate collection, renderer: BootstrapPagination::Rails
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
    return "<a class=\"nr-#{identity.icon_style}\" href=\"#{identity.nrdb_url}\" target=\"_blank\"> <span class=\"hidden-xs\">#{identity.display_name}</span><span class=\"visible-xs-inline\">#{identity.short_name}</span></a>".html_safe unless identity.blank?
    return nil
    case default
    when "Runner"
      return "<span class=\"nr-runner\">Runner</span>".html_safe
    when "Corp"
      return "<span class=\"nr-corp\">Corp</span>".html_safe
    else
      return "<em>#{default}</em>".html_safe
    end
  end

  def result_row(result)
    case result
    when "Win"
      return "success"
    when "Loss"
      return "danger"
    else
      return ""
    end
  end
end
