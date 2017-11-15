class HomeController < ApplicationController
  def index
    search_params = {}
    search_params.merge!(q:params[:q], max_results:25)

    if search_params.present?
      @results = YoutubeDataApi.search(search_params)
    end
  end
end
