# Completed step definitions for basic features: AddMovie, ViewDetails, EditMovie 

Given /^I am on the RottenPotatoes home page$/ do
  visit movies_path
 end


 When /^I have added a movie with title "(.*?)" and rating "(.*?)"$/ do |title, rating|
  visit new_movie_path
  fill_in 'Title', :with => title
  select rating, :from => 'Rating'
  click_button 'Save Changes'
 end

 Then /^I should see a movie list entry with title "(.*?)" and rating "(.*?)"$/ do |title, rating| 
   result=false
   all("tr").each do |tr|
     if tr.has_content?(title) && tr.has_content?(rating)
       result = true
       break
     end
   end  
  expect(result).to be_truthy
 end

 When /^I have visited the Details about "(.*?)" page$/ do |title|
   visit movies_path
   click_on "More about #{title}"
 end

 Then /^(?:|I )should see "([^"]*)"$/ do |text|
    expect(page).to have_content(text)
 end

 When /^I have edited the movie "(.*?)" to change the rating to "(.*?)"$/ do |movie, rating|
  click_on "Edit"
  select rating, :from => 'Rating'
  click_button 'Update Movie Info'
 end


# New step definitions to be completed for HW5. 
# Note that you may need to add additional step definitions beyond these


# Add a declarative step here for populating the DB with movies.

Given /the following movies have been added to RottenPotatoes:/ do |movies_table|
  # Remove this statement when you finish implementing the test step
  movies_table.hashes.each do |movie|
    # Each returned movie will be a hash representing one row of the movies_table
    # The keys will be the table headers and the values will be the row contents.
    # Entries can be directly to the database with ActiveRecord methods
    # Add the necessary Active Record call(s) to populate the database.
    Movie.create!(movie)
   end
end

When /^I have opted to see movies rated: "(.*?)"$/ do |arg1|
  # HINT: use String#split to split up the rating_list, then
  # iterate over the ratings and check/uncheck the ratings
  # using the appropriate Capybara command(s)
  #remove this statement after implementing the test step
  
  ratings = arg1.gsub(/\s/, '').split(',')
  
  all('input[type=checkbox]').each do |ratingCheckbox|
    rating = ratingCheckbox[:name].match(/\[(?<rating>.*)]/i)['rating']
    if ratings.include? rating
       check("ratings[#{rating}]")
   else
        uncheck("ratings[#{rating}]")
    end
  end
  
  click_button();
end

Then /^I should see only movies rated: "(.*?)"$/ do |arg1|
   #remove this statement after implementing the test step
   
   ratings = arg1.gsub(/\s/, '').split(',')
   result=true
   page.find('tbody').all("tr").each do |tr|
    rating = tr.all("td")[1].text
    if !ratings.include? rating
        result = false
        break;
    end
   end  
  expect(result).to be_truthy
end

Then /^I should see all of the movies$/ do
  #remove this statement after implementing the test step
  movies = Movie.all
  
  rows = page.find('tbody').all("tr");
  
  rows.length.should eq(movies.length)
  # each movie should be in a row
  movies.each do |m| 
    found = false
    rows.each do |row|
        if row.all("td")[0].text == m[:title] &&
           row.all("td")[1].text == m[:rating] &&
           row.all("td")[2].text == m[:release_date].to_s
            found = true
        end
    end
    expect(found).to be_truthy
  end
end


# new step definitions 

When /^I have chosen to see movies sorted by title alphabetically$/ do
  click_link('title_header')
end

Then /^I should see "(.*?)" before "(.*?)"$/ do |title1, title2|

   movies = page.find('tbody').all("tr")
            .map.with_index { |r, i| [r.all("td")[0].text,i]}
            .to_h
   # index of title1 < index of title2
   expect(movies[title1]).to be < movies[title2]
end

When /^I have chosen to see movies sorted by release date in increasing order$/ do
  click_link('release_date_header')
end


Then /^I should see movies ordered by title$/ do

   movies = page.find('tbody').all("tr")
            .map{ |r| r.all("td")[0].text}
            .to_a
    sorted_movies = movies.sort  
   # index of title1 < index of title2
   expect(movies).to  match_array(sorted_movies) 
end

Then /^I should see movies ordered by release date in increasing order$/ do

   movies = page.find('tbody').all("tr")
            .map{ |r| r.all("td")[2].text}
            .to_a
    sorted_movies = movies.sort  
   # index of title1 < index of title2
   expect(movies).to  match_array(sorted_movies) 
end

When(/^I search for movies whose title contains "([^"]*)"$/) do |title|
  
  fill_in 'Title', :with => title
  click_button 'Search TMDb'
end

