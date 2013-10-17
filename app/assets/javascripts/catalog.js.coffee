HOST = 'http://shmoter.ru'
initCategories = -> 
  $.ajax {
    url: HOST + '/api/marketplace/filters.json?callback=', 
    dataType: 'jsonp',
    success: (data) -> 
      categories = data.categories
      for category in categories
        li = $("<li/>")
        a = $("<a>").text(category[0]).attr("href", '#')
        a.appendTo li
        ul = $("<ul>").addClass("category_" + category[1]).addClass("nav")
        ul.appendTo li

        if category[2]
          li.appendTo $(".category_" + category[2])
        else
          li.appendTo $("#categories")

      $("#categories li a").on 'click', (e) ->
        e.preventDefault()
        $(this).parent().toggleClass("active")
        $.ajax {
          url: HOST + '/api/marketplace/items.json?callback=', 
          dataType: 'jsonp',
          success: (data) ->
            console.log(data)
        }

  }
  
initItems = (page) ->
  $.ajax {
    url: HOST + '/api/marketplace/items.json?callback=', 
    data: {
      category_id: document.category_id,
      brand_id: document.brand_id,
      page: page
    },
    dataType: 'jsonp',
    success: (data) -> 
      $("h1").text(data.title)
      items = data.items
      if data.next_page
        $(".show-more").removeClass("hidden")
        $(".show-more").find("a").text("Показать еще").removeClass("disabled")
        $(".show-more").data('page', data.next_page)
      for item in items
        container = $("<div/>").addClass('col-md-3').addClass('col-xs-3').addClass("item-wrapper")
        item_div = $("<div/>").addClass("item").appendTo(container)
        if item.discount
          discount = $("<div/>").addClass("discount").text(item.discount + "%").appendTo(item_div)
        image = $('<div/>').addClass('image').appendTo(item_div)
        image_a = $("<a/>").attr("href", item.url).attr("target", "_blank").appendTo(image)
        img = $("<img />").attr("src", item.image_url).appendTo(image_a)
        container.appendTo("#items")
        text = $("<div />").addClass("text").appendTo(item_div)

        text_a = $("<a/>").attr("href", item.url).attr("target", "_blank").appendTo(text)
        category = $("<div/>").addClass("category").text(item.title).appendTo(text_a)
        brand = $("<div/>").addClass("brand").text(item.brand).appendTo(text_a)
        price = $("<div/>").addClass("price").text(item.price + " руб.").appendTo(text_a)
  }

$ ->
  # initCategories()
  initItems(1)
  $(".show-more").on 'click', (e) ->
    initItems($(this).data('page'))
    $(this).find("a").text("Загрузка...").addClass("disabled")
    return false


  # $(document).endlessScroll {
  #   pagesToKeep: 5,
  #   inflowPixels: 200,
  #   fireDelay: 10,
  #   callback: (p, v, d) -> 
  #     initItems(p);
  # }