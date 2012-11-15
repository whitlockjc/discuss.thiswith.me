xml.instruct!
xml.urlset 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  # Site Pages
  site_pages.each do |site_page|
    if site_page['path'].end_with?('/index.html')
      xml.url do
        xml.loc site_root + site_page['path'].gsub('index.html', '')
        xml.changefreq 'weekly'
        xml.priority 1.0
        xml.lastmod w3c_date(DateTime.now)
      end
    end
  end
  # Archives
  articles_by_year.each do |year, articles|
    xml.url do
      xml.loc site_root + '/' + year.to_s(10) + '/'
      xml.changefreq 'weekly'
      xml.priority 1.0
      xml.lastmod w3c_date(DateTime.now)
    end
  end
  # Tags
  blog.tags.each do |tag, articles|
    xml.url do
      xml.loc site_root + '/tags/' + tag + '/'
      xml.changefreq 'weekly'
      xml.priority 1.0
      xml.lastmod w3c_date(DateTime.now)
    end
  end
  # Blog pages
  blog.articles.each do |article|
    xml.url do
      xml.loc site_root + article.url
      xml.changefreq 'never'
      xml.priority 1.0
      xml.lastmod w3c_date(DateTime.parse(article.date.to_s))
    end
  end
end