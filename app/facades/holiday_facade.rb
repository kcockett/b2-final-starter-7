require 'httparty'

class HolidayFacade
  BASE_URL = 'https://date.nager.at/api/v3/NextPublicHolidays/us'

  def self.next_public_holidays
    response = fetch_holidays
    parse_holidays(response)
  end

  def self.fetch_holidays
    response = HTTParty.get(BASE_URL)
    response.parsed_response
  end

  def self.parse_holidays(response)
    response.first(3).map do |holiday_data|
      {
        name: holiday_data['localName'],
        date: holiday_data['date']
      }
    end
  end
end
