#!/usr/bin/env ruby

require 'capybara'
require 'capybara/poltergeist'
require 'active_support/time'
require 'cape-cod'
require 'dotenv'

Dotenv.load!

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_logger: File.open(File::NULL, 'w'))
end

Capybara.default_driver = :poltergeist

class EServices
  include Capybara::DSL

  BASE_URL = 'https://www.rit.edu/eservices/'

  MEAL_PLAN_END_DATE = Date.new(2014, 12, 18)

  def call(username:, password:)
    auth(username, password)

    visit BASE_URL

    login

    { total: debit_balance, remaining_days: remaining_days }
  end

  private

  def debit_balance
    sleep 1
    find('td', text: /Food/).parent.all('td')[15].text[1..-1].to_f
  end

  def login
    click_link 'Login to eServices'
  end

  def auth(name, password)
    if page.driver.respond_to?(:basic_auth)
      page.driver.basic_auth(name, password)
    elsif page.driver.respond_to?(:basic_authorize)
      page.driver.basic_authorize(name, password)
    elsif page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:basic_authorize)
      page.driver.browser.basic_authorize(name, password)
    else
      raise "I don't know how to log in!"
    end
  end

  def remaining_days
    (meal_plan_end_date - Date.tomorrow).to_i
  end

  def meal_plan_end_date
    MEAL_PLAN_END_DATE
  end
end

class ReportBalance
  def call(total:, remaining_days:)
    puts CapeCod.blue "TOTAL BALANCE: #{ total }"
    puts CapeCod.magenta "REMAINING DAYS: #{ remaining_days }"

    daily = daily_balance(total, remaining_days)

    color = daily < 18 ? :red : :green

    puts CapeCod.public_send(color, daily)
  end

  private

  def daily_balance(total, remaining_days)
    total / remaining_days
  end
end

ReportBalance.new.call(
  **EServices.new.call(username: ENV['RIT_USERNAME'], password: ENV['RIT_PASSWORD']))
