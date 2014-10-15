require 'capybara'
require 'capybara/poltergeist'

class EServices
  BASE_URL = 'https://www.rit.edu/eservices/'

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, phantomjs_logger: File.open(File::NULL, 'w'))
  end

  Capybara.default_driver = :poltergeist

  def initialize(username:, password:)
    @username = username
    @password = password
  end

  def debit_balance
    require 'eservices/dining_accounts/debit'

    DiningAccounts::Debit.new.call(username: username, password: password)
  end

  private

  attr_reader :username, :password
end
