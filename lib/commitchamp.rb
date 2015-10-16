require "httparty"
require "pry"

require "commitchamp/contributions"
require "commitchamp/version"
# Probably you also want to add a class for talking to github.

module Commitchamp
  class App

    def initialize
      @contributions = Contributions.new
    end

    def run
      @contributions.retrieve_contributions
    end

  end
end

app = Commitchamp::App.new
app.run
