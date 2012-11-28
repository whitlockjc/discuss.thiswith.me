<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <xsl:output omit-xml-declaration="yes" method="html" encoding="ISO-8859-1"/>
  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes">
&lt;!DOCTYPE html&gt;    </xsl:text>
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
      <head>
        <meta charset="utf-8"/>
        <title>
ThoughtSpark.org - Feed        </title>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <meta content="Interesting stuff from the eyes of Jeremy Whitlock" name="description"/>
        <meta content="Jeremy Whitlock &lt;jcscoobyrs@gmail.com&gt;" name="author"/>
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
                <a data-target=".nav-collapse" data-toggle="collapse" class="btn btn-navbar">
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
                  <form id="cse-search-box" action="http://google.com/cse" target="_blank" class="navbar-search pull-right">
                    <input value="002070316934860344827:uskwlee9cfw" type="hidden" name="cx"/>
                    <input value="UTF-8" type="hidden" name="ie"/>
                    <input placeholder="Search" type="text" name="q" class="search-query"/>
                  </form>
                </div>
              </div>
            </div>
          </div>
          <div id="content-wrapper" class="container-fluid">
            <div class="row-fluid">
              <div id="content" class="span12 content">
                <div class="page-header single-page-header">
                  <h1>
Feed                    <small>
                      <xsl:value-of select="count(atom:feed/atom:entry)"/>
urls                    </small>
                  </h1>
                </div>
                <table class="table table-striped table-bordered">
                  <thead>
                    <tr>
                      <th>
Title                      </th>
                      <th>
Updated                      </th>
                    </tr>
                  </thead>
                  <xsl:for-each select="atom:feed/atom:entry">
                    <tr>
                      <td>
                        <a>
                          <xsl:attribute name="href">
                            <xsl:value-of select="atom:link/@href"/>
                          </xsl:attribute>
                          <xsl:value-of select="atom:title"/>
                        </a>
                      </td>
                      <td>
                        <xsl:value-of select="atom:updated"/>
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
