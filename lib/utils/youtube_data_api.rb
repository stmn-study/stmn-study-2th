require 'rubygems'
require 'google/api_client'
require 'trollop'

class YoutubeDataApi
  DEVELOPER_KEY = Rails.application.secrets.youtube_data_api_key
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
    # ex) response_sample
    #
    #  {
    #   "kind": "youtube#searchListResponse",
    #   "etag": "\"IHLB7Mi__JPvvG2zLQWAg8l36UU/B7HTIgYFvqFP1W51kJxRs_VPTEs\"",
    #   "pageInfo": {
    #   "totalResults": 2,
    #   "resultsPerPage": 5
    #  },
    #   "items": [
    #   {
    #     "kind": "youtube#searchResult",
    #     "etag": "\"IHLB7Mi__JPvvG2zLQWAg8l36UU/9Q6jCT_HeHFfR4LxWgkefRtExOk\"",
    #     "id": {
    #       "kind": "youtube#video",
    #       "videoId": "J9VsVp7n6mg"
    #     },
    #     "snippet": {
    #       "publishedAt": "2009-08-05T10:45:24.000Z",
    #       "channelId": "UCnUSZE-pn6_g2DQu_d78fyw",
    #       "title": "ミニチュア風動画 - 福岡市中央区赤坂",
    #       "description": "http://akihiro.jugem.jp/?eid=259.",
    #       "thumbnails": {
    #         "default": {
    #           "url": "https://i.ytimg.com/vi/J9VsVp7n6mg/default.jpg"
    #         },
    #         "medium": {
    #           "url": "https://i.ytimg.com/vi/J9VsVp7n6mg/mqdefault.jpg"
    #         },
    #         "high": {
    #           "url": "https://i.ytimg.com/vi/J9VsVp7n6mg/hqdefault.jpg"
    #         }
    #       },
    #       "channelTitle": "1977akihiro",
    #       "liveBroadcastContent": "none"
    #     }
    #    }
    #   }
    #

    def search_param_keys
      [
        :part,
        :q,
        :max_results
      ]
    end

    def search(params = {})
      params = {q: nil, max_results: 25}.merge(params.symbolize_keys)

      opts = Trollop::options do
        opt :q, 'Search term', :type => String, :default => params[:q]
        opt :max_results, 'Max results', :type => :int, :default => params[:max_results]
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
            when 'youtube#video'
              videos << "#{search_result.snippet.title} (#{search_result.id.videoId})"
            when 'youtube#channel'
              channels << "#{search_result.snippet.title} (#{search_result.id.channelId})"
            when 'youtube#playlist'
              playlists << "#{search_result.snippet.title} (#{search_result.id.playlistId})"
          end
        end

        results = {videos: videos}
        results
      rescue Google::APIClient::TransmissionError => e
        logger.debug(e.message)
      end
    end
  end
end