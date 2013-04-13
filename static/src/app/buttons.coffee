class Button
    constructor: (@label, @id, @classes) ->
        this.type = 'htmlelement'

    get_classes: ->
        _.union(['btn', ], @classes).join(" ")

    render: ->
        return "<button id=\"#{@id}-btn\" class=\"#{@get_classes()}\">#{@label}</button>"

window.Button = Button