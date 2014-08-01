---
note: "this is needed for processing by jekyll"
---

# product pages which want to render tabs have to define build_tabs: 1 in yaml front matter
# this will cause inclusion of .tabs template (see product-home.html)
# here we go through the content and convert every new H2 tag into a new tab with same name
# tabs are implemented using jQuery UI tabs component
transformContentIntoTabsAndPanes = (contentSelector, tabsSelector) ->
  tabs = $(tabsSelector)
  return  unless tabs.length # tabs not enabled
  ul = tabs.find("ul")
  cur = undefined
  items = $(contentSelector)
  items.each ->
    el = $(this)
    return  if el.hasClass("panes") or el.hasClass("tabs") # is this needed?
    tag = el.prop("tagName")
    return  if tag in ["SCRIPT", "NOSCRIPT", "STYLE"]
    if tag is "H2"
      name = el.html()
      id = name.toLowerCase().replace(/[^a-z0-9]/g, "-") # hash-friendly normalization
      li = $("<li/>")
      a = $("<a/>").attr("href", "#" + id).html(name)
      li.append a
      a.append "<div class=\"shadow\"/>"
      ul.append li
      cur = $("<div/>").addClass(id).addClass("page-content").prop("id", id)
      tabs.append cur
      el.remove()
    else
      cur.append el  if cur

  ignoreActivate = false
  tabs.tabs activate: (event, ui) ->
    if ignoreActivate
      # tab was activated when going back in history
      ignoreActivate = false
      return
    # add tab location into history, also prevents page jump
    # http://lea.verou.me/2011/05/change-url-hash-without-page-jump
    hash = ui.newPanel.attr("id")
    if history.pushState
      history.pushState null, null, "#" + hash
    else
      window.location.hash = hash # older browsers fallback

  # hash changes should reflect in tab selection, but without adding new item into history
  $(window).on "hashchange", ->
    index = tabs.find("a[href=\"#{location.hash}\"]").parent().index()
    ignoreActivate = true
    tabs.tabs "option", "active", index
    
  $('html').addClass('product-tabs-present')
  tabs.show()

$ ->
  transformContentIntoTabsAndPanes(".product-content .container > *", ".product-tabs")