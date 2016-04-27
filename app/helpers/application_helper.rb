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

  def offline_league_location(league)
    if league.offline?
      lookup = Geokit::Geocoders::GoogleGeocoder.reverse_geocode league.latlong
      loc = []
      loc.push(lookup.city) unless lookup.city.blank?
      loc.push(lookup.state) unless lookup.state.blank?
      loc.push(lookup.country) unless lookup.country.blank?

      return loc.join(", ")
    else
      return nil
    end
  end
end
