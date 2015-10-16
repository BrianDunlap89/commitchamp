module Commitchamp
  class Contributions
      include HTTParty
      base_uri "https://api.github.com"

    def initialize
      puts "Please provide an authentication token to proceed: "
      auth_token = gets.chomp
      @auth = {
        "Authorization" => "token #{auth_token}",
        "User-Agent"    => "HTTParty"
      }
    end

    def user_input
      puts "Which organization's data would you like to access?: "
      @org = gets.chomp
      puts "Which repository's?: "
      @repo = gets.chomp
    end

    def retrieve_contributions
      self.user_input
      @contributions = Contributions.get("/repos/#{@org}/#{@repo}/stats/contributors", 
                         :headers => @auth)
      self.collect_data
      self.display_data
    end

    def collect_data
      @data = []
      @contributions.map do |contribution|
        author = contribution["author"]["login"]
        weeks = contribution["weeks"]
        a = 0
        d = 0
        c = 0
        weeks.map do |week|
          a += week["a"]
          d += week["d"]
          c += week["c"]
        end
        @data.push([author, a, d, c])
      end
      @data
    end
   
    def display_data
      sprintf("%13s %5s %5s %5s, Username, Additions, Deletions, Changes")
      @data.each do |entry|
        sprintf("%13s %5s %5s %5s, #{entry[0]}, #{entry[1]}, #{entry[2]}, #{entry[3]}")
      end
    end

  end
end

