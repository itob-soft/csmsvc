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

