Chai Tea Framework
==================

ChaiTea-Framework is a BackEnd framework for nodejs, working over ExpressJS using MVC structure. Auto compiles JADE, STYLUS and COFFEESCRIPT to clientside, no need to pre-compiling.

Basically you can continue coding with coffeescript all the way to the clientside without worring about precompiling the files (no grunt,gulp,make,cake,etc needed).   
Do you like stylus? Well, you can use stylus and ChaiTea-Framework will parse them to CSS on the go.  
Jade view files will render, include, extend, mixin, etc and not a single line of HTML will be on your repo.  
Of course if you still want to use JS, CSS and HTML files, you can use them.

A few considerations must be taken in order to make it work efficiently. I Strongly  suggest to use ChaiTea-Brewer to kickstart a new project, it will take care of creating a bare minimal app that can be modified to any of your needs.

## Why ChaiTea-Framework?
### Story
ChaiTea-Framework was made because I needed to create a few apps at my job. First I tried using bare minimal html requirements, but routing and taking care of all by myself took too much time. Then using expressJS, this was a good option, but everytime I needed to set the same configuration over and over again. Then I tried HARP because I wanted to use Coffeescript, Stylus and Jade without compiling everytime before testing, but HARP is not exactly what I needed, uses SASS and need to configure extra stuff everytime.  
And finally I decided that it was enough, so I started to create a framework over ExpressJS that let me use Coffeescript, Stylus and Jade on the fly. Then added my most recurrent process to the core, so I can use them globally. Then I created a brewer in order to create new apps in 1 line of bash.

### Constant Testing and Improvement
I've been using ChaiTea-Framework ever since on every webapp I need to create, and when new stuff is needed, I add it to the core and updated the repo. So this is not a zombie project and its constantly being tweaked. Actually my [blog](http://floresbenavides.com) was created over ChaiTea-Framework.

## Installing  

### Using ChaiTea-Brewer  

Reffer to [ChaiTea-Brewer](https://github.com/ZeroDragon/ChaiTea-Brewer) documentation.  

### Manuall Install 
You can skip most of this using ChaiTea-Brewer, but here is the long run:

	npm i chaitea-framework --save

You will need to create the following structure:

	yourAppFolder
		|- app
			|- assets <- Clientside assets
				|- images
				|- scripts
				|- styles
			|- controllers
			|- models
			|- views
		|- yourApp.coffee <-This is your main file
		|- config.json
		|- package.json
		|- routes.coffee <- Optional

Anything you add to the ```config.json``` file will be available globally, the minimal structure should be like this:

	{
		"port" : 1339,
		"session_secret" : "my secret stuff",
		"timezone" : "America/Mexico_City"
	}

Obvious stuff if obvious. But:

- port: The port where the webapp will run
- session_secret: used to create cookies
- timezone: Set this to your timezone and worry no more about daylight saving.


## Usage  

just require it on you main ```app.coffee``` file:  

	require 'chaitea-framework'

Chai Tea will expose ```app``` globally so you can use it yo create the routes just like you'd normally use it in expressjs. When you are finished routing, just call ```CT_StartServer()``` to fire it up.  

Now that you know how to use it (seriously, take a look at ChaiTea-Brewer) lets talk about what is included inside ChaiTea-Framework.

## Included herbs
ExpressJS is a very nice service but every new version they release, they make it lighter by converting core packages to third part ones. And everytime I started using express I always use the same packages. So ChaiTea-Framework auto-loads this packages to the core:

- express-session
- body-parser

So you don't need to worry about serving sessions and parsing POST or GET request with params. This methods are loaded and added to ExpressJS before launching the app. No need to do anything here.


## Exposed methods  
ChaiTea-Framework exposes variables and methods to use globally on your application, this is to make it easier to load your methods.  
The methods and variables exposed are:  

- [config](#config)
- [app](#app)
- [jade](#jade)
- [CT_Static](#ct_static)
- [CT_Assets](#ct_assetsreqresnext-middleware)
- [CT_StartServer](#ct_startserver)
- [CT_Await](#ct_awaitfunction-deprecated-soon)
- [CT_DateFormat](#ct_dateformatinteger-epochformat)
- [CT_LoadController](#ct_loadcontrollerstring-controller)
- [CT_LoadModel](#ct_loadmodelstring-model)
- [CT_StringToDate](#ct_stringtodatestring-html5date)
- [CT_Infusion](#ct_infusionobject-recipe)
- [CT_Routes](#ct_routesstring-file-function-callback)

### config
Config is your ```config.json``` file parsed and ready to use.

### app
This is the regular app variable obtained from express: ```app = express()```.  

### jade
Jade rendering engine, you can use this to render jade files to variables, not required to render a page, since express already knows that if the view file is a ```.jade``` file, it will use jade internally.  

### CT_Static
This is a refference to the app/views route inside your project, so you can use it to render just like you do it on express.js.  

### CT_Assets(req,res,next) [middleware]
CT_Assets takes care of the pre-rendering of Styl=>CSS, Coffee=>JS and anything else as binary file, aswell will return an 404 error if the requested asset is not found.  
Regularly you won't need this method, for it is already being used inside ```CT_StartServer``` you will need this method only if you need to start your server in a very custom way (anybody said socket.io?)  

### CT_StartServer()
Use this method to start your server after you have defined the routes. This will call the Assets, check for **SSL** support and finally ```app.listen``` to start the server on the predefined port.  

**HTTPS/SSL**  
If you want to start your server over HTTPS, you must add to your ```config.json``` file the following attributes:  

	"https": {
		"key" : "your entire key here or the route to the key file"
		"cert" : "your entire cert here or the route to the cert file"
	}
And of course, change the port to ```443```

### CT_Await(function) [deprecated soon]  
CT_Await uses [deasync](https://www.npmjs.com/package/deasync) to expose loopWhile method, you can use this one to make sync an async function.  
[UPDATE], This is kinda buggy and will be deprecated soon

### CT_DateFormat(integer epoch[,format])
This method uses [dateformat](https://www.npmjs.com/package/dateformat); Receives an epoch timestamp and returns it in the resired format. If no format is provided dateFormat.masks.default is used.  

### CT_LoadController(string controller)
This method receives a reference to the controller file, ChaiTea will look for and include the desired controller. The controller file must be inside ```./app/controllers/``` folder and be named like this: ```<reference>_controller.coffee```.  

### CT_LoadModel(string model)
Similar to CT_LoadController method, this method will look for and include the desired model. The model file must be inside ```./app/models/``` folder and be named like this: ```<reference>_model.coffee```.  

### CT_StringToDate(string HTML5DATE)
Use this method to parse an HTML5 format date (from ```<input type=date>```) and returns a Date object.  

### CT_Infusion(object recipe)
Infusion need an object recipe and make every element available globally.  
The recipe object can define methods, variables, objects, etc. Eg:  

	CT_Infusion {
		request : require 'request'
		days    : {
			ES : ['Lun','Mar','Mie','Jue','Vie','Sab','Dom']
			EN : ['Mon','Tue','Wed','Thu','Fri','Sat','Sun]
		}
		globalModel : CT_LoadModel 'my_superModel'
		addCommas : (x)->
			return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
	}

In this example, after calling CT_Infusion, you can have access to ```request``` module globally inside your app,controllers,models, and any other included file. Aswell as an object of days in Spanish and English, a model loaded in memory to call anywhere (even inside other models) and a quick method called ```addCommas``` that can translate any integer into a comma separated integer (12345 => 12,345).  

### CT_Routes([string file,] function callback)  
If you are like me, you dont want to see all the routes inside the main.coffee app file. with this method, you can send all your routes to another file and call them before starting the server. If no file reference is provided, it will load ```./routes.coffee``` file.
When the routes are loaded, a callback is fired and you can continue with normal execution.  

## Release Notes

- 1.0.17 -> payloadSize can be defined on config.json to allow Request entity too large  
- 1.0.16 -> Introducing CT_Static and deprecating config.static  
- 1.0.15 -> Deprecating CT_Await
- 1.0.14 -> Added Readme and warning to future deprecated CT_Await  
- 1.0.13 -> Adding HTTPS Support  
- 1.0.12 -> CT_Assets are now a thing!  
- 1.0.10 -> CT_Routes to define the routes in a sepparated file  
- anythingBefore -> nightly build  

## 10Q
If you are this far, thanks for reading! 

EOF
