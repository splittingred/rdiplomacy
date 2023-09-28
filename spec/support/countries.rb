# frozen_string_literal: true

module CountryHelpers
  Variants::ConfigurationFactory.new.build('classic').countries.each do |abbr, _|
    define_method("country_#{abbr}") do
      FactoryBot.build(:country, abbr.to_sym)
    end
  end
end

RSpec.configure do |c|
  c.include CountryHelpers, territories: :classic
end
