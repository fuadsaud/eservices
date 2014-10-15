require 'cape-cod'

class EServices
  class CLI
    module Reports
      class ReportDebit
        def initialize(total:, remaining_days:)
          @total = total
          @remaining_days = remaining_days
        end

        def call
          puts total_report
          puts remaining_days_report
          puts daily_balance_report
        end

        private

        attr_reader :total, :remaining_days

        def total_report
          CapeCod.blue "TOTAL BALANCE: $#{ total }"
        end

        def remaining_days_report
          CapeCod.magenta "REMAINING DAYS: #{ remaining_days }"
        end

        def daily_balance_report
          CapeCod.public_send(daily_balance_color, daily_balance_string)
        end

        def daily_balance_string
          format '$%.2f', daily_balance
        end

        def daily_balance
          total / remaining_days
        end

        def daily_balance_color
          if daily_balance >= 18
            :green
          else
            :red
          end
        end
      end
    end
  end
end
