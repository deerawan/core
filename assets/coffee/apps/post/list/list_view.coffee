@Wardrobe.module "PostApp.List", (List, App, Backbone, Marionette, $, _) ->

  class List.PostItem extends App.Views.ItemView
    template: "post/list/templates/item"
    tagName: "tr"

    attributes: ->
      if @model.get("active") is "1"
        class: "post-item"
      else
        class: "post-item draft"

    triggers:
      "click .delete" : "post:delete:clicked"

    events:
      "click .details" : "edit"
      "click .preview" : "preview"

    onShow: ->
      allUsers = App.request "get:all:users"
      $avEl = @$(".avatar")
      if allUsers.length is 1
        $avEl.hide()
      else
        user = @model.get("user")
        $avEl.avatar user.email, $avEl.attr("width")
        @$('.js-format-date').formatDates()

    templateHelpers:
      status: ->
        if parseInt(@active) is 1 and @publish_date > moment().format('YYYY-MM-DD HH:mm:ss')
          Lang.post_scheduled
        else if parseInt(@active) is 1
          Lang.post_active
        else
          Lang.post_draft

    edit: (e) ->
      e.preventDefault()
      App.vent.trigger "post:item:clicked", @model

    preview: (e) ->
      e.preventDefault()
      storage = new Storage
        id: @model.id
      storage.put @model.toJSON()
      window.open("#{App.request("get:url:blog")}/post/preview/#{@model.id}",'_blank')

  class List.Empty extends App.Views.ItemView
    template: "post/list/templates/empty"
    tagName: "tr"

  class List.Posts extends App.Views.CompositeView
    template: "post/list/templates/grid"
    itemView: List.PostItem
    emptyView: List.Empty
    itemViewContainer: "tbody"
    className: "span12"
