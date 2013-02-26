<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:sitemap="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes">
&lt;!DOCTYPE html&gt;    </xsl:text>
    <html lang="en" xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <meta charset="utf-8"/>
        <title>
ThoughtSpark.org - Sitemap        </title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="description" content="Interesting stuff from the eyes of Jeremy Whitlock"/>
        <meta name="author" content="Jeremy Whitlock &lt;jcscoobyrs@gmail.com&gt;"/>
        <!-- Stylesheets -->
        <link href="http://thoughtspark.org/css/bootstrap.css" rel="stylesheet"/>
        <link href="http://thoughtspark.org/css/thoughtspark.org.css" rel="stylesheet"/>
        <link href="http://thoughtspark.org/css/bootstrap-responsive.css" rel="stylesheet"/>
      </head>
      <body>
        <div id="wrapper">
          <div class="navbar navbar-inverse navbar-fixed-top">
            <div class="navbar-inner">
              <div class="container-fluid">
                <a data-toggle="collapse" data-target=".nav-collapse" class="btn btn-navbar">
                  <span class="icon-bar"/>
                  <span class="icon-bar"/>
                  <span class="icon-bar"/>
                </a>
                <a href="http://thoughtspark.org/" class="brand">
ThoughtSpark.org                </a>
                <div class="nav-collapse collapse">
                  <ul class="nav">
                    <li>
                      <a href="http://thoughtspark.org/archives/">
Archives                      </a>
                    </li>
                    <li>
                      <a href="http://thoughtspark.org/tags/">
Tags Index                      </a>
                    </li>
                    <li>
                      <a href="http://thoughtspark.org/about-me/">
About Me                      </a>
                    </li>
                  </ul>
                  <form action="http://google.com/cse" class="navbar-search pull-right" target="_blank" id="cse-search-box">
                    <input type="hidden" name="cx" value="002070316934860344827:uskwlee9cfw"/>
                    <input type="hidden" name="ie" value="UTF-8"/>
                    <input type="text" name="q" placeholder="Search" class="search-query"/>
                  </form>
                </div>
              </div>
            </div>
          </div>
          <div class="container-fluid" id="content-wrapper">
            <div class="row-fluid">
              <div class="span12 content" id="content">
                <div class="page-header single-page-header">
                  <h1>
Sitemap                    <small>
                      <xsl:value-of select="count(sitemap:urlset/sitemap:url)"/>
urls                    </small>
                  </h1>
                </div>
                <table class="table table-striped table-bordered">
                  <thead>
                    <tr>
                      <th>
URL                      </th>
                      <th>
Last Modified                      </th>
                      <th>
Priority                      </th>
                      <th>
Change Frequency                      </th>
                    </tr>
                  </thead>
                  <xsl:for-each select="sitemap:urlset/sitemap:url">
                    <tr>
                      <td>
                        <a>
                          <xsl:attribute name="href">
                            <xsl:value-of select="sitemap:loc"/>
                          </xsl:attribute>
                          <xsl:value-of select="sitemap:loc"/>
                        </a>
                      </td>
                      <td>
                        <xsl:value-of select="sitemap:lastmod"/>
                      </td>
                      <td>
                        <xsl:value-of select="sitemap:priority"/>
                      </td>
                      <td>
                        <xsl:value-of select="sitemap:changefreq"/>
                      </td>
                    </tr>
                  </xsl:for-each>
                </table>
              </div>
            </div>
          </div>
        </div>
        <div id="push"/>
        <div id="footer">
          <div class="container-fluid">
            <p>
&#169; Jeremy Whitlock 2012 | Brought to you buy               <a href="http://pages.github.com/">
GitHub Pages              </a>
,               <a href="http://middlemanapp.com/">
Middleman              </a>
 and               <a href="http://twitter.github.com/bootstrap/">
Twitter Bootstrap              </a>
.            </p>
          </div>
        </div>
        <!-- JavaScript -->
        <script src="http://thoughtspark.org/js/jquery.js"/>
        <script src="http://thoughtspark.org/js/bootstrap.js"/>
        <script src="http://thoughtspark.org/js/thoughtspark.org.js"/>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
