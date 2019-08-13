/* OL controls */
			
			OpenLayers.Layer.MapEPSG_900913  = OpenLayers.Class(OpenLayers.Layer.TMS, {
				type: "png",
				displayOutsideMaxExtent: true,
				layers: "",
				quality: "",		
				maxExtent: new OpenLayers.Bounds(-20037508.3427892,-20037508.3427892,20037508.3427892,20037508.3427892),	
				attribution: '',
				url: "",
				urls: [],
				buffer: 1,
				transitionEffect: null,
				initialize: function(name, params, options) {
					this.isBaseLayer = true;
					OpenLayers.Layer.TMS.prototype.initialize.apply(this, arguments);		
				},
				getTileAddress: function(bounds,x,y,z) {
					var subs = [ 'a', 'b', 'c' ];
					return "http://" + subs[(x+y)%3] + ".tile.openstreetmap.org/" + z + "/" + x + "/" + y + ".png";				
				},
				getURL: function(bounds) {		
					var res = this.map.getResolution();
					var maxExtent = this.maxExtent;
					var tileW = (this.tileSize)?this.tileSize.w:256;
					var tileH = (this.tileSize)?this.tileSize.h:256;
					var x = Math.round((bounds.left - maxExtent.left)/(res * tileW));
					var y = Math.round((maxExtent.top - bounds.top)/(res * tileH));
					var z = this.map.getZoom(); 
					var limit = Math.pow(2, z);
					if (y <0 || y>= limit) {			
						return OpenLayers.Util.getImagesLocation() + "404.png";
					} else {
									
						x = ((x % limit) + limit) % limit;			
												
						return this.getTileAddress(bounds,x,y,z);
					}
				},
				clone: function(obj) {
					if (obj == null) {
						obj = new OpenLayers.Layer.MapEPSG_900913(this.name, this.params, this.options);
					}
					obj = OpenLayers.Layer.TMS.prototype.clone.apply(this, [obj]);		
					return obj;
				},
				CLASS_NAME: "OpenLayers.Layer.MapEPSG_900913"
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
			
			OpenLayers.Handler.PathRouteEx = OpenLayers.Class(OpenLayers.Handler.Path, {
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
				allowAddPoints: true,
				fixVertexStyle: null,
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
					/*for (var i = 0; this.vertices && i < this.vertices.length; i++) {
						var zoom_radius = this.vertices[i].geometry.radius;
						if (this.event_disp && typeof this.event_disp.getWidthPxFromM == "function") zoom_radius = this.event_disp.getWidthPxFromM(this.vertices[i].geometry.radius * 2);
						this.vertices[i].geometry.zoom_radius = zoom_radius;
					}*/
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
				setPointParams: function(pointIndex, isFixPoint, pointId) {
					if (pointIndex < this.vertices.length) {
						this.vertices[pointIndex].isFixPoint = isFixPoint;
						this.vertices[pointIndex].pointId = pointId;
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
							//var old_radius = st.strokeWidth;
							//if (typeof this.vertices[i].geometry.radius != "undefined" && this.vertices[i].geometry.radius > 0) st.strokeWidth = this.vertices[i].geometry.zoom_radius;
							if (this.vertices[i].isFixPoint && this.fixVertexStyle) {
								this.layer.drawFeature(this.vertices[i], this.fixVertexStyle);
							}
							else {							
								this.layer.drawFeature(this.vertices[i], st);
							}	
							//st.strokeWidth = old_radius;
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
					if (!this.allowAddPoints) return;
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
							if (this.vertices[i].isFixPoint) return res;
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
				CLASS_NAME: "OpenLayers.Handler.PathRouteEx"
			});
			OpenLayers.Handler.PathRouteEx.HIT_NONE = 0;
			OpenLayers.Handler.PathRouteEx.HIT_POINT = 1;
			OpenLayers.Handler.PathRouteEx.HIT_LINE = 2;

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
						
			OpenLayers.Control.InfoPanel = OpenLayers.Class(OpenLayers.Control, {
				
				initialize: function(options) {
					this.allowSelection = false;
					OpenLayers.Control.prototype.initialize.apply(this, arguments);
				},

				destroy: function() {					
					OpenLayers.Control.prototype.destroy.apply(this, arguments);
				},    
				
				draw: function() {
					OpenLayers.Control.prototype.draw.apply(this, arguments);					
					this.updateInfo();					
					return this.div;    
				},

				updateInfo: function() {
					this.div.innerHTML = "";
				},

				CLASS_NAME: "OpenLayers.Control.InfoPanel"
			});	

			OpenLayers.Marker.Label = OpenLayers.Class(OpenLayers.Marker, {
				/** 
				 * Property: labelDiv
				 * {DOMElement}
				 */
				labelDiv: null,
				/** 
				 * Property: label
				 * {String}
				 */
				label: null,
				/** 
				 * Property: label
				 * {Boolean}
				 */
				mouseOver: false,
				/** 
				 * Property: labelClass
				 * {String}
				 */
				labelClass: "olMarkerLabel",
				/** 
				 * Property: events 
				 * {<OpenLayers.Events>} the event handler.
				 */
				events: null,
				/** 
				 * Property: div
				 * {DOMElement}
				 */
				div: null,
				/** 
				 * Property: onlyOnMouseOver
				 * {Boolean}
				 */
				onlyOnMouseOver: false,
				/** 
				 * Property: mouseover
				 * {Boolean}
				 */
				mouseover: false,
				/** 
				 * Property: labelOffset
				 * {String}
				 */
				labelOffset: "10px",
				/** 
				 * Constructor: OpenLayers.Marker.Label
				 * Parameters:
				 * icon - {<OpenLayers.Icon>}  the icon for this marker
				 * lonlat - {<OpenLayers.LonLat>} the position of this marker
				 * label - {String} the position of this marker
				 * options - {Object}
				 */
				initialize: function(lonlat, icon, label, options) {
					var newArguments = [];
					OpenLayers.Util.extend(this, options);
					newArguments.push(lonlat, icon, label);
					OpenLayers.Marker.prototype.initialize.apply(this, newArguments);
					
					var img = this.icon.imageDiv.firstChild;
					img.className = "olMarkerImage";

					this.label = label;
					this.labelDiv = OpenLayers.Util.createDiv(img.id + "_Text", null, null);
					this.labelDiv.className = this.labelClass;
					this.labelDiv.innerHTML = label;
					this.labelDiv.style.marginTop = this.labelOffset;
					this.labelDiv.style.marginLeft = this.labelOffset;
				},
				
				/**
				 * APIMethod: destroy
				 * Destroy the marker. You must first remove the marker from any 
				 * layer which it has been added to, or you will get buggy behavior.
				 * (This can not be done within the marker since the marker does not
				 * know which layer it is attached to.)
				 */
				destroy: function() {
					this.label = null;
					this.labelDiv = null;
					OpenLayers.Marker.prototype.destroy.apply(this, arguments);
				},
			   
				/** 
				* Method: draw
				* Calls draw on the icon, and returns that output.
				* 
				* Parameters:
				* px - {<OpenLayers.Pixel>}
				* 
				* Returns:
				* {DOMElement} A new DOM Image with this marker's icon set at the 
				* location passed-in
				*/
				draw: function(px) {
					this.div = OpenLayers.Marker.prototype.draw.apply(this, arguments);
					this.div.appendChild(this.labelDiv, this.div.firstChild);
					
					if (this.mouseOver === true) {
						this.setLabelVisibility(false);
						this.events.register("mouseover", this, this.onmouseover);
						this.events.register("mouseout", this, this.onmouseout);
					}
					else {
						this.setLabelVisibility(true);
					}
					return this.div;
				}, 
				/** 
				 * Method: onmouseover
				 * When mouse comes up within the popup, after going down 
				 * in it, reset the flag, and then (once again) do not 
				 * propagate the event, but do so safely so that user can 
				 * select text inside
				 * 
				 * Parameters:
				 * evt - {Event} 
				 */
				onmouseover: function (evt) {
					
					this.setLabel( this.getLabel() );
					
					if (!this.mouseover) {
						this.setLabelVisibility(true);
						this.mouseover = true;
					}
					if (this.map.getSize().w - this.map.getPixelFromLonLat(this.lonlat).x<50) {
						this.labelDiv.style.marginLeft = (-10-this.icon.size.w)+"px";
					}
					if (this.map.getSize().h - this.map.getPixelFromLonLat(this.lonlat).y<50) {
						this.labelDiv.style.marginTop = (-10-this.icon.size.h)+"px";
					}
					OpenLayers.Event.stop(evt, true);
				},
				/** 
				 * Method: onmouseout
				 * When mouse goes out of the popup set the flag to false so that
				 *   if they let go and then drag back in, we won't be confused.
				 * 
				 * Parameters:
				 * evt - {Event} 
				 */
				onmouseout: function (evt) {
					this.mouseover = false;
					this.setLabelVisibility(false);
					this.labelDiv.style.marginLeft = this.labelOffset;
					this.labelDiv.style.marginTop = this.labelOffset;
					OpenLayers.Event.stop(evt, true);
				},
				/** 
				 * Method: setLabel
				 * Set new label
				 * 
				 * Parameters:
				 * label - {String} 
				 */
				setLabel: function (label) {
					this.label=label;
					this.labelDiv.innerHTML = label;
				},
				/** 
				 * Method: getLabel
				 * get label text
				 * 
				 * Parameters: none				 
				 */
				getLabel: function () {
					return this.label;					
				},				
				/** 
				 * Method: setLabelVisibility
				 * Toggle label visibility
				 * 
				 * Parameters:
				 * visibility - {Boolean} 
				 */
				setLabelVisibility: function (visibility) {
					if (visibility) {
						this.labelDiv.style.display = "block";
					}
					else {
						this.labelDiv.style.display = "none";
					}
				},
				
				/** 
				 * Method: getLabelVisibility
				 * Get label visibility
				 * 
				 * Returns:
				 *   visibility - {Boolean} 
				 */
				getLabelVisibility: function () {
					if (this.labelDiv.style == "none") {
						return false;
					}
					else {
						return true;
					}
				},
				
				CLASS_NAME: "OpenLayers.Marker.Label"
			});