class Movie < ActiveRecord::Base
  
  @@key = "f4702b08c0ac6ea5b51425788bb26562"
  
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
 
  def self.find_in_tmdb(string)
    begin
    # initialize the key
    Tmdb::Api.key(@@key)
    # search the tmdb 
    result = Tmdb::Movie.find(string)
    
    # return array of hashes
    result.collect do |movie|
      
      rating = get_tmdb_rating movie.id
      # map each movie in the collection to a hash
      {
        :tmdb_id=>movie.id,
        :title=> movie.title,
        :release_date=> (Time .parse(movie.release_date)
                              .in_time_zone('Central Time (US & Canada)')
                              .to_date rescue nil),
        :rating => rating
      }
    end
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end

  def self.create_from_tmdb tmdb_id
    # initialize the key
    Tmdb::Api.key(@@key)
    # get the details from tmdb
    result = Tmdb::Movie.detail(tmdb_id)
    # get the rating from tmdb
    rating = get_tmdb_rating tmdb_id
    
    #define a new movie object
    movie = {
              :title => result["title"], 
              :rating => rating, 
              :release_date => (Time.parse(result["release_date"])
                              .in_time_zone('Central Time (US & Canada)')
                              .to_date rescue nil),
              :description => result["overview"]
            }
    # persist the new movie in the database
    Movie.create(movie)
  end
  
  def self.get_tmdb_rating tmdb_id
      # get the result from tmdb 
      ratingResult = Tmdb::Movie.releases(tmdb_id)["countries"].
                    select {|c| c["iso_3166_1"]=="US"}
      
      # the default rating is 'R'
      rating = 'R'
      # if there is rating in the US
      if ratingResult.length == 1 && ratingResult[0]["certification"] != ''
        # get the US rating
          rating = ratingResult[0]["certification"]
      end
      return rating
  end
end
