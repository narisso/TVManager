class ShowsController < ApplicationController
  # GET /shows
  # GET /shows.json
  def index
    
    if params[:term] #term only appears with json
      @shows = Show.where("imdb_id IS NOT NULL AND tvdb_id IS NOT NULL AND name LIKE ?", "#{params[:term]}%").order(:name).page(1).per(10)

    elsif params[:search] #a search request
      if params[:id].blank? #no specific, just a query
        @shows = Show.where("imdb_id IS NOT NULL AND tvdb_id IS NOT NULL AND name LIKE ?", "#{params[:search]}%").order(:name).page(params[:page]).per(10)
      else #got id, we can find a specific show
        redirect_to show_path(Show.find_by_tvr_id(params[:id])) and return
      end
    else
      @shows = Show.where("imdb_id IS NOT NULL AND tvdb_id IS NOT NULL").order(:name).page(params[:page]).per(10)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shows }
    end
  end

  # GET /shows/
  # GET /shows/1.json
  def show
    @show = Show.find(params[:id])

    #API REQUEST
    @show_info = @show.load_tvr_details

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @show }
    end
  end

  # GET /shows/new
  # GET /shows/new.json
  def new

    @show = Show.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @show.errors }
    end
  end

  # GET /shows/1/edit
  def edit
    @show = Show.find(params[:id])
  end

  # POST /shows
  # POST /shows.json
  def create
    @show = Show.new(params[:show])

    respond_to do |format|
      if @show.save
        format.html { redirect_to @show, notice: 'show was successfully created.' }
        format.json { render json: @show, status: :created, location: @show }
      else
        format.html { render action: "new" }
        format.json { render json: @show.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shows/1
  # PUT /shows/1.json
  def update
    @show = Show.find(params[:id])
    info = params[:show]

    respond_to do |format|
      if true
        if @show.update(info)
          format.html { redirect_to @show, notice: 'show was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @show.errors, status: :unprocessable_entity }
        end  
      else
          format.html { render action: "edit" }
          format.json { render json: @show.errors, status: :unprocessable_entity }
      end  
      
    end
  end

  # DELETE /shows/1
  # DELETE /shows/1.json
  def destroy
    @show = Show.find(params[:id])
    @show.destroy

    respond_to do |format|
      format.html { redirect_to shows_url }
      format.json { head :no_content }
    end
  end
end
