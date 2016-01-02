class ApplicationController < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :session_secret, "my_application_secret"
  set :views, Proc.new { File.join(root, "../views/") }

  get '/' do
    @chapter1 = Chapter.first
    erb :index
  end

  get '/chapters' do
    @chapters = Chapter.all
    erb :"chapters/index"
  end

  get '/chapters/new' do
    erb :"chapters/new"
  end

  post '/chapters' do
    @chapter = Chapter.create(name: params["name"], content: params["content"])
    if !(params["path"]["chapter_ids"].empty?)
      path_chapters = params["path"]["chapter_ids"].map{|id| Chapter.find(id)}
      paths = path_chapters.map do |chapter|
        Path.create(name: chapter.name, chapter_id: @chapter.id, next_chapter_id: chapter.id)
      end
      @chapter.paths.concat(paths)
    end
    if !(params[:path][:chapter_name].empty?)
      next_chapter = Chapter.create(name: params[:path][:chapter_name])
      path = Path.create(name: next_chapter.name, chapter_id: @chapter.id, next_chapter_id: next_chapter.id)
      @chapter.paths << path
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
    @chapter.update(name: params["name"], content: params["content"])
    if !(params["path"]["chapter_ids"].empty?)
      path_chapters = params["path"]["chapter_ids"].map{|id| Chapter.find(id)}
      paths = path_chapters.map do |chapter|
        Path.find_or_create_by(name: chapter.name, chapter_id: @chapter.id, next_chapter_id: chapter.id)
      end
      @chapter.paths.concat(paths)
    end
    if !(params[:path][:chapter_name].empty?)
      next_chapter = Chapter.create(name: params[:path][:chapter_name])
      path = Path.create(name: next_chapter.name, chapter_id: @chapter.id, next_chapter_id: next_chapter.id)
      @chapter.paths << path
    end
    @chapter.save
    erb :"chapters/show"
  end
end
