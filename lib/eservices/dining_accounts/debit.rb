require 'capybara'
require 'active_support/time'

class EServices
  module DiningAccounts
    class Debit
      include Capybara::DSL

      FOOD_DEBIT_END_DATE = Date.new(2014, 12, 18)

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
        (food_debit_end_date - Date.tomorrow).to_i
      end

      def food_debit_end_date
        FOOD_DEBIT_END_DATE
      end
    end
  end
end
