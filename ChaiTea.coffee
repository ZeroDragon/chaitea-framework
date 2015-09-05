_getConfig = ->
	cfg = require.main.require "./config.json"
	cfg.static = "#{process.cwd()}/app/views"
	return cfg
config = _getConfig()

consolecolors = require 'consolecolors'
express       = require 'express'
request       = require 'request'
session       = require 'express-session'
df            = require 'dateformat'
bParser       = require 'body-parser'
jade          = require 'jade'
stylus        = require 'stylus'
fs            = require 'fs'
coffee        = require 'coffee-script'
time          = require('time')(Date)
deasync       = require 'deasync'
d = new Date();d.setTimezone(config.timezone)

_assets = (req,res,next)->
	_type = (q)-> req.originalUrl.indexOf(q) isnt -1
	fileArr = req.originalUrl.split('.')
	ext = fileArr.pop()
	file = fileArr.join('.')

	if ext

		if ext.indexOf('?') isnt -1
			ext = ext.substring(0, ext.indexOf('?'))
		if ext.indexOf('#') isnt -1
			ext = ext.substring(0, ext.indexOf('#'))

		_notFound = ->
			res.status 404
			res.render config.static+'/404.jade'
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
			else
				res.sendFile "#{process.cwd()}/app/assets/#{file}.#{ext}", (err)-> _notFound() if err
				return
		next()
	else next()

_startserver = ->
	app.use _assets
	server = app.listen config.port, ->
		console.log 'Listening at '+"http://localhost:#{config.port}".magenta

_createApp = ->
	app = express()
	app.use bParser.urlencoded { extended: true }
	app.use bParser.json()
	app.use session({
		secret : config.session_secret
		resave : true
		saveUninitialized : true
	})
	return app

specs = {
	config         : _getConfig()
	app            : _createApp()
	jade           : jade
	CT_StartServer : _startserver
	CT_Await       : deasync.loopWhile

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

}

global[name] = spec for name, spec of specs