class PostsController < ApplicationController
  def index
    @posts = current_user.posts
    @youtube = Google::Apis::YoutubeV3::YouTubeService.new
    @youtube.key = Rails.application.credentials.google[:api_key]
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)
    url = params[:post][:youtube_url]
    url = url.last(11)
    @post.youtube_url = url
    tag_list = params[:post][:tagname].split(',') 
    
    if @post.save
      @post.save_tag(tag_list)
      redirect_to posts_path, success: '動画を保存しました'
    else
      render :new
    end
  end
  

  def show
    @post = current_user.posts.find(params[:id])
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = Rails.application.credentials.google[:api_key]
    @post_tags = @post.tags 

    options = {
      # urlのラスト11字
      id: @post.youtube_url
    }
    @response = youtube.list_videos("snippet", options)
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(post_params)
      redirect_to posts_path, success: '更新しました'
    else
      flash.now[:danger] = '更新失敗しました'
      render :edit
    end
  end

  def destroy 
    @post = current_user.posts.find(params[:id])
    @post.delete
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:title, :body)
  end
  
end