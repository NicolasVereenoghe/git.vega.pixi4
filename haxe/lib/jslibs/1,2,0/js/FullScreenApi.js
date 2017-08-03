(function(define) {
	define(function() { 
		
		var fullScreenApi = {
			supportsFullScreen: false,
			isFullScreen: function() { return false; },
			requestFullScreen: function() {},
			cancelFullScreen: function() {},
			fullScreenEventName: '',
			prefix: ''
		};
		
		var browserPrefixes = 'webkit moz o ms khtml'.split(' ');
		
		if (typeof document.cancelFullScreen != 'undefined')
		{
			fullScreenApi.supportsFullScreen = true;
		}
		else
		{
			// check for fullscreen support by vendor prefix
			for (var i = 0, il = browserPrefixes.length; i < il; i++ )
			{
				fullScreenApi.prefix = browserPrefixes[i];

				if (typeof document[fullScreenApi.prefix + 'CancelFullScreen' ] != 'undefined' )
				{
					fullScreenApi.supportsFullScreen = true;
					break;
				}
			}
		}
		
		if (fullScreenApi.supportsFullScreen) 
		{
			fullScreenApi.fullScreenEventName = fullScreenApi.prefix + 'fullscreenchange';
			
			fullScreenApi.isFullScreen = function() 
			{
				switch (this.prefix) 
				{
					case '':
						return document.fullScreen;
					case 'webkit':
						return document.webkitIsFullScreen;
					default:
						return document[this.prefix + 'FullScreen'];
				}
			};
			
			fullScreenApi.requestFullScreen = function(el) 
			{
				return (this.prefix === '') ? el.requestFullScreen() : el[this.prefix + 'RequestFullScreen']();
			};
			
			fullScreenApi.cancelFullScreen = function(el) 
			{
				return (this.prefix === '') ? document.cancelFullScreen() : document[this.prefix + 'CancelFullScreen']();
			};
		}
		
		return fullScreenApi;
	});
	
}(typeof define != "undefined" && define.amd ? define : typeof module != "undefined" && module.exports ? function(factory) { module.exports = factory(); } : function(factory) { window.fullScreenApi = factory(); }));