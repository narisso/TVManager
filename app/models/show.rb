class Show < ActiveRecord::Base
  
  attr_accessible :name, :status, :tvr_id, :country, :started, :tvdb_id, :imdb_id

  validates_uniqueness_of :tvr_id

  has_many :user_favourites
  has_many :users, :through => :user_favourites

  def self.load_tvr_feed

  	puts 'START  REQUEST'

  	res = HTTParty.get('http://services.tvrage.com/feeds/show_list.php')
    
    body = res.body

  	puts 'END REQUEST'

  	puts 'START  PARSING'

    	doc = Nokogiri::XML(body)

      doc.xpath('/shows/show').map do |show|

      	name = show.xpath('name').inner_text
      	tvr_id = show.xpath('id').inner_text.to_i
      	status = show.xpath('status').inner_text.to_i
        country = show.xpath('country').inner_text
    
      	Show.create(:tvr_id => tvr_id, :status => status, :name => name, :country => country)
      	
  	end
  	puts 'END PARSING'
    return nil

  end

  def add_aired_column

    show = self 

    if show.started == "Not yet processed" 
      puts "API Request : " + show.name + " " + show.tvr_id.to_s
      tvr_info = show.load_tvr_details
      
      puts show.name + " new airdate: " + tvr_info.started.to_s
      show.started = tvr_info.started.to_s
      show.save
    else

    end

  end

  def add_tvdb_column

    show = self
    
    if show.tvdb_id.nil? 
      
      begin
        started = nil
        begin 
          started = Time.parse(show.started)
        rescue Exception => e 
        
        end
        
        puts "TVDB Request : " + show.name + " " + show.tvdb_detail_url
      
        tvdb_matches = show.tvdb_api_details(3)
        best_match = nil

        #try match by air date
        tvdb_matches.each do |match|
          if (not match.firstaired.blank?) and (not started.nil?)
            possible_match_date = Time.parse(match.firstaired)
            if started.year == possible_match_date.year and started.month == possible_match_date.month
              best_match = match
              break
            end
          end
        end

        #try match by name
        if best_match.nil?
          tvdb_matches.each do |match|
            if match.seriesname == show.name
              best_match = match
              break
            end
          end
        end

        #try changing a bit the name
        if best_match.nil?
          new_name = show.name

          index = new_name.index('(')
          if not index.nil?
            new_name = new_name[0,index]
          
            puts "TVDB Request : " + show.name + " " + show.tvdb_detail_url(new_name)
            tvdb_matches = show.tvdb_api_details( 3 , new_name )

            #try match by air date with new name
            tvdb_matches.each do |match|
              if (not match.firstaired.blank?) and (not started.nil?)
                possible_match_date = Time.parse(match.firstaired)
                if started.year == possible_match_date.year and started.month == possible_match_date.month
                  best_match = match
                  break
                end
              end
            end

          end
        end

        if not best_match.nil?
          puts show.name + " new tvdb: " + best_match.tvdbid.to_s
          show.tvdb_id = best_match.tvdbid
          if not best_match.imdbid.blank?
            show.imdb_id = best_match.imdbid
          end
          show.save
        else

        end


      rescue Exception => e
        puts show.name + " " + e.message
        Rails.logger.debug(show.name + " " + e.to_s)
      end
      
    else

    end

  end

  def add_imdb_column

    show = self
    
    #only when we have a match in tvdb
    if not show.tvdb_id.nil? and show.imdb_id.nil?

      begin

        if not self.try_omdb
          self.try_imdb
        end

      rescue Exception => e
        puts show.name + " " + e.message
        puts e.backtrace
        Rails.logger.debug(show.name + " " + e.to_s)
      end

    end
  
  end

  def try_omdb

    show = self
    return_value = false

    begin

      omdb_match = show.omdb_api_match(3)
      
      if not omdb_match.nil?
        
        started = nil
        begin 
          started = Time.parse(show.started)
        rescue Exception => e 
          started = nil
        end

        best_match = nil
        #try match by air date
        if (not omdb_match["Released"].nil?) and (not started.nil?)
          possible_match_date = nil
          begin
            possible_match_date = Time.parse(omdb_match["Released"])
          rescue Exception => e
            possible_match_date = nil
          end

          if (not possible_match_date.nil?) and (started.year == possible_match_date.year and started.month == possible_match_date.month)
            best_match = omdb_match
          elsif started.year == omdb_match["Year"].to_i
            best_match = omdb_match
          end
        end

        if not best_match.nil?
          puts show.name + " new imdb: " + omdb_match["imdbID"].to_s
          show.imdb_id = omdb_match["imdbID"].to_s
          show.save
          return_value = true
        end

      end

    rescue Exception => e
      puts show.name + " " + e.message
      puts e.backtrace
      Rails.logger.debug(show.name + " " + e.to_s)
    end

    return return_value
 
  end

  def try_imdb

    show = self
    return_value = false

    begin
            
      imdb_match = show.imdb_api_match(3)

      if not imdb_match.nil?
        started = nil
        begin 
          started = Time.parse(show.started)
        rescue Exception => e 
          started = nil
        end

        best_match = nil
        #try match by air date
        if (not imdb_match["release_date"].nil?) and (not started.nil?)
          possible_match_date = nil
          begin
            possible_match_date = Time.parse(imdb_match["release_date"])
          rescue Exception => e
            possible_match_date = nil
          end

          if (not possible_match_date.nil?) and (started.year == possible_match_date.year and started.month == possible_match_date.month)
            best_match = imdb_match
          elsif started.year == imdb_match["year"].to_i
            best_match = imdb_match
          end
        end

        if not best_match.nil?
          puts show.name + " new imdb: " + imdb_match["imdb_id"].to_s
          show.imdb_id = imdb_match["imdb_id"].to_s
          show.save
          return_value = true
        end

      end

    rescue Exception => e
      puts show.name + " " + e.message
      puts e.backtrace
      Rails.logger.debug(show.name + " " + e.to_s)
    end

    return return_value
  
  end

  def load_tvr_details
    require_dependency 'tvr_info'
    require_dependency 'episode'

    details = nil

    details = Rails.cache.fetch("/show/#{self.tvr_id}/tvr_info", :expires_in => 6.hours) do
       
      details = self.tvr_api_details (3)
    
    end

    if details.nil?
      Rails.cache.delete("/show/#{self.tvr_id}/tvr_info") 
    end

    return details

  end

  def load_imdb_details

    details = nil

    details=Rails.cache.fetch("/show/#{self.tvr_id}/imdb_info", :expires_in => 6.hours) do
    
      details = self.imdb_api_details (3)
    
    end

    if details.nil?
      Rails.cache.delete("/show/#{self.tvr_id}/imdb_info") 
    end

    return details

  end

  def omdb_api_match(retry_num, name = self.name)

    if retry_num < 0 then return nil end

    begin
      puts "OMDB Request : " + self.name + " " + self.omdb_match_url
      response = HTTParty.get( self.omdb_match_url(name) )
      body = response.body

      omdb_info = ActiveSupport::JSON.decode(body)
      
      if omdb_info["Response"] == "False"
        omdb_info = nil
      end

      return omdb_info

    rescue Exception => e
      puts "Error: "+e.message+" Retries: "+retry_num.to_s
      Rails.logger.debug(e.message)
      return self.omdb_api_match(retry_num - 1,name)
    end

  end

  def imdb_api_match(retry_num, name = self.name)

    if retry_num < 0 then return nil end

    begin
      puts "IMDB Request : " + self.name + " " + self.imdb_match_url

      response = HTTParty.get( self.imdb_match_url(name), :timeout => 5 )
      body = response.body

      imdb_info = ActiveSupport::JSON.decode(body)

      if imdb_info[0].nil?
        imdb_info = nil
        return imdb_info
      end

      return imdb_info[0]

    rescue Exception => e
      puts "Error: "+e.message+" Retries: "+retry_num.to_s
      Rails.logger.debug(e.message)
      return self.imdb_api_match(retry_num - 1,name)
    end

  end

  #FROM OMDB
  def imdb_api_details(retry_num)

    if retry_num < 0 then return nil end

    begin
      puts "IMDB Request : " + self.name + " " + self.imdb_detail_url

      response = HTTParty.get( self.imdb_detail_url )
      body = response.body

      omdb_info = ActiveSupport::JSON.decode(body)
      
      if omdb_info["Response"] == "False"
        omdb_info = nil
      end

      return omdb_info

    rescue Exception => e
      puts "Error: "+e.message+" Retries: "+retry_num.to_s
      #Rails.logger.debug("Error: "+e.message+" Retries: "+retry_num.to_s)
      return self.imdb_api_details(retry_num - 1)
    end

  end

  def tvdb_api_details (retry_num, name = self.name)

    require_dependency 'tvdb_info'

    if retry_num < 0 then return nil end

    begin
      puts "TVDB Request : " + self.name + " " + self.tvdb_detail_url(name)

      response = HTTParty.get( self.tvdb_detail_url(name) ) 
      body = response.body
      doc = Nokogiri::XML(body)

      tvdb_matches = []
      doc.xpath('/Data/Series').map do |show|
              
        #Rails.logger.debug("XML : " + show.to_s)
        tvdb_info = TvdbInfo.new(show)
        tvdb_matches << tvdb_info

      end

      return tvdb_matches

    rescue Exception => e
      puts "Error: "+e.message+" Retries: "+retry_num.to_s
      #Rails.logger.debug("Error: "+e.message+" Retries: "+retry_num.to_s)
      return self.tvdb_api_details(retry_num - 1,name)
    end

  end

  def tvr_api_details (retry_num)
    
    if retry_num < 0 then return nil end

    begin
      puts "TVR Request : " + self.name + " " + self.tvr_detail_url

      response = HTTParty.get( self.tvr_detail_url )
      body = response.body
      doc = Nokogiri::XML(body)

      tvr_info = nil
      doc.xpath('/Show').map do |show|
              
        #Rails.logger.debug("XML : " + show.to_s)
        tvr_info = TvrInfo.new(show)

      end

      return tvr_info

    rescue Exception => e
      puts "Error: "+e.message+" Retries: "+retry_num.to_s
      #Rails.logger.debug("Error: "+e.message+" Retries: "+retry_num.to_s)
      return self.tvr_api_details(retry_num - 1)
    end

  end

  def add_attrs(attrs)
    attrs.each do |var, value|
      class_eval { attr_accessor var }
      instance_variable_set "@#{var}", value
    end
  
  end

  def image_url
    require 'net/http'

    begin
      response = nil
      show_image = self.tvr_image_url
      url = URI.parse(show_image)
      Net::HTTP.start(url.host, url.port) {|http|
        response = http.head(url.path)
      }

      show_image = self.default_image_url if (response == nil or response['content-length'] == nil )
      
      return show_image
    rescue
      return self.default_image_url
    end
  end

  def tvr_detail_url
   
    return 'http://services.tvrage.com/feeds/full_show_info.php?sid='+self.tvr_id.to_s
  
  end

  def tvdb_detail_url (name = self.name)
    encoded_name = CGI::escape(name)
    return "http://thetvdb.com/api/GetSeries.php?seriesname="+encoded_name
  
  end

  def imdb_detail_url

    return "http://www.omdbapi.com/?i="+self.imdb_id

  end

  def omdb_match_url (name = self.name)
    encoded_name = CGI::escape(name)
    return "http://www.omdbapi.com/?i=&t="+encoded_name
  
  end

  def imdb_match_url (name = self.name, episodes = "0")
    encoded_name = CGI::escape(name)
    return "http://imdbapi.org/?episode="+episodes+"&limit=1&q="+encoded_name
  
  end

  def default_image_url
  
    return 'http://www.discountmugs.com/discountmugs/upload/cliparts/catimages/no_image_thumb.gif'
  
  end

  def tvr_image_url
    folder = (self.tvr_id / 1000 + 1).to_s
    img = self.tvr_id.to_s

    return 'http://images.tvrage.com/shows/' + folder + '/' + img
  
  end

  def get_download_string (season , episode)

    tvrinfo = self.load_tvr_details
    clean_name = self.name.dup
    while clean_name.gsub!(/\([^()]*\)/,""); end
    string = clean_name

    if  tvrinfo.genres.include? "Anime"
      string = string + " " + tvrinfo.seasons[season.to_i][episode.to_i-1].full_number.to_s
    else
      string = string + " S" + format('%02d', season.to_i)+"E"+format('%02d', episode.to_i)
    end

    return string

  end
  
  def status_string

    if self.status == 0
      return 'Unknown'
    elsif self.status == 1
      return 'Returning Series'
    elsif self.status == 2
      return 'Cancelled / Ended'
    elsif  self.status == 3
      return 'TBD / On The Bubble'
    elsif self.status == 4
      return 'In Development'
    elsif  self.status == 7
      return 'New Series'
    elsif self.status == 8
      return 'Never Aired'
    elsif self.status == 9
      return 'Final Season'
    elsif  self.status == 10
      return 'On Hiatus'
    elsif self.status == 11
      return 'Pilot Ordered'
    elsif self.status == 12
      return 'Pilot Rejected'
    elsif self.status == 13
      return 'Canceled'
    elsif self.status == 14
      return 'Ended'
    else
      return self.status.to_s
    end

  end

end
