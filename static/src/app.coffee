class Application
    constructor: () ->
        @SLIDE_SPEED = 300
        @AGE_CHOICES = [ '10-12', '13-15', '16-18', '18-25', '26-29', '30+' ]
        @PRODUCTS = [ 'carmine_red', 'ghost_white', 'hot_pink', 'pale_blue' ]

        # Some initialization shenanigans
        @current_product = 0
        @current_user = null

        @wrapper = $('#wrapper')

        # Get the ball rolling.
        @home()

    display_slide: (slug, params, id_attr, callback) ->
        slide_html = Templates[slug](params)

        id = if id_attr then id_attr else slug

        slide = $('<section class="slide" />').attr('id', id+'-slide').html(slide_html)
        
        @wrapper.append slide

        # Auto-center the current slide.
        @auto_center slide

        if @active_slide
            old_active = @active_slide
            old_active.fadeOut @SLIDE_SPEED, ->
                old_active.remove()
                slide.fadeIn @SLIDE_SPEED
        else
            slide.fadeIn @SLIDE_SPEED

        if callback
            setTimeout ->
                callback()
            , @SLIDE_SPEED

        @active_slide = slide

    auto_center: (slide) ->
        slide.css
            "margin-left": - slide.width() / 2
            "margin-top": - slide.height() / 2

    # This slide will greet the user with a start button.
    home: ->
        params = 
            home_text: "Hjälp oss att betygsätta våra nya Stålex<br/>skor & ha chansen att vara en<br/><strong>vinnare av en iPod Nano ifrån Apple.</strong>"
            continue_button: new Button("Start", 'home-continue').render()
  
        @display_slide 'home', params

        $('#home-continue-btn').bind 'click', =>
            @user_info()

    # This slide will ask users to input data about themselves.
    user_info: ->
        params = 
            your_name_label: 'Ditt namn'
            your_email_label: 'Din e-post'
            use_facebook_pri_text: 'Använder du Facebook?'
            facebook_chooser: @facebook_chooser 'has_facebook'
            your_age_label: 'Hur gammal är du?',
            age_chooser: @age_chooser 'your_age'
            next_button: new Button("Nästa", 'user-info-next').render()

        @display_slide 'user_info_slide', params, 'user_info_slide', ->
            $('#your_name').focus()

        $('#user_info_form').bind 'submit', ->
            $('#user-info-next-btn').click()
            false

        $('#user-info-next-btn').bind 'click', =>
            # Capture form data. Submit that to back-end.
            # This will give us an ID to use going forward for the voting.
            fields = [ 'your_name', 'your_email', 'has_facebook', 'your_age' ]
            
            data = {}
            errors = []

            _.each fields, (f) ->
                d = $("##{f}").val()
                data[f] = d
                
                if d is ''
                    errors.push(f)

            if errors.length
                alert 'Vänligen fyll i namn & e-post! Fyll i dem innan du fortsätter.'
            else
                # Here we'll create a new object with this data collection.
                # We'll store this as '@current_user' and then call a save method on her
                # at the end to push all data to server.
                @current_user = new User(data)

                @question_arbesko()

            false

    question_arbesko: ->
        params = 
            question: 'Känner du till Arbesko?',
            yes_button: new Button("Ja", 'question-arbesko-yes', 'yes').render()
            no_button: new Button("Nej", 'question-arbesko-no', 'no').render()

        slide = @display_slide 'question_slide', params, 'question-arbesko'

        $('#question-arbesko-yes-btn').bind 'click', =>
            @current_user.arbesko_question = 'yes'

        $('#question-arbesko-no-btn').bind 'click', =>
            @current_user.arbesko_question = 'no'

        # Collect events for overall buttons.
        slide.find('button.btn').bind 'click', =>
            @question_stalex()

    question_stalex: ->
        params = 
            question: 'Känner du till Stålex?'
            yes_button: new Button("Ja", 'question-stalex-yes').render()
            no_button: new Button("Nej", 'question-stalex-no').render()
        
        slide = @display_slide 'question_slide', params, 'question-stalex'

        $('#question-stalex-yes-btn').bind 'click', =>
            @current_user.stalex_question = 'yes'

        $('#question-stalex-no-btn').bind 'click', =>
            @current_user.stalex_question = 'no'

        slide.find('button.btn').bind 'click', =>
            @prompt_slide()

    prompt_slide: ->
        params =
            heading: 'Nu ska du få se våra skor.'
            sub_heading: 'Betygsätt dom från 1-10, där 1 är sämst och 10 är bäst och du.. <strong>var ärlig!</strong>'
            continue_button: new Button('Vidare', 'begin-voting').render()
        
        @display_slide 'prompt_slide', params

        $('#begin-voting-btn').bind 'click', =>
            @vote_slide()

    # Generate a voting bar. 
    vote_bar: ->
        buttons = ("<a data-rating=\"#{num}\">#{num}</a>" for num in [1..10])
        button_str = buttons.join ""

        "<section class=\"vote-bar\">#{button_str}</section>"

    store_rating: (product, rating) ->
        @current_user['ratings'][product] = rating

    vote_slide: ->
        # fetch the product
        product = @PRODUCTS[@current_product]

        params =
            product_img: "/img/products/#{product}.png"
            product_name: product
            vote_bar: @vote_bar()

        @display_slide 'vote_slide', params

        # Handle binding any voting buttons.
        $('#vote_slide-slide .vote-bar a').bind 'click', ->
            rating = $(this).data 'rating'

            if not $(this).hasClass 'selected'
                # show notice
                if not $('.vote-notice').size()
                    vote_notice = $ '<p class="vote-notice">Tryck en gång till på samma betyg för att fortsätta.</p>'
                    $('.vote-bar').after vote_notice
                    vote_notice.fadeIn()

                $(this).siblings().removeClass 'selected'
                $(this).addClass 'selected'

            else
                # At this point, show the notice to tap again to confirm the vote.
                app.store_rating(product, rating)

                # If the user does, continue to next product.
                # AKA, increment the @current_product counter and play this slide again.
                app.current_product++

                # UNLESS, we've just voted for the last one (current_product+1 = PRODUCTS.length)
                unless app.current_product is app.PRODUCTS.length
                    app.vote_slide()
                else
                    app.current_product = 0
                    app.success_slide()

    success_slide: ->
        # Before all this stuff is displayed, start the async submission of user data.
        u = @current_user

        $.ajax(
            url: '/capture'
            type: 'POST'
            dataType: 'json'
            data: u.get_serialized()
        )

        success_message = [ 
            'Tack! Nu har du en chans att vinna en iPod Nano.'
            "Vi har skickat e-post till #{u.email} med mer information om tävlingen."
            '<strong>Vinnaren presenteras på facebook.com/stalexshoes</strong>'
        ]

        params =
            success_message: success_message.join "<br/>"
            start_over_button: new Button('Starta igen', 'reset').render()

        @display_slide 'success_slide', params

        ipod_nanos = $('<i class="ipod-nanos"></i>')
        @wrapper.prepend ipod_nanos
        
        setTimeout ->
            ipod_nanos.fadeIn @SLIDE_SPEED
        , 500

        $('#reset-btn').bind 'click', =>
            ipod_nanos.fadeOut @SLIDE_SPEED, ->
                $(this).remove()

            @reset()

    # App reset procedure
    reset: ->
        # Clear out current user?
        if @current_user
            @current_user = false


        # Start ovar
        @home()

        return

    age_chooser: (slug) ->
        r = [ "<select id=\"#{slug}\" name=\"#{slug}\">" ]

        r.push "<option value=\"#{x}\">#{x}</option>" for x in @AGE_CHOICES
            
        r.push '</select>'

        r.join ""

    facebook_chooser: (slug) ->
        options = 
            yes: 'Ja'
            no: 'Nej'

        r = [ "<select id=\"#{slug}\" name=\"#{slug}\">" ]

        r.push "<option value=\"#{value}\">#{label}</option>" for value, label of options

        r.push '</select>'

        r.join ""

$ ->
    window.app = new Application