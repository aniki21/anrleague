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

  # display icons for a user's membership or ownership of a league
  def league_member(league,user=nil)
    if logged_in?
      user ||= current_user
    end
    return if user.blank?

    membership = user.membership_of(league)
    case membership
    when "officer"
      return '<i data-toggle="tooltip" data-placement="left" title="Officer" class="fa fa-angle-double-up league-officer"></i>'.html_safe 
    when "member"
      return '<i data-toggle="tooltip" data-placement="left" title="Member" class="fa fa-star league-member"></i>'.html_safe 
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

  # Common delete button
  def delete_button(path_to_delete,model_name="item",button_label="Delete")
    link_to button_label, "javascript:void(0)", class:"btn btn-danger btn-xs", "data-action": "delete", "data-model-name": model_name, "data-href":path_to_delete
  end
end
