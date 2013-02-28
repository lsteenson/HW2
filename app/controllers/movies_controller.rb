class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
  
    @all_ratings = Movie.all_ratings
    @ratings = Hash.new
    
    if session[:ratings] && !params[:ratings]
      if session[:loop_stop] == 0 || session[:loop_stop].nil?
        redirect_to movies_path session[:ratings] 
        session[:loop_stop] = 1
      else
        session[:loop_stop] = 0
      end
    end

    if !params[:sort].nil?
      session[:sort] = params[:sort]
    end
    
    if params.key? :ratings
      session[:ratings] = params[:ratings]
    elsif params.key? :commit
      session[:ratings] = nil
    end
    @sort = session[:sort]
    @ratings = session[:ratings]
    
    if @ratings != nil
      @movies = Movie.order(@sort).where("title != ''").select do |m|
          @ratings.include? m.rating
      end
    else
      @movies = Movie.order(@sort).all
    end

    if session[:sort] == 'title'
      @title_header = 'hilite'
    elsif session[:sort] == 'release_date'
      @release_date_header = 'hilite'
    end
     
    @all_ratings.each do |rating| 
      if session[:ratings].class == Hash
        if session[:ratings].key? rating
          @ratings[rating]= false
        else
          @ratings[rating] = true
        end
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
