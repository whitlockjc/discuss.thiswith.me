###
# Blog settings
###

###
# Timezone
###
Time.zone = "Mountain Time (US & Canada)"

###
# Blog Module
###

activate :blog do |blog|
  blog.layout = "article_page"
  blog.sources = "posts/:year-:month-:day-:title.html"
  # Template files
  blog.tag_template = "templates/tag.html"
  blog.calendar_template = "templates/calendar.html"
end

###
# Individual Pages
###
site_pages = [
  {"path" => "/index.html", "layout" => "scaffolding"},
  {"path" => "/tags/index.html", "layout" => "scaffolding"},
  {"path" => "/archives/index.html", "layout" => "scaffolding"},
  {"path" => "/about-me/index.html", "layout" => "scaffolding"},
  {"path" => "/feed.xml", "layout" => false},
  {"path" => "/sitemap.xml", "layout" => false}
]

site_pages.each do |page_config|
  page page_config["path"], :layout => page_config["layout"]
end

set :site_pages, site_pages

###
# Syntax Highlighting
###
activate :syntax

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

###
# Pretty URLs
###
activate :directory_indexes

###
# Asset Locations
###
set :css_dir, 'css'
set :js_dir, 'js'
set :images_dir, 'img'

###
# Template Variables
###
set :site_root, 'http://localhost:4567'

###
# Custom Helpers
###
helpers do
  # Update this, and/or expand it, to do YYYY, YYYY/MM and YYYY/MM/DD variants
  def articles_by_year
    articles_by_year = Hash.new()
    blog.articles.each do |article|
      year = article.date.year
      if !articles_by_year.has_key?(year)
        articles_by_year[year] = []
      end
      articles_by_year[year] = articles_by_year[year].push(article)
    end
    return articles_by_year
  end
  def get_site_pages
    return site_pages
  end
  def w3c_date(date)
    date.strftime("%Y-%m-%dT%H:%M:%S%:z")
  end
end

configure :build do
  # Build-specific configuration
  set :site_root, 'http://thoughtspark.org'
  # Build directory
  set :build_dir, '.'
end
