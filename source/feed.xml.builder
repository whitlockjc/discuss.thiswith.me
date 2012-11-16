xml.instruct!
xml.instruct! 'xml-stylesheet', {:href => absolute_url('/feed.xsl'), :type=>'text/xsl'}
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title "ThoughtSpark.org"
  xml.subtitle "The blog of Jeremy Whitlock."
  xml.id "http://www.thoughtspark.org"
  xml.link "href" => absolute_url("/")
  xml.link "href" => absolute_url("/feed.xml"), "rel" => "self"
  xml.updated blog.articles.first.date.to_time.iso8601
  xml.author { xml.name "Jeremy Whitlock" }

  blog.articles.each do |article|
    xml.entry do
      xml.title article.title
      xml.link "rel" => "alternate", "href" => absolute_url(article.url)
      xml.id absolute_url(article.url)
      xml.published article.date.to_time.iso8601
      xml.updated article.date.to_time.iso8601
      xml.author { xml.name "Jeremy Whitlock" }
      xml.summary article.summary, "type" => "html"
      xml.content article.body, "type" => "html"
    end
  end
end