#!/usr/bin/env coffee

ejs = require 'ejs'
express = require 'express'
fs = require 'fs'
mongojs = require 'mongojs'
nodemailer = require 'nodemailer'

app = express.createServer express.logger()

app.set "view engine", "ejs"

app.configure ->
    app.use express.methodOverride()
    app.use express.bodyParser()
    app.use app.router
    app.use express.static(__dirname + "/static")
    app.use express.errorHandler(
        dumpExceptions: true,
        showStack: true
    )

# Database
db = mongojs.connect(process.env.MONGO_URI, ['submissions'])

# Email
smtpTransport = nodemailer.createTransport("SMTP",
    service: "Gmail"
    auth:
        user: process.env.MAIL_USER
        pass: process.env.MAIL_PASS
)

# Index
app.get "/", (req, res) ->
    res.render "index.ejs"

# Capture
app.post "/capture", (req, res) ->
    db.submissions.save req.body

    admin_email = fs.readFileSync "#{__dirname}/views/email/admin_email.ejs", 'ascii'

    admin_mail_options =
        from: process.env.MAIL_FROM
        to: "facebook@arbesko.se"
        subject: "New Stalex iPad Voting Submission"
        text: ejs.render admin_email, req.body

    smtpTransport.sendMail admin_mail_options, (error, response) ->
        if error
            console.log error
        else
            console.log "Message sent: " + response.message

    # Now handle emailing the end-user
    user_email = fs.readFileSync "#{__dirname}/views/email/user_email.txt", 'ascii'

    user_mail_options =
        from: process.env.MAIL_FROM
        to: req.body.email
        subject: "Stålex tävling med iPod Nano"
        text: user_email

    smtpTransport.sendMail user_mail_options, (error, response) ->
        if error
            console.log error
        else
            console.log "Message sent: " + response.message

    res.send
        success: true

app.get "/list", (req, res) ->
    # List all current mongodb submissions
    db.submissions.find (err, submissions) ->
        res.render "list.ejs", 
            submissions: submissions

port = process.env.PORT or 3000
app.listen port, ->
    console.log "Listening on " + port