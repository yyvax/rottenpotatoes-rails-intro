class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @selected_checkbox = []
    redirect_flag = false;
    if params[:ratings] 
      @selected_checkbox = params[:ratings].keys
      session[:ratings] = params[:ratings] 
    elsif session[:ratings]
      @selected_checkbox = session[:ratings].keys   
      redirect_flag = true
    else
      @selected_checkbox = Movie.distinct.pluck(:rating)    
    end 
    
    sort_by = ''
    if params[:sort]
      session[:sort] = params[:sort] 
      sort_by = params[:sort]
    elsif session[:sort]
      sort_by = session[:sort]
      redirect_flag = true
    end 
   
    params[:ratings] ?
    @movies = Movie.with_ratings(params[:ratings].keys) 
    : @movies = Movie.all
    
    case sort_by
      when 'title'
      puts @selected_checkbox
      if @selected_checkbox.length > 0
         @movies = Movie.where(rating: @selected_checkbox).order('title ASC')
      else
         @movies = Movie.order('title ASC')
      end 
        @title_hilite = 'hilite'
      when 'release'
        if @selected_checkbox.length > 0
          @movies = Movie.where(rating: @selected_checkbox).order('release_date ASC')
        else
          @movies = Movie.order('release_date ASC')
        end
        @release_hilite = 'hilite'
    end
    
    if redirect_flag
      redirect_to movies_path(sort: sort_by, ratings: session[:ratings])
    end 
    @all_ratings = Movie.all_ratings
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    # flash[:notice] = "#{@movie.title} was successfully created."
    flash[:notice] = "#{@movie.title} was CREATED!"
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
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
