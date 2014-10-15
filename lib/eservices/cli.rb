require 'dotenv'

Dotenv.load!

require 'eservices'

class EServices
  class CLI
    def call(service:)
      case service
      when 'debit' then report_debit
      end
    end

    private

    def report_debit
      require 'eservices/cli/reports/report_debit'

      Reports::ReportDebit.new(
        **EServices.new(
          username: ENV['RIT_USERNAME'],
          password: ENV['RIT_PASSWORD'],
        ).debit_balance
      ).call
    end
  end
end
