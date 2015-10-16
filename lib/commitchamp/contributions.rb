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
      puts "Which repository?: "
      @repo = gets.chomp
    end

    def retrieve_contributions
      self.user_input
      @contributions = Contributions.get("/repos/#{@org}/#{@repo}/stats/contributors", 
                         :headers => @auth)
      self.collect_data
      self.sort_data
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
        @data.push({l: author, a: a, d: d, c: c})
      end
      @data
    end
   
    def sort_data
      puts "How would you like to sort contributors?: "
      puts "Lines (a)dded"
      puts "Lines (d)eleted"
      puts "(c)ommits made"
      input = gets.chomp.downcase
      until ["a", "d", "c"].include?(input)
        puts "Please provide a valid entry."
        puts "(a)dded, (d)eleted, or (c)ommits"
        input = gets.chomp.downcase
      end
      @sorted_data = @data.sort_by do |hash|
        hash[input.to_sym]
        end
      @sorted_data.reverse!
      binding.pry
    end

    def display_data
      printf("%-20s %-10s %-10s %-10s\n", "Username ", "Additions ", "Deletions ", "Commits")
      @sorted_data.each do |entry|
        printf("%-20s %-10s %-10s %-10s\n", "#{entry[:l]}", "#{entry[:a]}", "#{entry[:d]}", "#{entry[:c]}")
      end
    end

    


  end
end

