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

  def pretty_date(date)
    date.strftime("%b #{date.day.ordinalize}")
  end

  def league_member(league)
    if logged_in?
      return '<i class="fa fa-star league_member" title="Member" data-toggle="tooltip" data-placement="right"></i>'.html_safe if current_user.leagues.include?(league)
    end
  end

  def player_identity(identity,default="Unknown")
    return "<a class=\"nr nr-#{identity.icon_style}\" href=\"#{identity.nrdb_url}\" target=\"_blank\"> <span class=\"hidden-xs\">#{identity.display_name.truncate(40)}</span><span class=\"visible-xs-inline\">#{identity.short_name}</span></a>".html_safe unless identity.blank?
    return nil
    case default
    when "Runner"
      return "<span class=\"nr nr-runner\">Runner</span>".html_safe
    when "Corp"
      return "<span class=\"nr nr-corp\">Corp</span>".html_safe
    else
      return "<em>#{default}</em>".html_safe
    end
  end

  def gravatar(email,size=50)
    gravatar_image_tag(email, :class => 'img-rounded', :gravatar => { :size => size, :rating => "g" }, title: "Gravatar")
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

  def delete_button(path_to_delete,model_name="item",button_label="Delete")
    link_to button_label, "javascript:void(0)", class:"btn btn-danger btn-xs", "data-action": "delete", "data-model-name": model_name, "data-href":path_to_delete
  end
end
