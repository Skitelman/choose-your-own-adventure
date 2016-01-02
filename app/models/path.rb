class Path < ActiveRecord::Base
  belongs_to :chapter

  def slug
    name.downcase.gsub(/[^0-9a-z ]/i, '').gsub(" ","-")
  end

  def self.find_by_slug(slug)
    self.all.find do |path|
      path.slug == slug
    end
  end
end
