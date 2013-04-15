
class TvdbInfo

	attr_accessor	:tvdbid,
					:language,
					:seriesname,
					:overview,
					:firstaired,
					:imdbid

	def initialize(xml)
		@tvdbid = xml.xpath('seriesid').inner_text.to_i
		@language = xml.xpath('language').inner_text.to_i
		@seriesname = xml.xpath('SeriesName').inner_text
		@overview = xml.xpath('Overview').inner_text
		@firstaired = xml.xpath('FirstAired').inner_text
		@imdbid = xml.xpath('IMDB_ID').inner_text
		
		if 	@imdbid.blank? 	then	@imdbid = ''	end

	end
		
end