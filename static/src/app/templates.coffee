_templates = 
    home: [ 
        '<img src="/img/slides/01/stalex-logo.png" />',
        '<p><%= home_text %></p>'
        '<%= continue_button %>'
    ]

    user_info_slide: [
        '<form id="user_info_form">'
        '<section class="field">'
            '<p class="label"><label for="your_name"><%= your_name_label %></label></p>'
            '<p><input type="text" id="your_name" name="your_name" /></p>'
        '</section>'
        '<section class="field">'
            '<p class="label"><label for="your_email"><%= your_email_label %></label></p>'
            '<p><input type="email" id="your_email" name="your_email" /></p>'
        '</section>'
        '<section class="field left-field">'
            '<p class="label"><%= use_facebook_pri_text %></p>'
            '<p><%= facebook_chooser %></p>'
        '</section>'
        '<section class="field right-field">'
            '<p class="label"><label for="your_age"><%= your_age_label %></label></p>'
            '<p><%= age_chooser %></p>'
        '</section>'
        '<div class="clear"></div>'
        '<%= next_button %>'
        '</form>'
    ]

    # Used for both arbesko and stalex questions
    question_slide: [
        '<h1><%= question %></h1>'
        '<section class="button-wrapper">'
        '<%= yes_button %><%= no_button %>'
        '</section>'
    ]

    # Used for "now we're going to show you some shoes slide"
    prompt_slide: [
        '<h2><%= heading %></h2>'
        '<p><%= sub_heading %></p>'
        '<%= continue_button %>'
    ]

    vote_slide: [
        '<section class="shoe-box">'
            '<img src="<%= product_img %>" id="product-photo-<%= product_name %>" alt="<%= product_name %>" />'
        '</section>'
        '<%= vote_bar %>'
    ]

    success_slide: [
        '<h3><%= success_message %></h3>'
        '<%= start_over_button %>'   
    ]

# Loop templates and make a fancy object out of them.
Templates = {}
_.each _templates, (t, slug) ->
    Templates[slug] = _.template(t.join("\n"))

window.Templates = Templates