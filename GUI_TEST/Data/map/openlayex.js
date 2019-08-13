OpenLayers.Layer.Yandex = OpenLayers.Class(OpenLayers.Layer.EventPane, OpenLayers.Layer.FixedZoomLevels, {
	MIN_ZOOM_LEVEL: 0,
	MAX_ZOOM_LEVEL: 17,
	RESOLUTIONS: [1.40625, 0.703125, 0.3515625, 0.17578125, 0.087890625, 0.0439453125, 0.02197265625, 0.010986328125, 0.0054931640625, 0.00274658203125, 0.001373291015625, 0.0006866455078125, 0.00034332275390625, 0.000171661376953125, 0.0000858306884765625, 0.00004291534423828125, 0.00002145767211914062, 0.00001072883605957031, 0.00000536441802978515, 0.00000268220901489257],
	type: null,
	sphericalMercator: false,
	dragObject: null,
	initialize: function(name, options) {
		OpenLayers.Layer.EventPane.prototype.initialize.apply(this, arguments);
		OpenLayers.Layer.FixedZoomLevels.prototype.initialize.apply(this, arguments);
		if (this.sphericalMercator) {
			OpenLayers.Util.extend(this, OpenLayers.Layer.SphericalMercator);
			this.initMercatorParameters();
		}
	},
	loadMapObject: function() {
		try {
			this.mapObject = new YMaps.Map(this.div);
			this.dragObject = this.mapObject;
		} catch(e) {
			OpenLayers.Console.error(e);
		}
	},
	setMap: function(map) {
		OpenLayers.Layer.EventPane.prototype.setMap.apply(this, arguments);
		if (this.type != null) {
			this.map.events.register("moveend", this, this.setType);
		}
	},
	setType: function() {
		if (this.mapObject.getCenter() != null) {
			this.mapObject.setType(this.type);
			this.mapObject.redraw();
			this.map.events.unregister("moveend", this, this.setType);
		}
	},
	onMapResize: function() {
		this.mapObject.redraw();
	},
	getOLBoundsFromMapObjectBounds: function(moBounds) {
		var olBounds = null;
		if (moBounds != null) {
			var sw = moBounds.getSouthWest();
			var ne = moBounds.getNorthEast();
			if (this.sphericalMercator) {
				sw = this.forwardMercator(sw.lng(), sw.lat());
				ne = this.forwardMercator(ne.lng(), ne.lat());
			} else {
				sw = new OpenLayers.LonLat(sw.lng(), sw.lat());
				ne = new OpenLayers.LonLat(ne.lng(), ne.lat());
			}
			olBounds = new OpenLayers.Bounds(sw.lon, sw.lat, ne.lon, ne.lat);
		}
		return olBounds;
	},
	getMapObjectBoundsFromOLBounds: function(olBounds) {
		var moBounds = null;
		if (olBounds != null) {
			var sw = this.sphericalMercator ? this.inverseMercator(olBounds.bottom, olBounds.left) : new OpenLayers.LonLat(olBounds.bottom, olBounds.left);
			var ne = this.sphericalMercator ? this.inverseMercator(olBounds.top, olBounds.right) : new OpenLayers.LonLat(olBounds.top, olBounds.right);
			moBounds = new GLatLngBounds(new GLatLng(sw.lat, sw.lon), new GLatLng(ne.lat, ne.lon));
		}
		return moBounds;
	},
	addContainerPxFunction: function() {},
	getWarningHTML: function() {
		return OpenLayers.i18n("googleWarning");
	},
	setMapObjectCenter: function(center, zoom) {
		this.mapObject.setCenter(center, zoom);
	},
	dragPanMapObject: function(dX, dY) {
		this.dragObject.moveBy(new YMaps.Point(dX, -dY), false);
	},
	getMapObjectCenter: function() {
		return this.mapObject.getCenter();
	},
	getMapObjectZoom: function() {
		return this.mapObject.getZoom();
	},
	getMapObjectLonLatFromMapObjectPixel: function(moPixel) {
		return this.mapObject.converter.mapPixelsToCoordinates(this.mapObject.converter.localPixelsToMapPixels(moPixel));
	},
	getMapObjectPixelFromMapObjectLonLat: function(moLonLat) {
		return this.mapObject.converter.mapPixelsToLocalPixels(this.mapObject.converter.coordinatesToMapPixels(moLonLat));
	},
	getMapObjectZoomFromMapObjectBounds: function(moBounds) {
		return this.mapObject.getBounds(moBounds);
	},
	getLongitudeFromMapObjectLonLat: function(moLonLat) {
		return this.sphericalMercator ? this.forwardMercator(moLonLat.getLng(), moLonLat.getLat()).lon: moLonLat.getLng();
	},
	getLatitudeFromMapObjectLonLat: function(moLonLat) {
		var lat = this.sphericalMercator ? this.forwardMercator(moLonLat.getLng(), moLonLat.getLat()).lat: moLonLat.getLat();
		return lat;
	},
	getMapObjectLonLatFromLonLat: function(lon, lat) {
		var gLatLng;
		if (this.sphericalMercator) {
			var lonlat = this.inverseMercator(lon, lat);
			gLatLng = new YMaps.GeoPoint(lonlat.lon, lonlat.lat);
		} else {
			gLatLng = new YMaps.GeoPoint(lon, lat);
		}
		return gLatLng;
	},
	getXFromMapObjectPixel: function(moPixel) {
		return moPixel.x;
	},
	getYFromMapObjectPixel: function(moPixel) {
		return moPixel.y;
	},
	getMapObjectPixelFromXY: function(x, y) {
		return new YMaps.Point(x, y);
	},
	CLASS_NAME: "OpenLayers.Layer.Yandex"
});

OpenLayers.Layer.IngitMaps = OpenLayers.Class.create();
OpenLayers.Layer.IngitMaps.prototype = OpenLayers.Class.inherit(OpenLayers.Layer.TMS, {
	layers: "",
	quality: "",		
	maxExtent: new OpenLayers.Bounds(-20037508.342789,-20037508.342789,20037508.342789,20037508.342789),	
	attribution: '',
	url: "",
	urls: [],
	buffer: 1,
	map_type: "MAP",
	transitionEffect: null,
	initialize: function(name, params, options) {
		this.isBaseLayer = true;
		if (params.map_type) {
			this.map_type = params.map_type; 			
		}		
		OpenLayers.Layer.TMS.prototype.initialize.apply(this, arguments);		
	},
	getURL: function(bounds) {		
		var res = this.map.getResolution();
		var maxExtent = this.maxExtent;
		var tileW = (this.tileSize)?this.tileSize.w:256;
		var tileH = (this.tileSize)?this.tileSize.h:256;
		var x = Math.round((bounds.left - maxExtent.left)/(res * tileW));
		var y = Math.round((maxExtent.top - bounds.top)/(res * tileH));
		var z = this.map.getZoom();var limit = Math.pow(2, z);
		if (y <0 || y>= limit) {			
			return OpenLayers.Util.getImagesLocation() + "404.png";
		} else {
			x = ((x % limit) + limit) % limit;			
			
			scale = (1/(((Math.pow(2,z)*256)/(2*Math.PI))/(6366752*Math.cos(0*(Math.PI/180) ))))*3600;
			ld2 = Math.round((Math.pow(2,z)*256)/2);
            cx = ld2-(x*256);
            cy = ld2-(y*256);
			
			NumTiles = Math.pow(2,z);
			BitmapSize = NumTiles*256;
			BitmapOrigo = BitmapSize/2;
			
			PixelsPerLonDegree = BitmapSize/360;
			PixelsPerLonRadian = BitmapSize/(2*Math.PI);
			
			Lon0 = ((x-1)*256 - BitmapOrigo) / PixelsPerLonDegree;			
			Lat0 = (2 * Math.atan(Math.exp(-((y-1)*256 - BitmapOrigo) / PixelsPerLonRadian)) - Math.PI/2) * 180/Math.PI;
			
			Lon1 = (x*256 - BitmapOrigo) / PixelsPerLonDegree;			
			Lat1 = (2 * Math.atan(Math.exp(-(y*256 - BitmapOrigo) / PixelsPerLonRadian)) - Math.PI/2) * 180/Math.PI;
									
			LonMin = Math.min(Lon0,Lon1);
			LatMin = Math.min(Lat0,Lat1);
			LonMax = Math.max(Lon0,Lon1);
			LatMax = Math.max(Lat0,Lat1);
			
			map_name = "world_x.chart";			
			
			url = "http://maps.ingit.ru/bin/GWCgi.exe?cmd=img&map="+map_name+"&w=256&h=256&dpm=3600&long=0&lat=0&conv=mrc"+			
            "&scale=" + Math.round(scale) +
            "&xc=" + cx +
            "&yc=" + cy + "&cache";			
			
			return url;
		}
	},
	clone: function(obj) {
		if (obj == null) {
			obj = new OpenLayers.Layer.IngitMaps(this.name, this.params, this.options);
		}
		obj = OpenLayers.Layer.TMS.prototype.clone.apply(this, [obj]);		
		return obj;
	},
	CLASS_NAME: "OpenLayers.Layer.IngitMaps"
});

/*OpenLayers.Layer.WebGIS = OpenLayers.Class.create();
OpenLayers.Layer.WebGIS.prototype = OpenLayers.Class.inherit(OpenLayers.Layer.TMS, {
	layers: "",
	quality: "",
	map_tags: "",
	url_params: "",
	res_name: "/map_gmaps",
	url: "",
	urls: [],
	buffer: 1,
	transitionEffect: null,
	initialize: function(name, url, params, options) {
		this.isBaseLayer = true;
		this.url = url;
		this.urls = [];
		OpenLayers.Layer.TMS.prototype.initialize.apply(this, arguments);
		var arr = this.url.split(",");
		if (arr.length >= 2) {
			for (var i = 0; i < arr.length; i++)
			this.urls.push(arr[i]);
			this.url = arr[0];
		}
	},
	getURL: function(bounds) {
		var res = this.map.getResolution();
		var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
		var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
		var z = this.map.getZoom();
		var limit = Math.pow(2, z);
		if (y < 0 || y >= limit || z > 20) {
			return OpenLayers.Util.getImagesLocation() + "404.png";
		} else {
			x = ((x % limit) + limit) % limit;
			var url = this.url;
			if (this.urls.length >= 2) {
				var index = x % this.urls.length;
				url = this.urls[Math.floor(index)];
			}
			url += this.res_name + "?x=" + x + "&y=" + y + "&zoom=" + (17 - z) + "&v=" + this.layers + "&w=" + this.tileSize.w + "&h=" + this.tileSize.h + "&q=" + this.quality + "&m=" + this.map_tags;
			if (this.url_params != "") url += "&" + this.url_params;
			return url;
		}
	},
	clone: function(obj) {
		if (obj == null) {
			obj = new OpenLayers.Layer.WebGIS(this.name, this.url, this.params, this.options);
		}
		obj = OpenLayers.Layer.TMS.prototype.clone.apply(this, [obj]);
		obj.url = this.urls.length ? this.urls[0] : "";
		obj.urls = this.urls;
		return obj;
	},
	CLASS_NAME: "OpenLayers.Layer.WebGIS"
});
*/
OpenLayers.Layer.WebGIS = OpenLayers.Class.create();
OpenLayers.Layer.WebGIS.prototype = OpenLayers.Class.inherit(OpenLayers.Layer.TMS, {
    layers: "",
    quality: "",
    map_tags: "",
    url_params: "",
    res_name: "/map_gmaps",
    url: "",
    urls: [],
    buffer: 1,
    transitionEffect: null,
    initialize: function (name, url, params, options) {
        this.isBaseLayer = true;
        this.url = url;
        this.urls = [];
        OpenLayers.Layer.TMS.prototype.initialize.apply(this, arguments);
        var arr = this.url.split(",");
        if (arr.length >= 2) {
            for (var i = 0; i < arr.length; i++)
            this.urls.push(arr[i]);
            this.url = arr[0];
        }
    },
    getURL: function (bounds) {
        var res = this.map.getResolution();
        var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
        var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
        var z = this.map.getZoom();
        var limit = Math.pow(2, z);
        if (y < 0 || y >= limit || z > 20) {
            return OpenLayers.Util.getImagesLocation() + "404.png";
        } else {
            x = ((x % limit) + limit) % limit;
            var url = this.url;
            if (this.urls.length >= 2) {
                var index = x % this.urls.length;
                url = this.urls[Math.floor(index)];
            }
            url += this.res_name + "?x=" + x + "&y=" + y + "&zoom=" + (17 - z) + "&v=" + this.layers + "&w=" + this.tileSize.w + "&h=" + this.tileSize.h + "&q=" + this.quality + "&m=" + this.map_tags;
            if (this.url_params != "") url += "&" + this.url_params;
            return url;
        }
    },
    clone: function (obj) {
        if (obj == null) {
            obj = new OpenLayers.Layer.WebGIS(this.name, this.url, this.params, this.options);
        }
        obj = OpenLayers.Layer.TMS.prototype.clone.apply(this, [obj]);
        obj.url = this.urls.length ? this.urls[0] : this.url;
        obj.urls = this.urls;
        return obj;
    },
    CLASS_NAME: "OpenLayers.Layer.WebGIS"
}); 

OpenLayers.Layer.YandexMaps = OpenLayers.Class.create();
OpenLayers.Layer.YandexMaps.prototype = OpenLayers.Class.inherit(OpenLayers.Layer.TMS, {
	layers: "",
	quality: "",	
	maxExtent: new OpenLayers.Bounds(-20037508,-20002151,20037508,20072865),	
	attribution: '<a href="http://maps.yandex.ru/">Яндекс.Карты</a>',
	url: "",
	urls: [],
	buffer: 1,
	map_type: "MAP",
	transitionEffect: null,
	initialize: function(name, params, options) {
		this.isBaseLayer = true;
		if (params.map_type) {
			this.map_type = params.map_type; 			
		}		
		OpenLayers.Layer.TMS.prototype.initialize.apply(this, arguments);		
	},
	getURL: function(bounds) {		
		var res = this.map.getResolution();
		var maxExtent = this.maxExtent;
		var tileW = (this.tileSize)?this.tileSize.w:256;
		var tileH = (this.tileSize)?this.tileSize.h:256;
		var x = Math.round((bounds.left - maxExtent.left)/(res * tileW));
		var y = Math.round((maxExtent.top - bounds.top)/(res * tileH));
		var z = this.map.getZoom();var limit = Math.pow(2, z);
		if (y <0 || y>= limit) {			
			return OpenLayers.Util.getImagesLocation() + "404.png";
		} else {
			x = ((x % limit) + limit) % limit;
			if (this.map_type=="SATELLITE") {
				url = "http://sat0"+(1+(x+y)%4)+".maps.yandex.ru/tiles?l=sat&v=1.9.0&x=" + x + "&y=" + y + "&z=" + z + ".jpg";
			} else if (this.map_type=="HYBRID") {
				url = "http://vec0"+(1+(x+y)%4)+".maps.yandex.ru/tiles?l=skl&v=2.6.0&x=" + x + "&y=" + y + "&z=" + z + ".png";
		    } else { // MAP
				url = "http://vec0"+(1+(x+y)%4)+".maps.yandex.ru/tiles?l=map&v=2.6.0&x=" + x + "&y=" + y + "&z=" + z + ".jpg";	
			}			
			
			return url;
		}
	},
	clone: function(obj) {
		if (obj == null) {
			obj = new OpenLayers.Layer.YandexMaps(this.name, this.params, this.options);
		}
		obj = OpenLayers.Layer.TMS.prototype.clone.apply(this, [obj]);		
		return obj;
	},
	CLASS_NAME: "OpenLayers.Layer.YandexMaps"
});

OpenLayers.Layer.VEMaps = OpenLayers.Class.create();
OpenLayers.Layer.VEMaps.prototype = OpenLayers.Class.inherit(OpenLayers.Layer.TMS, {
	layers: "",
	quality: "",	
	maxExtent: new OpenLayers.Bounds(-20037508.342789,-20037508.342789,20037508.342789,20037508.342789),	
	attribution: '<a href="http://www.bing.com/maps/">Bing</a>',
	url: "",
	urls: [],
	buffer: 1,
	map_type: "MAP",
	transitionEffect: null,
	initialize: function(name, params, options) {
		this.isBaseLayer = true;
		if (params.map_type) {
			this.map_type = params.map_type; 			
		}		
		OpenLayers.Layer.TMS.prototype.initialize.apply(this, arguments);		
	},
	getURL: function(bounds) {		
		var res = this.map.getResolution();
		var maxExtent = this.maxExtent;
		var tileW = (this.tileSize)?this.tileSize.w:256;
		var tileH = (this.tileSize)?this.tileSize.h:256;
		var x = Math.round((bounds.left - maxExtent.left)/(res * tileW));
		var y = Math.round((maxExtent.top - bounds.top)/(res * tileH));
		var z = this.map.getZoom();var limit = Math.pow(2, z);
		if (y <0 || y>= limit) {			
			return OpenLayers.Util.getImagesLocation() + "404.png";
		} else {
			x = ((x % limit) + limit) % limit;
			var sTile = '000000';
			sTile += (parseInt(y.toString(2) * 2) +	parseInt(x.toString(2)));
			sTile = sTile.substring(sTile.length - z, sTile.length);
			
			if (this.map_type=="SATELLITE") {				
				url = 'http://a'
				url += sTile.substring(sTile.length-1, sTile.length);
				url += '.ortho.tiles.virtualearth.net/tiles/a'
				url += sTile;
				url += '.jpeg?g=1';				
			} else if (this.map_type=="HYBRID") {
				url = 'http://h'
				url += sTile.substring(sTile.length-1, sTile.length);
				url += '.ortho.tiles.virtualearth.net/tiles/h'
				url += sTile;
				url += '.jpeg?g=1';
		    } else { // MAP				
				url = 'http://r'
				url += sTile.substring(sTile.length-1, sTile.length);
				url += '.ortho.tiles.virtualearth.net/tiles/r'
				url += sTile;
				url += '.jpeg?g=1';	
			}			
			
			return url;
		}
	},
	clone: function(obj) {
		if (obj == null) {
			obj = new OpenLayers.Layer.VEMaps(this.name, this.params, this.options);
		}
		obj = OpenLayers.Layer.TMS.prototype.clone.apply(this, [obj]);		
		return obj;
	},
	CLASS_NAME: "OpenLayers.Layer.VEMaps"
});

OpenLayers.Layer.YahooMaps = OpenLayers.Class.create();
OpenLayers.Layer.YahooMaps.prototype = OpenLayers.Class.inherit(OpenLayers.Layer.TMS, {
	layers: "",
	quality: "",	
	maxExtent: new OpenLayers.Bounds(-20037508.342789,-20037508.342789,20037508.342789,20037508.342789),	
	attribution: '<a href="http://maps.yahoo.com//">Yahoo maps</a>',
	url: "",
	urls: [],
	buffer: 1,
	map_type: "MAP",
	transitionEffect: null,
	initialize: function(name, params, options) {
		this.isBaseLayer = true;
		if (params.map_type) {
			this.map_type = params.map_type; 			
		}		
		OpenLayers.Layer.TMS.prototype.initialize.apply(this, arguments);		
	},
	getURL: function(bounds) {		
		var res = this.map.getResolution();
		var maxExtent = this.maxExtent;
		var tileW = (this.tileSize)?this.tileSize.w:256;
		var tileH = (this.tileSize)?this.tileSize.h:256;
		var x = Math.round((bounds.left - maxExtent.left)/(res * tileW));
		var y = Math.round((maxExtent.top - bounds.top)/(res * tileH));
		var z = this.map.getZoom();var limit = Math.pow(2, z);
		if (y <0 || y>= limit) {			
			return OpenLayers.Util.getImagesLocation() + "404.png";
		} else {
			x = ((x % limit) + limit) % limit;			
			if (this.map_type=="SATELLITE") {
				url = "http://maps.yimg.com/ae/ximg?v=1.9&t=a&s=256&.intl=en";				
			} else if (this.map_type=="HYBRID") {
				url = "http://maps.yimg.com/hx/tl?v=4.2&t=h&.intl=en";
		    } else { // MAP
				url = "http://maps.yimg.com/hx/tl?v=4.2&.intl=en";
			}
			
			url += "&x=" + x + "&y=" + (((1 << z) >> 1)-1-y) + "&z=" + (z+1) + "&r=1";
			
			return url;
		}
	},
	clone: function(obj) {
		if (obj == null) {
			obj = new OpenLayers.Layer.YahooMaps(this.name, this.params, this.options);
		}
		obj = OpenLayers.Layer.TMS.prototype.clone.apply(this, [obj]);		
		return obj;
	},
	CLASS_NAME: "OpenLayers.Layer.YahooMaps"
});

OpenLayers.Handler.PathEx = OpenLayers.Class(OpenLayers.Handler.Path, {
    vertices: null,
    lastStyle: null,
    textOffset: 10,
    textStyle: {
        fillColor: "#0000EE",
        fillOpacity: 1,
        hoverFillColor: "#0000EE",
        strokeColor: "#0000EE",
        strokeWidth: 1,
        fontSize: 12
    },
    vertexIndex: -1,
    vertexInsertIndex: -1,
    hoverIndex: -1,
    hoverTimeout: 300,
    hoverTimerId: null,
    fullRepaint: false,
    offset: 4,
    initialize: function(control, callbacks, options) {
        OpenLayers.Handler.Path.prototype.initialize.apply(this, arguments);
    },
    setCursor: function(cur) {
        if (this.map.div.style.cursor != cur) this.map.div.style.cursor = (cur == "" ? "default": cur);
    },
    intersectsLine: function(pt1, pt2, pt3) {
        if (!pt1 || !pt2 || !pt3) {
            return false;
        }
        var pnt1x = pt1.lat;
        var pnt1y = pt1.lon;
        var pnt2x = pt2.lat;
        var pnt2y = pt2.lon;
        var pnt_from_x = pt3.lat;
        var pnt_from_y = pt3.lon;
        var pt = {
            lon: 0.0,
            lat: 0.0
        };
        if (pnt1x == pnt2x && pnt1y == pnt2y) {
            pt.lon = ((pnt1y + pnt2y) / 2);
            pt.lat = ((pnt1x + pnt2x) / 2);
            return new OpenLayers.LonLat(pt.lon, pt.lat);
        }
        var x_int, y_int;
        if (pnt1x != pnt2x) {
            var a = (pnt1y - pnt2y) / (pnt1x - pnt2x);
            var b = pnt1y - pnt1x * a;
            x_int = (pnt_from_x + a * pnt_from_y - a * b) / (a * a + 1.0);
            y_int = x_int * a + b;
        } else {
            var a = (pnt1x - pnt2x) / (pnt1y - pnt2y);
            var b = pnt1x - pnt1y * a;
            y_int = (pnt_from_y + a * pnt_from_x - a * b) / (a * a + 1.0);
            x_int = y_int * a + b;
        }
        pt.lon = y_int;
        pt.lat = x_int;
        var check_int = false;
        if (x_int < pnt1x && x_int < pnt2x) check_int = true;
        if (x_int > pnt1x && x_int > pnt2x) check_int = true;
        if (y_int < pnt1y && y_int < pnt2y) check_int = true;
        if (y_int > pnt1y && y_int > pnt2y) check_int = true;
        if (!check_int) {
            return new OpenLayers.LonLat(pt.lon, pt.lat);
        }
        var range = Math.sqrt((pnt_from_x - pnt1x) * (pnt_from_x - pnt1x) + (pnt_from_y - pnt1y) * (pnt_from_y - pnt1y));
        pt.lon = pnt1y;
        pt.lat = pnt1x;
        var range2 = Math.sqrt((pnt_from_x - pnt2x) * (pnt_from_x - pnt2x) + (pnt_from_y - pnt2y) * (pnt_from_y - pnt2y));
        if (range2 < range) {
            range = range2;
            pt.lon = pnt2y;
            pt.lat = pnt2x;
        }
        return new OpenLayers.LonLat(pt.lon, pt.lat);
    },
    setStyle: function(def_style, last_style) {
        this.style = def_style;
        this.lastStyle = last_style;
        this.fullRepaint = true;
        for (var i = 0; this.vertices && i < this.vertices.length; i++) {
            var zoom_radius = this.vertices[i].geometry.radius;
            if (this.event_disp && typeof this.event_disp.getWidthPxFromM == "function") zoom_radius = this.event_disp.getWidthPxFromM(this.vertices[i].geometry.radius * 2);
            this.vertices[i].geometry.zoom_radius = zoom_radius;
        }
        this.drawFeature();
    },
    createFeature: function() {
        this.line = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.LineString());
        this.point = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point());
        this.vertices = new Array();
    },
    setPointText: function(pointIndex, text) {
        if (pointIndex < this.vertices.length) {
            //this.vertices[pointIndex].text.geometry.text = text;
            //this.vertices[pointIndex].text.geometry.draw = false;
            this.drawFeature();
        }
    },
    setPointTextWithoutRedraw: function(pointIndex, text) {
        if (pointIndex < this.vertices.length) {
            this.textStyle.s
            //this.vertices[pointIndex].text.geometry.text = text;
            //this.vertices[pointIndex].text.geometry.draw = false;
        }
    },
    setPointRadius: function(pointIndex, radius) {
        if (pointIndex < this.vertices.length) {
            var zoom_radius = radius;
            if (radius != -1 && this.event_disp && typeof this.event_disp.getWidthPxFromM == "function") zoom_radius = this.event_disp.getWidthPxFromM(radius * 2);
            this.vertices[pointIndex].geometry.radius = radius;
            this.vertices[pointIndex].geometry.zoom_radius = zoom_radius;
            this.drawFeature();
        }
    },
    destroyFeature: function() {
        OpenLayers.Handler.Path.prototype.destroyFeature.apply(this);
        if (this.vertices) {
            for (i = 0; i < this.vertices.length; i++)
            this.vertices[i].destroy();
            this.vertices = null;
        }
    },
    modifyFeature: function() {
        if (this.vertexIndex == -1 || !this.line || !this.vertices || !this.line.geometry.components.length || !this.vertices.length || this.line.geometry.components.length < this.vertices.length) return;
        this.line.geometry.components[this.vertexIndex].x = this.point.geometry.x;
        this.line.geometry.components[this.vertexIndex].y = this.point.geometry.y;
        this.line.geometry.components[this.vertexIndex].clearBounds();
        this.vertices[this.vertexIndex].geometry.x = this.point.geometry.x;
        this.vertices[this.vertexIndex].geometry.y = this.point.geometry.y;
    },
    drawFeature: function() {
        if (!this.layer) return;
        if (!this.lastStyle) this.lastStyle = this.style;
        if (this.line && this.style) {
            this.layer.drawFeature(this.line, this.style);
        }
        if (this.vertices) {
            for (i = 0; i < this.vertices.length; i++) {
                st = (i == this.vertices.length - 1) ? this.lastStyle: this.style;
                var old_radius = st.strokeWidth;
                if (typeof this.vertices[i].geometry.radius != "undefined" && this.vertices[i].geometry.radius > 0) st.strokeWidth = this.vertices[i].geometry.zoom_radius;
                this.layer.drawFeature(this.vertices[i], st);
                st.strokeWidth = old_radius;
                /*if (!this.vertices[i].text.geometry.draw || this.fullRepaint) {
                    this.vertices[i].text.geometry.x = this.vertices[i].geometry.x + this.textOffset;
                    this.vertices[i].text.geometry.y = this.vertices[i].geometry.y;
                    this.layer.drawFeature(this.vertices[i].text, this.textStyle);
                    this.vertices[i].text.geometry.draw = true;
                }*/
            }
            this.fullRepaint = false;
        }
    },
    setPoints: function(points) {
        if (!points || !points.length) return;
        this.destroyFeature();
        this.createFeature();
        this.line.geometry.addComponents(points);
        for (var i = 0; i < this.line.geometry.components.length; i++) {
            vertex = new OpenLayers.Feature.Vector(this.line.geometry.components[i].clone());
            //vertex.text = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Text());
            //vertex.text.geometry.text = "";
            //vertex.text.geometry.text.draw = false;
            this.vertices.push(vertex);
        }
        this.drawFeature();
    },
    getPoints: function() {
        if (this.line) {
            var points = new Array;
            for (var i = 0; i < this.line.geometry.components.length; i++) {
                points.push(this.line.geometry.components[i].clone());
            }
            return points;
        }
        return null;
    },
    drawPoint: function() {
        this.layer.drawFeature(this.point, this.style);
    },
    addPoint: function() {
        if (this.line && this.point) this.line.geometry.addComponent(this.point.geometry.clone(), this.line.geometry.components.length);
        if (!this.vertices) this.vertices = new Array();
        vertex = new OpenLayers.Feature.Vector(this.point.geometry.clone());
        //vertex.text = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Text());
        //vertex.text.geometry.text = "";
        //vertex.text.geometry.text.draw = false;
        this.vertices.push(vertex);
        this.callback("point", [this.point.geometry]);
        if (this.event_disp && typeof this.event_disp.on_point_add == "function") this.event_disp.on_point_add();
    },
    insertPoint: function() {
        var index = this.vertexInsertIndex;
        if (index < 0) return;
        if (this.line && this.point) {
            this.line.geometry.addComponent(this.point.geometry.clone(), index + 1);
            vertex = new OpenLayers.Feature.Vector(this.point.geometry.clone());
            //vertex.text = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Text());
            //vertex.text.geometry.text = "";
            //vertex.text.geometry.text.draw = false;
            if (index < this.vertices.length) {
                var v1 = this.vertices.slice(0, index + 1);
                var v2 = this.vertices.slice(index + 1, this.vertices.length);
                v1.push(vertex);
                this.vertices = v1.concat(v2);
            } else {
                this.vertices.push(vertex);
            }
            this.callback("point", [this.point.geometry]);
            if (this.event_disp && typeof this.event_disp.on_point_insert == "function") this.event_disp.on_point_insert(index);
        }
    },
    removePoint: function() {
        if (this.vertexIndex == -1 || !this.line || !this.vertices || this.line.geometry.components.length <= 2 || this.vertices.length <= 2 || this.line.geometry.components.length < this.vertices.length) return;
        this.line.geometry.removeComponent(this.line.geometry.components[this.vertexIndex]);
        this.layer.removeFeatures([this.vertices[this.vertexIndex]]);
        //this.layer.removeFeatures([this.vertices[this.vertexIndex].text]);
        this.vertices.splice(this.vertexIndex, 1);
        if (this.event_disp && typeof this.event_disp.on_point_remove == "function") this.event_disp.on_point_remove(this.vertexIndex);
        this.vertexIndex = -1;
    },
    hittestPoint: function() {
        var res = OpenLayers.Handler.PathEx.HIT_NONE;
        this.vertexIndex = -1;
        this.vertexInsertIndex = -1;
        if (!this.point || !this.vertices) return res;
        var pt = new OpenLayers.LonLat(this.point.geometry.x, this.point.geometry.y);
        var px = this.map.getPixelFromLonLat(pt);
        var lonlat1 = null;
        var lonlat2 = null;
        for (var i = 0; i < this.vertices.length; i++) {
            lonlat2 = new OpenLayers.LonLat(this.vertices[i].geometry.x, this.vertices[i].geometry.y);
            var vetrex_px = this.map.getPixelFromLonLat(lonlat2);
            var bounds = new OpenLayers.Bounds(vetrex_px.x - this.offset, vetrex_px.y - this.offset, vetrex_px.x + this.offset, vetrex_px.y + this.offset)
            if (bounds.containsPixel(px)) {
                this.vertexIndex = i;
                res = OpenLayers.Handler.PathEx.HIT_POINT;
                break;
            }
            if (i != 0 && lonlat1 && lonlat2) {
                var point = this.intersectsLine(lonlat1, lonlat2, pt);
                var vetrex_px2 = this.map.getPixelFromLonLat(point);
                var bounds2 = new OpenLayers.Bounds(vetrex_px2.x - this.offset, vetrex_px2.y - this.offset, vetrex_px2.x + this.offset, vetrex_px2.y + this.offset);
                if (bounds2.containsPixel(px)) {
                    this.vertexInsertIndex = i - 1;
                    res = OpenLayers.Handler.PathEx.HIT_LINE;
                    break;
                }
            }
            lonlat1 = lonlat2;
        }
        if (res == OpenLayers.Handler.PathEx.HIT_NONE && this.vertices.length >= 2) {
            lonlat1 = new OpenLayers.LonLat(this.vertices[0].geometry.x, this.vertices[0].geometry.y);
            lonlat2 = new OpenLayers.LonLat(this.vertices[this.vertices.length - 1].geometry.x, this.vertices[this.vertices.length - 1].geometry.y);
            if (lonlat1 && lonlat2) {
                var point = this.intersectsLine(lonlat1, lonlat2, pt);
                var vetrex_px2 = this.map.getPixelFromLonLat(point);
                var bounds2 = new OpenLayers.Bounds(vetrex_px2.x - this.offset, vetrex_px2.y - this.offset, vetrex_px2.x + this.offset, vetrex_px2.y + this.offset);
                if (bounds2.containsPixel(px)) {
                    this.vertexInsertIndex = this.vertices.length - 1;
                    res = OpenLayers.Handler.PathEx.HIT_LINE;
                }
            }
        }
        return res;
    },
    isVertex: function() {
        return (this.vertexIndex != -1);
    },
    isInsertVertex: function() {
        return (this.vertexInsertIndex != -1);
    },
    geometryClone: function() {
        return this.line.geometry.clone();
    },
    mousedown: function(evt) {
        if (this.lastDown && this.lastDown.equals(evt.xy)) {
            return true;
        }
        this.mouseDown = true;
        this.lastDown = evt.xy;
        if (!this.point && !this.line) {
            this.createFeature();
        }
        if (this.point) {
            var lonlat = this.control.map.getLonLatFromPixel(evt.xy);
            this.point.geometry.x = lonlat.lon;
            this.point.geometry.y = lonlat.lat;
        }
        if (this.isVertex()) {
            return false;
        }
        this.reset_hover();
        return true;
    },
    mousemove: function(evt) {
        if (this.point) {
            var lonlat = this.map.getLonLatFromPixel(evt.xy);
            this.point.geometry.x = lonlat.lon;
            this.point.geometry.y = lonlat.lat;
        }
        if (this.mouseDown) {
            this.reset_hover();
            if (this.isVertex()) {
                this.modifyFeature();
                this.drawFeature();
                return false;
            }
        } else {
            if (this.event_disp && typeof this.event_disp.on_mouse_move == "function") {
                this.event_disp.on_mouse_move(evt.xy, lonlat);
            }
            res = this.hittestPoint();
            if (res == OpenLayers.Handler.PathEx.HIT_NONE) {
                this.setCursor("default");
            } else if (res == OpenLayers.Handler.PathEx.HIT_POINT) {
                this.setCursor("pointer");
                if (this.hoverIndex == -1 || this.hoverIndex != this.vertexIndex) {
                    if (this.hoverTimerId) window.clearTimeout(this.hoverTimerId);
                    this.hoverTimerId = window.setTimeout(OpenLayers.Function.bind(this.on_hover, this), this.hoverTimeout);
                }
            } else if (res == OpenLayers.Handler.PathEx.HIT_LINE) {
                this.setCursor("crosshair");
            }
        }
        if (this.vertexIndex == -1 && this.hoverTimerId) {
            this.reset_hover();
        }
        return true;
    },
    on_hover: function() {
        this.hoverTimerId = null;
        if (this.vertexIndex == -1) return;
        this.hoverIndex = this.vertexIndex;
        if (this.event_disp && typeof this.event_disp.on_point_hover == "function") {
            this.event_disp.on_point_hover(this.hoverIndex, this.vertices[this.hoverIndex].geometry.x, this.vertices[this.hoverIndex].geometry.y);
        }
    },
    reset_hover: function() {
        if (this.hoverTimerId) {
            window.clearTimeout(this.hoverTimerId);
            this.hoverTimerId = null;
        }
        if (this.hoverIndex != -1) {
            if (this.event_disp && typeof this.event_disp.on_point_hover == "function") this.event_disp.on_point_hover( - 1);
            this.hoverIndex = -1;
        }
    },
    mouseup: function(evt) {
        this.mouseDown = false;
        this.lastUp = evt.xy;
        if (this.isVertex()) {
            //if (typeof this.vertices[this.vertexIndex].text != "undefined") this.vertices[this.vertexIndex].text.geometry.draw = false;
            this.drawFeature();
            if (this.event_disp && typeof this.event_disp.on_point_modified == "function") {
                this.event_disp.on_point_modified(this.vertexIndex, this.vertices[this.vertexIndex].geometry.x, this.vertices[this.vertexIndex].geometry.y);
            }
        }
        return true;
    },
    dblclick: function(evt) {
        this.reset_hover();
        if (evt.ctrlKey) {
            this.finalize();
            return false;
        }
        if (this.isVertex()) {
            this.removePoint();
        } else {
            if (this.isInsertVertex()) {
                this.insertPoint();
            } else {
                this.addPoint();
            }
        }
        this.drawFeature();
        this.drawing = true;
        return false;
    },
    CLASS_NAME: "OpenLayers.Handler.PathEx"
});
OpenLayers.Handler.PathEx.HIT_NONE = 0;
OpenLayers.Handler.PathEx.HIT_POINT = 1;
OpenLayers.Handler.PathEx.HIT_LINE = 2;
OpenLayers.Handler.PolygonEx = OpenLayers.Class(OpenLayers.Handler.PathEx, {
    polygon: null,
    initialize: function(control, callbacks, options) {
        OpenLayers.Handler.PathEx.prototype.initialize.apply(this, arguments);
    },
    createFeature: function() {
        this.polygon = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Polygon());
        this.line = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.LinearRing());
        this.polygon.geometry.addComponent(this.line.geometry);
        this.point = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point());
        this.vertices = new Array();
    },
    destroyFeature: function() {
        OpenLayers.Handler.PathEx.prototype.destroyFeature.apply(this);
        if (this.polygon) {
            this.polygon.destroy();
        }
        this.polygon = null;
    },
    modifyFeature: function() {
        OpenLayers.Handler.PathEx.prototype.modifyFeature.apply(this);
    },
    drawFeature: function() {
        if (!this.layer) return;
        if (!this.lastStyle) this.lastStyle = this.style;
        if (this.polygon && this.style) this.layer.drawFeature(this.polygon, this.style);
        if (this.vertices) {
            for (i = 0; i < this.vertices.length; i++) {
                st = (i == this.vertices.length - 1) ? this.lastStyle: this.style;
                this.layer.drawFeature(this.vertices[i], st);
            }
        }
    },
    setPoints: function(points) {
        if (!points || !points.length) return;
        this.destroyFeature();
        this.createFeature();
        for (var i = 0; i < points.length; i++) {
            this.line.geometry.addComponent(points[i], this.line.geometry.components.length);
            vertex = new OpenLayers.Feature.Vector(points[i].clone());
            this.vertices.push(vertex);
        }
        this.drawFeature();
    },
    getPoints: function() {
        if (this.line) {
            var points = new Array;
            for (var i = 0; i < this.line.geometry.components.length - 1; i++) {
                points.push(this.line.geometry.components[i].clone());
            }
            return points;
        }
        return null;
    },
    removePoint: function() {
        if (this.vertexIndex == -1 || !this.line || !this.vertices || this.line.geometry.components.length <= 3 || this.vertices.length <= 3 || this.line.geometry.components.length < this.vertices.length) return;
        this.line.geometry.removeComponent(this.line.geometry.components[this.vertexIndex]);
        this.layer.removeFeatures([this.vertices[this.vertexIndex]]);
        this.vertices.splice(this.vertexIndex, 1);
        if (this.event_disp && typeof this.event_disp.on_point_remove == "function") this.event_disp.on_point_remove(this.vertexIndex);
        this.vertexIndex = -1;
    },
    geometryClone: function() {
        return this.polygon.geometry.clone();
    },
    CLASS_NAME: "OpenLayers.Handler.PolygonEx"
});

OpenLayers.Control.DisableDoubleClickControl = OpenLayers.Class(OpenLayers.Control, {
                defaultHandlerOptions: {
                    'single': false,
                    'double': false,
                    'pixelTolerance': 0,
                    'stopSingle': false,
                    'stopDouble': true
                },

                initialize: function(options) {
                    this.handlerOptions = OpenLayers.Util.extend(
                        {}, this.defaultHandlerOptions
                    );
                    OpenLayers.Control.prototype.initialize.apply(
                        this, arguments
                    ); 
                    this.handler = new OpenLayers.Handler.Click(
                        this, {
                            /*'click': this.trigger*/
                        }, this.handlerOptions
                    );
                }

            });