require_relative '../utils'

SlackRubyBotServer::Events.configure do |config|
  def topli_command(command, is_public = false)
    text = command[:text]
    parsed_date = Utils.parse_date_from_text(text)
    offers = Utils.get_food_offers_for_date(parsed_date)
    if offers.status != 200
      { text: 'Unable to fetch offers' }.tap do |hash|
        if is_public
          hash.merge!({ response_type: 'in_channel' })
        end
      end
    else
      Utils.build_blocks_response_from_offers(offers.body, parsed_date).tap do |hash|
        if is_public
          hash.merge!({ response_type: 'in_channel' })
        end
      end
    end
  end

  config.on :command, '/topli' do |command|
    topli_command(command, false)
  end

  config.on :command, '/pub_topli' do |command|
    topli_command(command, true)
  end
end
