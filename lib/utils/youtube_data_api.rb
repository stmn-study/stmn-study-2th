require 'google/api_client'
require 'trollop'

class YoutubeDataApi
  DEVELOPER_KEY = 'REPLACE_ME'
  YOUTUBE_API_SERVICE_NAME = 'youtube'
  YOUTUBE_API_VERSION = 'v3'

  class << self
    def get_service
      client = Google::APIClient.new(
        :key => DEVELOPER_KEY,
        :authorization => nil,
        :application_name => $PROGRAM_NAME,
        :application_version => '1.0.0'
      )
      youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

      return client, youtube
    end

    # Keyword_Search
    def search_param_keys
      [
        :part,
        :q,
        :max_results
      ]
    end

    def search(params = {})
      opts = Trollop::options do
        opt :q, 'Search term', :type => String, :default => 'Google'
        opt :max_results, 'Max results', :type => :int, :default => 25
      end

      client, youtube = get_service

      begin
        search_response = client.execute!(
          :api_method => youtube.search.list,
          :parameters => {
            :part => 'snippet',
            :q => opts[:q],
            :maxResults => opts[:max_results]
          }
        )

        videos = []
        channels = []
        playlists = []

        search_response.data.items.each do |search_result|
          case search_result.id.kind

          end
        end

      rescue Google::APIClient::TransmissionError => e
        logger.debug(e.message)
      end
    end
  end
end