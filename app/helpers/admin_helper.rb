module AdminHelper
  def reportee_path(reportee)
    case reportee.class.name
    when "Liga"
      return show_league_path(reportee.id,reportee.slug)
    when "User"
      return show_profile_path(reportee.id,reportee.slug)
    else
      return nil
    end
  end

  def reportee_stats(reportee)
    flags = reportee.reports_against

    stats = "#{stat_badge("default","Total",flags.count)}"
    stats += " #{stat_badge("success","Upheld",flags.upheld.count)}"
    stats += " #{stat_badge("danger","Rejected",flags.rejected.count)}"

    return stats.html_safe
  end

  def reporter_stats(reporter)
    flags = reporter.report_flags

    stats = "#{stat_badge("default","Total",flags.count)}"
    stats += " #{stat_badge("success","Upheld",flags.upheld.count)}"
    stats += " #{stat_badge("danger","Rejected",flags.rejected.count)}"

    return stats.html_safe
  end

  def stat_badge(css_class,title,count)
    return "<span class=\"label label-#{css_class}\" title=\"#{title}\" data-toggle=\"tooltip\" data-placement=\"top\">#{count}</span>"
  end

  def reportee_icon(reportee_type)
    case reportee_type
    when "User"
      icon = '<i class="fa fa-user" title="User"></i>'
    when "League"
      icon = '<i class="fa fa-list" title="League"></i>'
    else
      icon = '<i class="fa fa-question" title="Unknown"></i>'
    end
    return icon.html_safe
  end

  def report_row_class(flag)
    (flag.upheld? ? "success" : (flag.rejected? ? "danger" : "" ))
  end
end
