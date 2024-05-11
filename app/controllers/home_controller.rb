class HomeController < ApplicationController
  include HTTParty

  def index
    begin
      response = HTTParty.post('https://voice-ai.herokuapp.com/getDatabaseVoicesWithCustom', headers: {
        'Content-Type' => 'application/json',
        'Host' => 'voice-ai.herokuapp.com',
        'User-Agent' => 'VoiceAI/2.0',
        'Accept-Language' => 'ar-SA;q=1.0, en-SA;q=0.9',
        'Accept-Encoding' => 'br;q=1.0, gzip;q=0.9, deflate;q=0.8'
      }, body: { user_id: 'HQwQc50V' }.to_json)

      if response.code == 200
        @speakers = response.parsed_response['data']
      else
        raise "API request failed with status code: #{response.code}"
      end
    rescue => e
      flash[:alert] = "Failed to fetch speakers data: #{e.message}"
      @speakers = []
    end
  end

  def speakers
    render :speakers
  end

  def show
    @speaker = Speaker.find(params[:id])
    @text = @speaker.text
    @mp3_url, @mp4_url = send_voice_request(speaker_id: @speaker.id, text: @speaker.text)
    if error.present?
      flash[:alert] = error
      render and return
    end
  end

  def generate_speech
    speaker_id = params[:speaker_id]
    text = params[:text]
    character_limit = 500
  
    if text.length <= character_limit
      mp3_url, mp4_url, error = send_voice_request(speaker_id: speaker_id, text: text)
      
      puts mp3_url
      puts mp4_url
      
      if error.present?
        render json: { error: error }, status: :unprocessable_entity
      else
        render json: { mp3_url: mp3_url, mp4_url: mp4_url }
      end
    else
      error_message = "Exceeded the maximum allowed characters limit of #{character_limit}."
      render json: { error: error_message }, status: :unprocessable_entity
    end
  end



  private

  def send_voice_request(speaker_id:, text:)
    voice_api_url = "https://voice-ai.herokuapp.com/generateVoice"
    headers = {
      'Content-Type' => 'application/json',
      'Host' => 'voice-ai.herokuapp.com',
      'User-Agent' => 'VoiceAI/2.0',
      'Accept-Language' => 'ar-SA;q=1.0, en-SA;q=0.9',
      'Accept-Encoding' => 'br;q=1.0, gzip;q=0.9, deflate;q=0.8'
    }

    body = {
      "speaker_id" => speaker_id,
      "text" => text,
      "isSubbed" => true,
      "user_id" => "j7qR2Vhg",
      "version" => 2
    }.to_json

    response = HTTParty.post(voice_api_url, headers: headers, body: body)

    if response.code == 200
      data = response.parsed_response
      mp3_url = data["data"]
      mp4_url = data["video_url"]
      return mp3_url, mp4_url
    else
      error_message = "Error: Received response code #{response.code}, not successfully generated speech."
      return nil, nil, error_message
    end
  rescue StandardError => e
    return nil, nil, "Error: #{e.message}"
  end
end