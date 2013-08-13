
class TvrInfo

	attr_accessor	:name,
					:totalseasons,
					:showid,
					:showlink,
					:started,
					:ended,
					:image,
					:origin_country,
					:status,
					:classification,
					:genres,
					:runtime,
					:network,
					:airtime,
					:airday,
					:timezone,
					:seasons

	def initialize(*args)
		case args.size
		when 1
			load_xml args[0]
		else
      		load_empty
		end
	end

	def load_xml(xml)
		@name = xml.xpath('name').inner_text
		@totalseasons = xml.xpath('totalseasons').inner_text.to_i
		@showid = xml.xpath('showid').inner_text.to_i
		@showlink = xml.xpath('showlink').inner_text
		@started = xml.xpath('started').inner_text
		@ended = xml.xpath('ended').inner_text
		@image = xml.xpath('image').inner_text
		@origin_country = xml.xpath('origin_country').inner_text
		@status = xml.xpath('status').inner_text
		@classification = xml.xpath('classification').inner_text

		@genres = []

		xml.xpath('genres/genre').map do |g|
			@genres << g.inner_text
		end

		@runtime = xml.xpath('runtime').inner_text
		@network = xml.xpath('network').inner_text

		@airtime = xml.xpath('airtime').inner_text
		if 	@airtime.blank? 	then	@airtime = '12:00'	end
		@airday = xml.xpath('airday').inner_text
		if 	@airday.blank? 	then	@airday = 'Monday'		end
		@timezone = xml.xpath('timezone').inner_text
		if 	@timezone.blank? 	then	@timezone = 'GMT-5 +DST'		end

		@seasons = {}

		xml.xpath('Episodelist/Season').map do |season|

				episodes = []
				
				season.xpath('episode').map do |episode|
					episodes << Episode.new(episode, season.attr('no').to_i ,self.airtime , self.airday , self.timezone)
				end

				@seasons[season.attr('no').to_i] = episodes
		end
	end

	def load_empty
		@name = ""
		@totalseasons = 0
		@showid = -1
		@showlink = ""
		@started = ""
		@ended = ""
		@image = ""
		@origin_country = ""
		@status = ""
		@classification = ""

		@genres = []

		@runtime = ""
		@network = ""

		@airtime = ""
		@airday = ""
		@timezone = 'GMT-5 +DST'

		@seasons = {}
	end

	def get_lastEpisode

		last_ep = nil
		ended_series = true
		self.seasons.each do |s,episodes|
			episodes.each_with_index do |e, index|
				if not e.isOld?
					last_ep = episodes[index-1]
					ended_series = false
					break
				end
			end
			break if last_ep != nil
		end

		#if ended_series
		#	last_season = self.seasons[self.seasons.length]
		#	last_ep = last_season[last_season.length - 1]
		#	Rails.logger.debug(last_ep.get_episodeNumber)
		#end

		return last_ep		
	end

end