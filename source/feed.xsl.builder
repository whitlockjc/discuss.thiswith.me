xml.instruct!
xml.xsl :stylesheet,
        "xmlns:xsl" => "http://www.w3.org/1999/XSL/Transform",
        "xmlns:atom" => "http://www.w3.org/2005/Atom",
        "version" => "1.0" do
  xml.xsl :output, "method" => "html", "omit-xml-declaration" => "yes", "encoding" => "ISO-8859-1"
  xml.xsl :template, "match" => "/" do
    xml.xsl :text, "disable-output-escaping" => "yes" do
      xml.text! "<!DOCTYPE html>"
    end
    xml.html "xmlns" => "http://www.w3.org/1999/xhtml", "lang" => "en" do
      xml.head do
        xml.meta "charset" => "utf-8"
        xml.title do
          xml.text! "ThoughtSpark.org - Feed"
        end
        xml.meta "name" => "viewport", "content" => "width=device-width, initial-scale=1.0"
        xml.meta "name" => "description", "content" => "Interesting stuff from the eyes of Jeremy Whitlock"
        xml.meta "name" => "author", "content" => "Jeremy Whitlock <jcscoobyrs@gmail.com>"

        xml.comment! "Stylesheets"
        xml.link "href" => absolute_url('/css/bootstrap.css'), "rel" => "stylesheet"
        xml.link "href" => absolute_url('/css/thoughtspark.org.css'), "rel" => "stylesheet"
        xml.link "href" => absolute_url('/css/bootstrap-responsive.css'), "rel" => "stylesheet"
      end
      xml.body do
        xml.div "id" => "wrapper" do
          xml.div "class" => "navbar navbar-inverse navbar-fixed-top" do
            xml.div "class" => "navbar-inner" do
              xml.div "class" => "container-fluid" do
                xml.a "class" => "btn btn-navbar", "data-toggle" => "collapse", "data-target" => ".nav-collapse" do
                  xml.span "class" => "icon-bar"
                  xml.span "class" => "icon-bar"
                  xml.span "class" => "icon-bar"
                end
                xml.a "class" => "brand", "href" => absolute_url('/') do
                  xml.text! "ThoughtSpark.org"
                end
                xml.div "class" => "nav-collapse collapse" do
                  xml.ul "class" => "nav" do
                    xml.li do
                      xml.a "href" => absolute_url('/archives/') do
                        xml.text! "Archives"
                      end
                    end
                    xml.li do
                      xml.a "href" => absolute_url('/tags/') do
                        xml.text! "Tags Index"
                      end
                    end
                    xml.li do
                      xml.a "href" => absolute_url('/about-me/') do
                        xml.text! "About Me"
                      end
                    end
                  end
                  xml.form "class" => "navbar-search pull-right", "id" => "cse-search-box", "action" => "http://google.com/cse", "target" => "_blank" do
                    xml.input "type" => "hidden", "name" => "cx", "value" => "002070316934860344827:uskwlee9cfw"
                    xml.input "type" => "hidden", "name" => "ie", "value" => "UTF-8"
                    xml.input "type" => "text", "class" => "search-query", "name" => "q", "placeholder" => "Search"
                  end
                end
              end
            end
          end
          xml.div "class" => "container-fluid", "id" => "content-wrapper" do
            xml.div "class" => "row-fluid" do
              xml.div "class" => "span12 content", "id" => "content" do
                xml.div "class" => "page-header single-page-header" do
                  xml.h1 do
                    xml.text! "Feed"
                    xml.small do
                      xml.tag! "xsl:value-of", "select" => "count(atom:feed/atom:entry)"
                      xml.text! "urls"
                    end
                  end
                end
                xml.table "class" => "table table-striped table-bordered" do
                  xml.thead do
                    xml.tr do
                      xml.th do
                        xml.text! "Title"
                      end
                      xml.th do
                        xml.text! "Updated"
                      end
                    end
                  end
                  xml.tag! "xsl:for-each", "select" => "atom:feed/atom:entry" do
                    xml.tr do
                      xml.td do
                        xml.a do
                          xml.xsl :attribute, "name" => "href" do
                            xml.tag! "xsl:value-of", "select" => "atom:link/@href"
                          end
                          xml.tag! "xsl:value-of", "select" => "atom:title"
                        end
                      end
                      xml.td do
                        xml.tag! "xsl:value-of", "select" => "atom:updated"
                      end
                    end
                  end
                end
              end
            end
          end
        end
        xml.div "id" => "push"
        xml.div "id" => "footer" do
          xml.div "class" => "container-fluid" do
            xml.p do
              xml.text! "© Jeremy Whitlock 2012 | Brought to you buy "
              xml.a "href" => "http://pages.github.com/" do
                xml.text! "GitHub Pages"
              end
              xml.text! ", "
              xml.a "href" => "http://middlemanapp.com/" do
                xml.text! "Middleman"
              end
              xml.text! " and "
              xml.a "href" => "http://twitter.github.com/bootstrap/" do
                xml.text! "Twitter Bootstrap"
              end
              xml.text! "."
            end
          end
        end
        xml.comment! "JavaScript"
        xml.script "src" => absolute_url('/js/jquery.js')
        xml.script "src" => absolute_url('/js/bootstrap.js')
        xml.script "src" => absolute_url('/js/thoughtspark.org.js')
      end
    end
  end
end