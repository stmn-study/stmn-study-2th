class HomeController < ApplicationController
  def index
    params[:video_id] ||= "4JkIs37a2JE"
    @video = params[:video_id]
    @results = YoutubeDataApi.search(q: params[:q], max_results: 25)
  end
end
