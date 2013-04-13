This was an application that I built while in the Cayman Islands with my family. I figured I should drink as much kool-aid as possible since it was meant to be built extremely quickly. So I decided to build it with Coffeescript and Node, using MongoDB as a data store and running it all on Heroku.

**NOTE – This was built approximately one year ago and is unmaintained. A lot has happened since then. I code with 2 tab spaces now, and no longer drink tequila. Use this for fun and learning but don't come complainin' to me when it doesn't work.**

## Mission

An iPad would be used on a conference floor in a large display booth to collect opinions on new products from folks walking around.

The objective was to build a simple web app that looked and felt like a native iPad application. The app walked users through a series of questions, starting with asking for information about themselves and ending with showing users a new product and asking what they thought it was on a scale of 1 to 10.

## Lessons Learned

This was a fun project. I'd definitely do something similar in the future. It's nice to have what is essentially one single stack on the front and back-end. Also, writing Coffeescript is an absolute pleasure. It takes a little bit of time to become efficient with it, but once you do it really starts to repay you.

## Run It Yourself

### Dependencies

You can experiment with running the app yourself by installing foreman, node, and the required node dependencies within `package.json`

### Configure your Environment

There are a few environment variables that must be configured in order for the app to work completely. With Foreman, this is as simple as creating a `.env` file and defining the four vars:

    MONGO_URI="user:pass@host:port/database"
    MAIL_USER="user@host.com"
    MAIL_PASS="password123"
    MAIL_FROM="Stalex <stalex@stalex.se>"

Then it's a simple as executing the following command:

    foreman start
