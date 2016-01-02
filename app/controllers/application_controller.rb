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
    if !(params["path"]["chapter_ids"] == nil)
      path_chapters = params["path"]["chapter_ids"].map{|id| Chapter.find(id)}
      paths = path_chapters.map do |chapter|
        Path.create(name: chapter.name, chapter_id: @chapter.id, next_chapter_id: chapter.id)
      end
      @chapter.paths.concat(paths)
    end
    if params[:path][:chapter_names].find{|name| !name.empty?}
      paths = params[:path][:chapter_names].select{|name| !name.empty?}.map do |name|
        next_chapter = Chapter.create(name: name)
        Path.create(name: next_chapter.name, chapter_id: @chapter.id, next_chapter_id: next_chapter.id)
      end
      @chapter.paths.concat(paths)
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
    old_name = @chapter.name
    @chapter.update(name: params["name"], content: params["content"])
    path = Path.find_by(name: old_name, next_chapter_id: @chapter.id)
    if path
      path.update(name: @chapter.name)
    end
    if !(params["path"]["chapter_ids"] == nil)
      path_chapters = params["path"]["chapter_ids"].map{|id| Chapter.find(id)}
      paths = path_chapters.map do |chapter|
        Path.find_or_create_by(name: chapter.name, chapter_id: @chapter.id, next_chapter_id: chapter.id)
      end
      @chapter.paths.concat(paths)
    end
    if params[:path][:chapter_names].find{|name| !name.empty?}
      paths = params[:path][:chapter_names].select{|name| !name.empty?}.map do |name|
        next_chapter = Chapter.create(name: name)
        Path.create(name: next_chapter.name, chapter_id: @chapter.id, next_chapter_id: next_chapter.id)
      end
      @chapter.paths.concat(paths)
    end
    @chapter.save
    erb :"chapters/show"
  end

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
