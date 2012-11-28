---
title: The New ThoughtSpark.org
date: 2012-11-14 23:00 -07:00
tags: thoughtspark.org
---

I've decided it's time to rethink how I maintain and deploy [ThoughtSpark.org](http://www.thoughtspark.org).  My
current deployment model is to use [Drupal](http://drupal.org) to craft/host my site's content and I currently
pay a small monthly fee to [GoDaddy](http://www.godaddy.com) for hosting Drupal.  While there isn't anything
really **wrong** with my current model, I've grown tired of it.  Below are a few pain points worth mentioning.

### Maintenance Overhead
I've grown tired of maintaining Drupal.  I'm tired of applying a security patch or verision update and having my
whole site turn to crap.  Why?  All of my modules then need to be re-enabled and/or updated.  How is this a
problem?  All non-core functionality on my site *(sitemap.xml generation, SPAM filtering, syntax highlighting, ...)*
are all enabled via modules.  If these modules are disabled during the update, and they are, I now have to go through
the process of re-enabling them just so my site doesn't look like crap and I don't get SPAMed to Hell and back.

Don't get me wrong, Drupal is a phenomenal product.  It's an excellent
<abbr title="Content Management System">CMS</abbr> and Drupal is also a great example of what an
<abbr title="Open Source Software">OSS</abbr> project should be.  It's not Drupal's fault that I don't need a
<abbr title="Content Management System">CMS</abbr> and I'm sure there is a reason that the update process is more
painful than I'd like.

Another aspect of the maintenance overhead is the fact that Drupal runs on [PHP](http://php.net) and needs a
database, [MySQL](http://www.mysql.com) in my case, so you have to either host your server or pay someone to host it
you.  I chose the second option.  The overhead for this of course is the financial cost, regardless of how large or
small it is.

### Authoring
The options I've been exposed to in Drupal for authoring content on my site is to use raw
<abbr title="HyperText Markup Language">HTML</abbr> or using one of the
<abbr title="What You See Is What You Get">WYSIWYG</abbr> editors.  The problem with raw HTML is it's cumbersom and
error prone.  Crafting a single post can often end up with a lot of time spent finding HTML typos.  The problem with
WYSIWYG editors is that you often end up fighting them.  Either the output is junk or they don't handle certain use
cases, like handling code blocks.  Regardless, I loathe creating content in Drupal but again, I don't feel it's
Drupal's fault, I just want something simpler.

One approach to creating web-based content I've become very fond of as of late is
[Markdown](http://daringfireball.net/projects/markdown/).  Markdown is a great language that allows me to focus more
on the content being crafted while still being able to style my content very easily.  I can even drop in raw HTML
wheenver I feel the need to.  If you've ever visited any [GitHub](https://www.github.com) project/user homepage or
a project's wiki, you've seen the result of Markdown.

### The Solution
The new ThoughtSpark.org will no longer be using Drupal and will no longer be deployed on GoDaddy.  Instead, I'm going
to use a static website generator that will take my Markdown files and create my website.  The tool I will be using is
[Middleman](http://www.middlemanapp.com) and I will be using [GitHub Pages](http://pages.github.com/) as my host.  Not
only will writing/maintaining my website content be easier but now it will also require no cost to host.  Those two
things are good enough reasons for me to switch but there are also the following reasons that are equally compelling:

* **Security**: With there being no server-side component and no server-side processing, there are much fewer security
issues that I need to concern myself with
* **Performance**: With there being no server-side component and no server-side processing, the performance of the site
will be faster
* **Deployment**: The solutions for hosting static websites are plentiful and you are no longer locked into a
particular host/product for hosting your website.  *(There's a chance you're already using a
service that will host your static websites for you.  Examples: GitHub's Pages and 
[DropBox](http://www.dropboxwiki.com/Hosting_Websites_with_Dropbox) are two excellent examples.)*

### In Closing
GitHub Pages, Markdown, Middleman and [Twitter Bootstrap](http://twitter.github.com/bootstrap/) have made it very easy
for me to re-create and maintain ThoughtSpark.org.  I feel like with this new approach for ThoughtSpark.org, I'll be
able to get posts out quicker and much easier, while saving a few bucks along the way.  Thanks for your patience and I
look forward to sharing with you on my new platform.

**Note:** There are a few things left to finish before I'd say that the migration is complete, follow
[here](https://github.com/whitlockjc/thoughtspark.org/issues/1) if you're interested.

**Note:** Originally I had planned on migrating all of the old Drupal posts to the new platform.  I've decided against
it for a few reasons and will instead only migrate things upon request.  To request such a thing, use the
[issue tracker](https://github.com/whitlockjc/thoughtspark.org/issues) or hit me up on
[Twitter](https://twitter.com/whitlockjc).