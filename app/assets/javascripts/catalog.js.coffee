HOST = 'http://shmoter.ru'
initCategories = -> 
  $.ajax {
    url: HOST + '/api/marketplace/filters.json?callback=', 
    dataType: 'jsonp',
    data: {
      brand_id: document.brand_id
    },
    success: (data) -> 
      categories = data.categories
      for category in categories
        li = $("<li/>").addClass("category_" + category[1]).addClass("depth_" + category[3])
        a = $("<a>").text(category[0]).attr("href", '#').data("id", category[1])
        a.appendTo li
        
        
        if category[2]
          targetLi = $(".category_" + category[2])
          
          if targetLi.find("> .nav").length == 0
            ul = $("<ul>").addClass("nav")
            ul.appendTo targetLi

          li.appendTo(targetLi.find("> .nav"))

        else
          li.appendTo $("#categories")

      $("#categories li a").on 'click', (e) ->
        e.preventDefault()
        $(this).parent().parent().find("> li").removeClass('active')
        $(this).parent().find("li").removeClass('active')
        $(this).parent().addClass("active")

        document.category_id = $(this).data("id")
        initItems(1)
  }
  
initItems = (page) ->
  if page == 1
    $("#items").html("")
    $(".show-more").addClass("hidden")
  $.ajax {
    url: HOST + '/api/marketplace/items.json', 
    data: {
      category_id: document.category_id,
      brand_id: document.brand_id,
      page: page
    },
    dataType: 'jsonp',
    success: (data) -> 
      $("h1").text(data.title)
      document.title = data.title
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
  initCategories()
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