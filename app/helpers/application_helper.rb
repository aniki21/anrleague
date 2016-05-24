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
    when "owner"
      return '<i data-toggle="tooltip" data-placement="left" title="Owner" class="fa fa-star-o league-officer"></i>'.html_safe 
    when "officer"
      return '<i data-toggle="tooltip" data-placement="left" title="Officer" class="fa fa-angle-double-up league-officer"></i>'.html_safe 
    when "member"
      return '<i data-toggle="tooltip" data-placement="left" title="Member" class="fa fa-check league-member"></i>'.html_safe 
    end
  end

  def player_identity(identity,default="Unknown")
    return "<a class=\"#{identity.icon_style}\" href=\"#{identity.nrdb_url}\" target=\"_blank\"><i class=\"icon icon-#{identity.icon_style}\"></i> <span class=\"hidden-xs\">#{identity.display_name.truncate(40)}</span><span class=\"visible-xs-inline\">#{identity.short_name}</span></a>".html_safe unless identity.blank?
    return nil
    case default
    when "Runner"
      return "<span class=\"runner\">Runner</span>".html_safe
    when "Corp"
      return "<span class=\"corp\">Corp</span>".html_safe
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

  def league_role_row_style(role)
    case role.downcase
    when "owner","officer"
      return "info"
    end
  end

  def league_position(league,user)
    return nil if league.blank? or user.blank? 
    pos = league.user_position(user)
    return nil if pos.blank?
    return "#{pos[:position].ordinalize} with #{pos[:points]} points" unless pos[:points].to_i == 0
  end

  # Common delete button
  def delete_button(path_to_delete,model_name="item",button_label="Delete",additional_message="")
    link_to button_label, "javascript:void(0)", class:"btn btn-danger btn-xs", "data-action": "delete", "data-model-name": model_name, "data-href":path_to_delete, "data-message":additional_message
  end
end
