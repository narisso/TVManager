
class Episode

	attr_accessor 	:full_number,
					:number,
					:season,
					:air_date,
					:link,
					:title,
					:screencap_url,
					:airtime,
					:airday,
					:timezone

	def initialize(xml, season, airtime, airday, timezone)

		@full_number = xml.xpath('epnum').inner_text.to_i
		@number = xml.xpath('seasonnum').inner_text.to_i
		@air_date = xml.xpath('airdate').inner_text
		@link = xml.xpath('link').inner_text
		@title = xml.xpath('title').inner_text
		@screencap_url = xml.xpath('screencap').inner_text

		@airtime = airtime
		@airday = airday
		@timezone = timezone
		@season = season

	end

	def get_airdate(target_timezone)
		air_date_time = nil
		begin
			date_time_string = self.air_date + " " + self.airtime + " " + self.timezone
    		air_date_time = Time.strptime( date_time_string , '%Y-%m-%d %H:%M %Z').in_time_zone(target_timezone)
    	rescue
    		air_date_time = Time.local( 9999 ,12 ,31,23,59 )
    	end
    	return air_date_time
	end

	def isOld?
		return (Time.zone.now > self.get_airdate(Time.zone) )
	end

	def get_episodeNumber
		return self.season.to_s + "x" + self.number.to_s
	end

end