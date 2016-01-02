class Chapter < ActiveRecord::Base
  has_many :paths

  def slug
    name.downcase.gsub(/[^0-9a-z ]/i, '').gsub(" ","-")
  end

  def path_names
    self.paths.map do |path|
      path.name
    end
  end

  def self.find_by_slug(slug)
    self.all.find do |chapter|
      chapter.slug == slug
    end
  end
end
