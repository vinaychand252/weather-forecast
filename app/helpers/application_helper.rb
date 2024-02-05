module ApplicationHelper
  def utc_to_specific(time_str, zone)
    time_str ? time_str.in_time_zone("UTC").in_time_zone(zone) : nil
  end
end
