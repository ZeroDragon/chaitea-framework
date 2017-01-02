###*
 * Chai Tea Framework
 * By ZeroDragon (Carlos Flores)
 * https://github.com/ZeroDragon/
 * http://floresbenavides.com
###

config        = require.main.require "./config.json"
consolecolors = require 'consolecolors'
express       = require 'express'
request       = require 'request'
session       = require 'express-session'
df            = require 'dateformat'
bParser       = require 'body-parser'
pug           = require 'pug'
stylus        = require 'stylus'
fs            = require 'fs'
coffee        = require 'coffee-script'
time          = require('time')(Date)
compress      = require 'compression'
babel         = require 'babel-core'
d = new Date();d.setTimezone(config.timezone)

_assets = (req,res,next)->
	_type = (q)-> req.originalUrl.indexOf(q) isnt -1
	fileArrNoParams = req.originalUrl.split('?')[0]
	fileArr = fileArrNoParams.split('.')
	ext = fileArr.pop()
	file = fileArr.join('.')

	if ext

		if ext.indexOf('?') isnt -1
			ext = ext.substring(0, ext.indexOf('?'))
		if ext.indexOf('#') isnt -1
			ext = ext.substring(0, ext.indexOf('#'))

		_notFound = ->
			res.status 404
			res.render CT_Static+'/404.pug'
			return
		switch
			when _type('.css')
				# is it a stylus file
				try
					styl = fs.readFileSync("#{process.cwd()}/app/assets/#{file}.styl",{encoding:'utf8'})
					stylus.render styl,(err,css)->
						res.header "Content-type", "text/css"
						res.send css
						return
				catch e
					# is it a vanilla css
					try
						css = fs.readFileSync("#{process.cwd()}/app/assets/#{file}.css",{encoding:'utf8'})
						res.header "Content-type", "text/css"
						res.send css
						return
					catch e
						_notFound()
						return
			when _type('.js')
				# is it a coffee file
				try
					script = fs.readFileSync("#{process.cwd()}/app/assets/#{file}.coffee",{encoding:'utf8'})
				catch e
					# is it a vanilla js
					try
						js = fs.readFileSync("#{process.cwd()}/app/assets/#{file}.js",{encoding:'utf8'})
						res.header "Content-type", "application/javascript"
						res.send js
						return
					catch e
						_notFound()
						return
				compiled = coffee.compile script, {bare:true}
				res.header "Content-type", "application/javascript"
				res.send compiled
				return
			when _type('.es6')
				try
					script = fs.readFileSync("#{process.cwd()}/app/assets/#{file}.es6",{encoding:'utf8'})
				catch e
					# is it a vanilla js
					try
						js = fs.readFileSync("#{process.cwd()}/app/assets/#{file}.js",{encoding:'utf8'})
						res.header "Content-type", "application/javascript"
						res.send js
						return
					catch e
						_notFound()
						return
				{code} = babel.transform script
				res.header "Content-type", "application/javascript"
				res.send code
				return
			else
				res.sendFile "#{process.cwd()}/app/assets/#{file}.#{ext}", (err)-> _notFound() if err
				return
		next()
	else next()

_startserver = ->
	ready = ->
		console.log "Listening at "+"#{if config.https? then "https" else "http"}://localhost:#{config.port}".magenta

	app.use _assets

	if config.https?
		https = require "https"
		key = if config.https.key.indexOf("\\n") is -1 then config.https.key else fs.readFileSync(config.https.key)
		cert = if config.https.cert.indexOf("\\n") is -1 then config.https.cert else fs.readFileSync(config.https.cert)
		https.createServer({key:key,cert:cert}, app).listen config.port, ready
	else
		app.listen config.port, ready

_createApp = ->
	app = express()
	payloadSize = if config.payloadSize? then config.payloadSize else '2mb'
	app.use bParser.urlencoded { extended: true,limit: payloadSize }
	app.use bParser.json({limit: payloadSize})
	app.use compress()
	app.use session({
		secret : config.session_secret
		resave : true
		saveUninitialized : true
	})
	return app

specs = {
	config         : config
	app            : _createApp()
	pug            : pug
	CT_Static      : "#{process.cwd()}/app/views"
	CT_Assets      : _assets
	CT_StartServer : _startserver

	CT_DateFormat : (epoch,format=false)->
		return df epoch*1000,format

	CT_LoadController : (name)->
		return require "#{process.cwd()}/app/controllers/#{name}_controller.coffee"

	CT_LoadModel : (name)->
		return require "#{process.cwd()}/app/models/#{name}_model.coffee"

	CT_StringToDate : (string)->
		r = string.split('-').map (v,i)->
			v = ~~v
			v-- if i is 1
			return v
		return new Date r[0],r[1],r[2],0,0,0

	CT_Infusion : (recipe)->
		for name, ingredient of recipe
			global[name] = ingredient
	CT_Routes : (file,cb)->
		if typeof file is 'function'
			require.main.require "./routes.coffee"
			file()
		else
			require.main.require "./#{file}.coffee"
			cb()

}

global[name] = spec for name, spec of specs
