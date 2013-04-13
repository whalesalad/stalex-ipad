class User
    constructor: (user_data) ->
        @name = user_data.your_name
        @email = user_data.your_email
        @has_facebook = user_data.has_facebook
        @age = user_data.your_age
        @ratings = {}

        console.log "<New User: #{@name}, #{@email}>"

    get_first_name: ->
        return @name.split(' ')[0]

    get_serialized: ->
        {
            name: @name
            email: @email
            facebook: @has_facebook,
            arbesko_question: @arbesko_question,
            stalex_question: @stalex_question,
            age: @age
            ratings: @ratings
        }

window.User = User
