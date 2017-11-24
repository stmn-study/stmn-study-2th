class HomeController < ApplicationController
  def index
    params[:q] ||= '組織エンゲージメントクラウド TUNAG'
    @results = YoutubeDataApi.search(q: params[:q], max_results: 25)
    @video_id = @results.first[:video_id]

    if params[:video_id]
      @video_id = params[:video_id]
    end
  end
end
