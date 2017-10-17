Feature: Allow RottenPotatoes user to search TMDB Movies

Scenario:  Search TMDB movies using with a search title
  Given I am on the RottenPotatoes home page
  When I search for movies whose title contains "Lethal Weapon"
  Then I should see a movie list entry with title "Lethal Weapon" and rating "R"
  And I should see a movie list entry with title "Lethal Weapon4" and rating "R"
  And I should see a movie list entry with title "Lethal Weapon2" and rating "R"
  And I should see a movie list entry with title "Lethal Weapon3" and rating "R"
  
