class ApplicationController < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :session_secret, "my_application_secret"
  set :views, Proc.new { File.join(root, "../views/") }

  get '/' do
    @chapter1 = Chapter.first
    erb :index
  end

  get '/chapters' do
    erb :"chapters/index"
  end

  get '/chapters/new' do
    erb :"chapters/new"
  end

  post '/chapters' do
    @chapter = Chapter.create(name: params["name"], content: params["content"])
    params[:path].each do |path_hash|
      if path_hash[:name] != ""
        path = Path.create(name: path_hash[:name], chapter_id: @chapter.id)
        if path_hash[:chapter_id]
          path.update(next_chapter_id: path_hash[:chapter_id])
        else
          next_chapter = Chapter.create(name: path_hash[:chapter_name])
          path.update(next_chapter_id: next_chapter.id)
        end
        @chapter.paths << path
      end
    end
    @chapter.save
    erb :"chapters/show"
  end

  get '/chapters/:id' do
    @chapter = Chapter.find(params[:id])
    erb :"chapters/show"
  end

  get '/chapters/:id/edit' do
    @chapter = Chapter.find(params[:id])
    erb :"chapters/edit"
  end

  post '/chapters/:id' do
    @chapter = Chapter.find(params[:id])
    @chapter.paths.clear
    @chapter.update(name: params["name"], content: params["content"])
    params[:path].each do |path_hash|
      if path_hash[:name] != ""
        path = Path.find_or_create_by(name: path_hash[:name], chapter_id: @chapter.id)
        if path_hash[:chapter_id]
          path.update(next_chapter_id: path_hash[:chapter_id])
        else
          next_chapter = Chapter.create(name: path_hash[:chapter_name])
          path.update(next_chapter_id: next_chapter.id)
        end
        @chapter.paths << path
      end
    end
    @chapter.save
    erb :"chapters/show"
  end

  # get '/chapters/:id/edit_paths' do
  #   @chapter = Chapter.find(params[:id])
  #   erb :"chapters/edit_paths"
  # end

  get '/chapters/:id/delete' do
    @chapter = Chapter.find(params[:id])
    erb :"chapters/delete"
  end

  post '/chapters/:id/delete' do
    @chapter = Chapter.find(params[:id])
    if !(@chapter.paths.empty?)
      @chapter.paths.each do |path|
        path.destroy
      end
    end
    @chapter.destroy
    redirect to "/chapters"
  end
end
