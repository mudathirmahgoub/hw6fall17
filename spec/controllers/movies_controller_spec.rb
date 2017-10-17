require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      fake_results = [double('movie1'), double('movie2')]
      allow(Movie).to receive(:find_in_tmdb).and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end 
    
    it 'should make the TMDb search term available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:search_terms)).to eq('Ted')
    end 
    
    it 'should receives a simple array of hashes' do
      fake_results = [{:tmdb_id => 1 , :title => 'title1', :rating => 'PG',
      :release_date => '1992-11-25 00:00:00 UTC'}, 
      {:tmdb_id => 2 , :title => 'title2', :rating => 'PG',
      :release_date => '1992-11-25 00:00:00 UTC'}]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      # assert that the returned result is an array
      expect(assigns(:movies).class).to be (Array)
      assigns(:movies).each do |movie|
        
        #assert that each element in the array is a hash
        expect(movie.class).to be (Hash)
        #assert that each hash has the following 4 keys
        expect(movie[:tmdb_id]).not_to be (nil)
        expect(movie[:title]).not_to be (nil)
        expect(movie[:release_date]).not_to be (nil)
        expect(movie[:rating]).not_to be (nil)
      end 
    end
    
    it 'should return Invalid search term message if the search term is nil ' do
      post :search_tmdb, {:search_terms => nil}
      expect(flash[:notice]).to eq "Invalid search term"
      expect(response).to redirect_to(:controller => 'movies', :action => 'index')
    end
    
    it 'should return Invalid search term message if the search term is blank' do
      post :search_tmdb, {:search_terms => "  "}
      expect(flash[:notice]).to eq "Invalid search term"
      expect(response).to redirect_to(:controller => 'movies', :action => 'index')
    end
    
    it 'should redirect to home page if no matching movies found in TMDB' do
      fake_results = []
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(flash[:notice]).to eq "No matching movies were found on TMDb"
      expect(response).to redirect_to(:controller => 'movies', :action => 'index')
    end
  end
  
  describe 'add TMDb' do
    before :each do
      @ids = {"27205"=>"1", "64956"=>"1", "250845"=>"1", "350632"=>"1"}
    end
    it 'should call the model method create_from_tmdb' do
      expect(Movie).to receive(:create_from_tmdb).with(27205)
      expect(Movie).to receive(:create_from_tmdb).with(64956)
      post :add_tmdb, {:tmdb_movies=>{"27205"=>"1", "64956"=>"1"}}
    end 
    
    it 'should return redirect to home page' do
      allow(Movie).to receive(:create_from_tmdb).with(27205)
      allow(Movie).to receive(:create_from_tmdb).with(64956)
      post :add_tmdb, {:tmdb_movies=>{"27205"=>"1", "64956"=>"1"}}
      expect(response).to redirect_to(:controller => 'movies', :action => 'index')
    end
    
    it 'should display confirmation message if movies are added' do
      allow(Movie).to receive(:create_from_tmdb).with(27205)
      allow(Movie).to receive(:create_from_tmdb).with(64956)
      post :add_tmdb, {:tmdb_movies=>{"27205"=>"1", "64956"=>"1"}}
      expect(response).to redirect_to(:controller => 'movies', :action => 'index')
      expect(flash[:notice]).to eq "Movies successfully added to Rotten Potatoes"   
    end
    
    it 'should display No movies selected if no movie is selected' do
      post :add_tmdb, {:tmdb_movies=>nil}
      expect(flash[:notice]).to eq "No movies selected"
      expect(response).to redirect_to(:controller => 'movies', :action => 'index')
    end
  end
  
  #old actions
  describe "show action" do
    it 'should call the model method find' do
      fake_result = double('movie')
      expect(Movie).to receive(:find).with("100").
        and_return(fake_result)
      get :show, {:id => 100}
    end
    
     it 'should select the show template for rendering' do
      fake_result = double('movie')
      expect(Movie).to receive(:find).with("100").
        and_return(fake_result)
      get :show, {:id => 100}
      expect(response).to render_template('show')
    end  
    it 'should make the result available to that template' do
      fake_result = double('movie')
      expect(Movie).to receive(:find).with("100").
        and_return(fake_result)
      get :show, {:id => 100}
      expect(assigns(:movie)).to eq(fake_result)
    end 
  end
  
  describe "create action" do
    before :each do
      @movie_params = {:title => 'Aladdin', :rating => 'G', :release_date => '25-Nov-1992'}
      @savedMovie = double('Movie', :id=> 100, :title => 'Aladdin', :rating => 'G', :release_date => '25-Nov-1992')
    end
    it 'should call the model method create!' do
      expect(Movie).to receive(:create!).with(@movie_params).and_return (@savedMovie)
      post :create, {:movie => @movie_params}
    end
    
     it 'should select movies_path template for rendering' do
      allow(Movie).to receive(:create!).with(@movie_params).and_return (@savedMovie)
      post :create, {:movie => @movie_params}
      expect(response).to redirect_to(:controller => 'movies', :action => 'index')
    end     
    
     it 'should return  message movie.title was successfully created.' do
      allow(Movie).to receive(:create!).with(@movie_params).and_return (@savedMovie)
      post :create, {:movie => @movie_params}
      expect(flash[:notice]).to eq ("#{@savedMovie.title} was successfully created.")
    end  
  end
  
  describe "edit" do
    before :each do
      @savedMovie = double('Movie', :id=> 100, :title => 'Aladdin', :rating => 'G', :release_date => '25-Nov-1992')
    end
    it 'should call the model method find' do
      expect(Movie).to receive(:find).with("100").and_return (@savedMovie)
      post :edit, {:id => 100}
    end
    
     it 'should select edit template for rendering' do
      allow(Movie).to receive(:find).with("100").and_return (@savedMovie)
      post :edit, {:id => 100}
      expect(response).to render_template('edit')
    end     
    
     it 'should return the selected movie' do
      allow(Movie).to receive(:find).with("100").and_return (@savedMovie)
      post :edit, {:id => 100}
      
      expect(assigns(@movie)[:movie]).to eq (@savedMovie)
    end  
  end
  
  describe "update action" do
    before :each do
      @movie_params = {:title => 'Terminator', :rating => 'G', :release_date => '25-Nov-1992'}
      @savedMovie = double('Movie', :id=> 100, :title => 'Aladdin', :rating => 'G', :release_date => '25-Nov-1992')
      allow(Movie).to receive(:find).with("100").and_return (@savedMovie)
    end
    it 'should call the model method update_attributes!' do
      expect(@savedMovie).to receive(:update_attributes!).with(@movie_params)
      put :update, {:id=> 100, :movie => @movie_params}
    end
    
     it 'should select movies_path template for rendering' do
      allow(@savedMovie).to receive(:update_attributes!).with(@movie_params)
      put :update, {:id=> 100, :movie => @movie_params}
      expect(response).to redirect_to movie_path(@savedMovie)
    end     
    
     it 'should return  message movie.title was successfully updated.' do
      allow(@savedMovie).to receive(:update_attributes!).with(@movie_params)
      put :update, {:id=> 100, :movie => @movie_params}
      expect(flash[:notice]).to eq ("#{@savedMovie.title} was successfully updated.")
    end  
  end
  
  describe "destroy action" do
    before :each do
      @savedMovie = double('Movie', :id=> 100, :title => 'Aladdin', :rating => 'G', :release_date => '25-Nov-1992')
      allow(Movie).to receive(:find).with("100").and_return (@savedMovie)
    end
    it 'should call the model method destroy' do
      expect(@savedMovie).to receive(:destroy)
      delete :destroy, {:id=> 100}
    end
    
     it 'should select movies_path template for rendering' do
      allow(@savedMovie).to receive(:destroy)
      delete :destroy, {:id=> 100}
      expect(response).to redirect_to movies_path
    end     
    
     it 'should return  message movie.title deleted.' do
      allow(@savedMovie).to receive(:destroy)
      delete :destroy, {:id=> 100}
      expect(flash[:notice]).to eq ("Movie '#{@savedMovie.title}' deleted.")
    end  
  end
  
end
