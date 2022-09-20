require 'date'
require 'json'

module Utils
  class << self
    BASE_TOPLI_URL = "http://94.130.168.29:8080"

    def get_monday
      date = Date.today
      date - (date.wday - 1) % 7
    end

    # @param [Date] date
    def get_food_offers_for_date(date)
      formatted_date = date.strftime('%d-%m-%Y')
      Faraday.post("#{BASE_TOPLI_URL}/jelo/getMenu", { datumOd: formatted_date, datumDo: formatted_date }.to_json, 'Content-Type' => 'application/json')
    end

    def parse_date_from_text(text)
      text = text.strip.downcase
      case text
      when 'sutra', 'tomorrow'
        Date.today + 1
      when 'monday', 'ponedeljak'
        get_monday
      when 'tuesday', 'utorak'
        get_monday + 1
      when 'wednesday', 'sreda'
        get_monday + 2
      when 'thursday', 'cetvrtak'
        get_monday + 3
      when 'friday', 'petak'
        get_monday + 4
      else
        Date.today
      end
    end

    # @param [Date] date
    def build_blocks_response_from_offers(body, date)
      json_body = JSON.parse(body)
      {
        blocks: [
          {
            type: 'section',
            text: {
              type: 'mrkdwn',
              text: "Offers for date *#{date.strftime('%d-%m-%Y')}*:"
            }
          },
          { type: 'divider' },
          *offers_parsed(json_body)
        ]
      }
    end

    def compute_text_for_offer(offer)
      price_large = offer['cenaVelika']
      price_normal = offer['cenaNormal']
      day_before_ordering = offer['danRanije']
      name = offer['naziv']
      description = offer['opis']
      ret = ''
      ret += "*#{name}*\n"
      if description
        ret += "#{description}\n"
      end
      ret += "Price for normal portion: #{price_normal} RSD\n"
      if price_large && price_large > 0
        ret += "Price for large portion: #{price_large} RSD\n"
      end
      if day_before_ordering
        ret += '*Only if ordered day before!*'
      end
      ret
    end

    def offers_parsed(body)
      body.map do |offer|
        { type: 'section', text: {
          type: 'mrkdwn',
          text: compute_text_for_offer(offer)
        } }
      end
    end
  end
end
