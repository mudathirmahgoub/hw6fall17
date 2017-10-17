
describe Movie do
  before :each do
    @movie1=Tmdb::Movie.new
    @movie1.id= 27205
    @movie1.title="Inception"
    @movie1.release_date="2010-07-14"
    
    @movie2=Tmdb::Movie.new
    @movie2.id= 64956
    @movie2.title="Inception: The Cobol Job"
    @movie2.release_date="2010-12-07"
    
    @movie3=Tmdb::Movie.new
    @movie3.id= 250845
    @movie3.title="WWA The Inception"
    @movie3.release_date="2001-10-26"
    
    @movie4=Tmdb::Movie.new
    @movie4.id= 350632
    @movie4.title="The Inception of Dramatic Representation"
    @movie4.release_date=""
    
    @tmdb_movies = [@movie1, @movie2, @movie3, @movie4]
    
    @movie1_ratings =
     {
        "id"=>27205, 
        "countries"=>
        [
          {"certification"=>"PG-13", 
           "iso_3166_1"=>"US", 
           "primary"=>false, 
           "release_date"=>"2010-07-16"
          }, 
          {"certification"=>"12A", 
           "iso_3166_1"=>"GB", 
           "primary"=>false, 
           "release_date"=>"2010-07-16"
          }
       ]
     }
     
     @movie2_ratings =
     {
        "id"=>64956, 
        "countries"=>
        [
          {"certification"=>"NR", 
           "iso_3166_1"=>"US", 
           "primary"=>false, 
           "release_date"=>"2010-12-07"
          }
       ]
     }
     
     @movie3_ratings =
     {
        "id"=>250845, 
        "countries"=>
        [
          {"certification"=>"", 
           "iso_3166_1"=>"US", 
           "primary"=>false, 
           "release_date"=>"2002-01-06"
          }, 
          {
            "certification"=>"", 
            "iso_3166_1"=>"AU", 
            "primary"=>false, 
            "release_date"=>"2001-10-26"
          }
       ]
     }
     
     @movie4_ratings = {"id"=>350632, "countries"=>[]} 
     
     @generic_rating = 
     {
       "countries"=>
        [
          {
            "certification"=>"G", 
            "iso_3166_1"=>"US", 
            "primary"=>false, 
            "release_date"=>"2002-01-06"
          }
        ]
     }
  end
      
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      
      it 'should call Tmdb with title keywords' do
        expect(Tmdb::Movie).to receive(:find).with('Inception').
        and_return ([])
        Movie.find_in_tmdb('Inception')
      end
      
      it 'should return array of hashes with tmdb information' do
        allow(Tmdb::Movie).to receive(:find).with('Inception').
          and_return (@tmdb_movies)
        
        allow(Tmdb::Movie).to receive(:releases).and_return (@generic_rating)  
          
        result = Movie.find_in_tmdb('Inception')
        expect(result.class).to be (Array)
        expect(result.length).to be @tmdb_movies.length
        result.each_index do |index|
          #assert that each element in the array is a hash
          expect(result[index].class).to be (Hash)
          #assert that hash values are properly set
          expect(result[index][:tmdb_id]).to eq (@tmdb_movies[index].id)
          expect(result[index][:title]).to eq (@tmdb_movies[index].title)
          expect(result[index][:release_date]).to eq (
            @tmdb_movies[index].release_date == ""? nil: 
            Time.parse(@tmdb_movies[index].release_date).
                        in_time_zone('Central Time (US & Canada)').
                        to_date)
          expect(result[index][:rating]).to eq ("G")
        end 
      end
      
      it 'should call Tmdb::Movie.releases and return US rating' do
        allow(Tmdb::Movie).to receive(:find).with('Inception').
          and_return ([@movie1])
        expect(Tmdb::Movie).to receive(:releases).with(@movie1.id).
          and_return (@movie1_ratings)  
        result = Movie.find_in_tmdb('Inception')
        expect(result[0][:rating]).to eq (@movie1_ratings["countries"].
                    select {|c| c["iso_3166_1"]=="US"}[0]["certification"])
      end
      
      it 'should return empty array if no match found in tmdb' do
        allow(Tmdb::Movie).to receive(:find).with('not a movie').
          and_return ([])
        result = Movie.find_in_tmdb('not a movie')
        expect(result.class).to be (Array)
        expect(result.length).to be 0
      end
      
      it 'should return R rating if the US is not in listed countries' do
        allow(Tmdb::Movie).to receive(:find)
            .with('The Inception of Dramatic Representation').
          and_return ([@movie4])
        expect(Tmdb::Movie).to receive(:releases).with(@movie4.id).
          and_return (@movie4_ratings)  
        result = Movie.find_in_tmdb('The Inception of Dramatic Representation')
        expect(result[0][:rating]).to eq ('R')
      end
      
      it 'should return R empty string if the tmdb rating is empty' do
        allow(Tmdb::Movie).to receive(:find)
            .with('WWA The Inception').
          and_return ([@movie3])
        expect(Tmdb::Movie).to receive(:releases).with(@movie3.id).
          and_return (@movie3_ratings)  
        result = Movie.find_in_tmdb('WWA The Inception')
        expect(result[0][:rating]).to eq ("R")
      end
      
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
  end
  
  describe 'adding a tmdb movie' do
    before :each do
      @movie1_detail = { 
      	"title"=>"Inception",
      	"release_date"=>"2010-07-14",
      	"overview"=>"Cobb, a skilled thief who commits corporate espionage ..."
      }
      
      @movie4_detail = {"title"=>"The Inception of Dramatic Representation",
      	"release_date"=>"",
      	"overview"=>"overview"
      }

    end
    
    it 'should call Tmdb details with tmdb id' do
      expect(Tmdb::Movie).to receive(:detail).with(27205).
      and_return (@movie1_detail)
      allow(Tmdb::Movie).to receive(:releases).with(27205).
        and_return (@movie1_ratings) 
      Movie.create_from_tmdb(27205)
    end
    
    it 'should call Tmdb releases with tmdb id' do
      allow(Tmdb::Movie).to receive(:detail).with(27205).
        and_return (@movie1_detail)
      expect(Tmdb::Movie).to receive(:releases).with(27205).
        and_return (@movie1_ratings) 
      Movie.create_from_tmdb(27205)
    end
    
    it 'should add the selected record to the database' do
      allow(Tmdb::Movie).to receive(:detail).with(27205).
        and_return (@movie1_detail)
      allow(Tmdb::Movie).to receive(:releases).with(27205).
        and_return (@movie1_ratings) 
      Movie.create_from_tmdb(27205)
      
      record = Movie.all[0]
      expect(record).not_to be nil
      expect(record.title).to eq (@movie1_detail["title"])
      expect(record.rating).to eq ('PG-13')
      expect(record.release_date).to eq (
            @movie1_detail["release_date"] == ""? nil: 
            Time.parse(@movie1_detail["release_date"]).
                        in_time_zone('Central Time (US & Canada)').
                        to_date)
      expect(record.description).to eq (@movie1_detail["overview"])
    end

    it 'should add tmdb movie with nil date' do
      allow(Tmdb::Movie).to receive(:detail).with(350632).
        and_return (@movie4_detail)
      allow(Tmdb::Movie).to receive(:releases).with(350632).
        and_return (@movie4_ratings) 
      Movie.create_from_tmdb(350632)
      
      record = Movie.all[0]
      expect(record).not_to be nil
      expect(record.title).to eq (@movie4_detail["title"])
      expect(record.rating).to eq ('R')
      expect(record.release_date).to eq (
            @movie4_detail["release_date"] == ""? nil: 
            Time.parse(@movie4_detail["release_date"]).
                        in_time_zone('Central Time (US & Canada)').
                        to_date)
      expect(record.description).to eq (@movie4_detail["overview"])
    end
  end
  
  # for old functions
  describe 'all_ratings' do
    it "should return all ratings" do
      ratings = Movie.all_ratings
      expect(ratings).to eq %w(G PG PG-13 NC-17 R)
    end
  end
end
