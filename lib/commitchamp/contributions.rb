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
      @org_true = nil #Indicates whether or not a search spans an entire organization
      @data = []
      @duplicates = []
    end

    def user_input
      puts "Would you like to get information from an individual user or organization? (u/o)"
      response = gets.chomp.downcase
      until ["u", "o"].include?(response)
        puts "Please answer with either (u)ser or (o)rganization: "
      end
      if response == "u"
        puts "Which user's data would you like to access?"
        @owner = gets.chomp
        puts "Which repository?"
        @repo = gets.chomp
      else
        puts "Which organization's data would you like to access?"
        @org = gets.chomp
        @org_true = true
      end
    end

    def retrieve_org_repositories
      org_repositories = Contributions.get("/orgs/#{@org}/repos",
                                           :header => @auth)
        org_repositories.map do |repo|
          @owner = repo["owner"]["login"]
          @repo = repo["name"]
          self.collect_data
        end
          self.sort_data
          self.display_data
    end

    def retrieve_contributions
      self.user_input
      if @org_true == true
        self.retrieve_org_repositories
      else
        self.collect_data
        self.sort_data
        self.display_data
      end
    end

    def collect_data
      contributions = Contributions.get("/repos/#{@owner}/#{@repo}/stats/contributors", 
                                         :headers => @auth)
      contributions.map do |contribution|
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
        @data.push({l: author, a: a, d: d, c: c}) #login (name), adds, deletes, commits

        ## Working on consolidating duplicates, so far non-functional

        # key = :l
        # value = :l[author]
        # @duplicates.push(@data.select {|hash| hash.key?(key) && hash[key] == value })
        # binding.pry
        # # unless @duplicates.empty?
        # #   @duplicates.each_with_object({}) do |k, v| 
        # #     v.merge!(k) { |k, val1, val2| k == key ? val1 : (val1 + val2) }
        #   # end
        # # end
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
    end

    def display_data
      printf("%-20s %-10s %-10s %-10s\n", "Username ", "Additions ", "Deletions ", "Commits")
      @sorted_data.each do |entry|
        printf("%-20s %-10s %-10s %-10s\n", "#{entry[:l]}", "#{entry[:a]}", "#{entry[:d]}", "#{entry[:c]}")
      end
    end
  end
end

