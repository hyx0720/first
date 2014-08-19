/// <reference path="OpenLayers.js" />

OpenLayers.ProxyHost = 'MyProxy.ashx?URL=';



function init() {
    // 使用指定的文档元素创建地图
    var geourl = "http://58.198.183.152:8000/";
    // var bounds = new OpenLayers.Bounds(-135.111, 17.66, -60.73, 58.13);
    var option = {
        units: 'degrees',
        projection: new OpenLayers.Projection("EPSG:4326")
        // displayProjection: new OpenLayers.Projection("EPSG:4326"),
        // maxExtent: bounds,
        //maxScale: 20000000,
        //center: new OpenLayers.LonLat(-98.11, 39.11)

    };
    map = new OpenLayers.Map("map", option);

    var tile = new OpenLayers.Layer.WMS("topp:states", geourl + "geoserver/wms",
        {
            layers: 'topp:states',
            srs: 'EPSG:4326',
            format: 'image/png',
            transparent: true
        },
        { isBaseLayer: false, singleTile: false, ratio: 1 });
    //           

    capital = new OpenLayers.Layer.WMS("capitals", geourl + "geoserver/wms", {
        layers: 'cite:natcapitals',
        srs: 'EPSG:4326',
        format: 'image/png',
        transparent: true
    }, { isBaseLayer: false });

    //            var base = new OpenLayers.Layer.OSM();

    //    var base = new OpenLayers.Layer.WMS("Earth", geourl + "geoserver/wms",
    //                    {
    //                        layers: 'cite:singleNight',
    //                        srs: 'EPSG:4326',
    //                        format: 'image/png'
    //                    }, { isBaseLayer: true});



    vlayer = new OpenLayers.Layer.Vector("Editable", {

        renderers: renderer,
        styleMap: new OpenLayers.StyleMap({
            "default": new OpenLayers.Style(OpenLayers.Util.applyDefaults({
                externalGraphic: "../img/ship2.jpg",
                graphicOpacity: 1,
                rotation: 0,
                pointRadius: 10
            }, OpenLayers.Feature.Vector.style["default"]))
        })
    });

    wfsGet = new OpenLayers.Layer.Vector("wfs", {
        strategies: [new OpenLayers.Strategy.BBOX()],
        projection: new OpenLayers.Projection("EPSG:4326"),
        protocol: new OpenLayers.Protocol.WFS({
            version: "1.0.0",
            url: geourl + "geoserver/wfs",
            featureType: "states",
            featureNS: "http://www.opengeospatial.net/cite",
            srsName: "EPSG:4326"
            //geometryName: 'the_geom'
        })
    });

    tempdraw = new OpenLayers.Layer.Vector("temp");


    map.addLayer(tile);
    //    map.addLayer(base);
    map.addLayer(vlayer);
    map.addLayer(capital);
    map.addLayer(wfsGet);

    //add control
    map.addControl(new OpenLayers.Control.LayerSwitcher({ 'ascending': false }));

    locate = new OpenLayers.Control.MousePosition({ 'div': OpenLayers.Util.getElement('location') });
    map.addControl(locate);
    map.addControl(new OpenLayers.Control.Scale($('scale')));


    // 设定视图缩放地图程度为最大
    // map.zoomToMaxExtent();
    //控件panel
    var world = new OpenLayers.Control.ZoomToMaxExtent({
        title: "Zoom to the max extent",
        text: "World"
    });

    var contain = document.getElementById("hello");
    var panel = new OpenLayers.Control.Panel(
                    {
                        defaultControl: world,
                        createControlMarkup: function (control) {
                            var button = document.createElement("button"),
                                iconSpan = document.createElement("span"),
                                textSpan = document.createElement("span");
                            //                iconSpan.innerHTML = "&nbsp";

                            button.appendChild(iconSpan);
                            if (control.text) {
                                textSpan.innerHTML = control.text;
                            }
                            button.appendChild(textSpan);
                            return button;
                        }
                    });


    var draw = new OpenLayers.Control.EditingToolbar(vlayer, {
        title: "Draw feature",
        text: 'draw'
    }, { div: contain });
    var clc = new EraseLayer(vlayer, { title: "EraseAllFeature", text: "Clear" });
    var edit = new OpenLayers.Control.ModifyFeature(vlayer, {
        title: "modify Feature",
        text: "edit",
        displayClass: 'olControlModifyFeature'
    });
    var tempPoint = new OpenLayers.Control.DrawFeature(tempdraw, OpenLayers.Handler.Box, {
        title: "select State",
        text: "wfs"
    });

    panel.addControls([world, draw, edit, clc, tempPoint]);

    //  panel.addControls([nav.next, nav.previous]);
    map.addControl(panel);

    //查询功能
    // support GetFeatureInfo
    //    map.events.register('click', map, mapclick);


    info = new OpenLayers.Control.WMSGetFeatureInfo(
                        {
                            url: geourl + "geoserver/wms",
                            title: "get info by clicking",
                            queryVisible: true,
                            eventListeners: {
                                getfeatureinfo: function (e) {
                                    map.addPopup(new OpenLayers.Popup.FramedCloud(
                                "chicken",
                                map.getLonLatFromPixel(e.xy),
                                new OpenLayers.Size(30, 30),
                                e.text,
                                null,
                                true
                                ));

                                }

                            }
                        });
    map.addControl(info);
    info.activate();

    function mapclick(e) {
        document.getElementById("nodelist").innerHTML = "loading";
        var params = {
            REQUEST: "GetFeatureInfo",
            EXCEPTIONS: "application/vnd.ogc.se_xml",
            BBOX: map.getExtent().toBBOX(),
            X: e.xy.x,
            Y: e.xy.y,
            INFO_FORMAT: 'text/html',
            QUERY_LAYERS: map.layers[0].params.LAYERS,
            FEATURE_COUNT: 50,
            Layers: ['topp:states', 'cite:natcapitals'],
            Styles: '',
            Srs: 'EPSG:4326',
            WIDTH: map.size.w,
            HEIGHT: map.size.h,
            format: 'image/jpeg'
        };

        OpenLayers.loadURL = function (uri, params, caller, onComplete, onFailure) {
            if (typeof params == 'string') { params = OpenLayers.Util.getParameters(params); }
            var success = (onComplete) ? onComplete : OpenLayers.nullHandler; var failure = (onFailure) ? onFailure : OpenLayers.nullHandler; return OpenLayers.Request.GET({ url: uri, params: params, success: success, failure: failure, scope: caller });
        };

        OpenLayers.loadURL(geourl + "geoserver/wms", params, this, setHTML, setFail);

        //  OpenLayers.loadURL("geoserverProxy.aspx?url=http://58.198.182.214:8080/geoserver/wms", params, this, setHTML, setFail);
        OpenLayers.Event.stop(e);

    }


    //create Feature point test 
    var point = new OpenLayers.Geometry.Point(125.7, 31.5);
    var proj = new OpenLayers.Projection("EPSG:4326");
    point.transform(proj, map.getProjectionObject());
    var pointFeature = new OpenLayers.Feature.Vector(point);
    var point2 = new OpenLayers.Geometry.Point(128.2, 42.4);
    point2.transform(proj, map.getProjectionObject());
    var pointFeature2 = new OpenLayers.Feature.Vector(point2);
    pointFeature.attributes = {
        name: "shipfleet",
        title: "ship",
        type: "battleship",
        favColor: 'red',
        align: 'cm'
    };
    var wkt1 = new OpenLayers.Format.WKT();
    var polygon1 = wkt1.read("POLYGON((7.174072265625 32.5634765625, 57.799072265625 37.4853515625, 92.955322265625 0.2197265625, 73.970947265625 -13.1396484375, 5.767822265625 -23.6865234375, 7.174072265625 32.5634765625))");

    vlayer.addFeatures([pointFeature, pointFeature2]);

    //marker test
    //            var markers = new OpenLayers.Layer.Markers("Markers");
    //            map.addLayer(markers);

    //            var size = new OpenLayers.Size(15, 20);
    //            var offset = new OpenLayers.Pixel(-(size.w / 2), -size.h);
    //            var icon = new OpenLayers.Icon('img/marker-gold.png', size, offset);
    //            markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(0, 0), icon));
    //            markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(0, 0), icon.clone()));



    //画框查询已经发布的矢量图层，WFS Filter  .在vlayer中画多边形，筛选wfsGet图层中相交的要素，显示出来
    tempdraw.events.on({
        beforefeatureadded: function (event) {
            var geometry = event.feature.geometry;
            wfsGet.filter = new OpenLayers.Filter.Spatial(
                    {
                        type: OpenLayers.Filter.Spatial.INTERSECTS,
                        value: event.feature.geometry
                    });
            wfsGet.refresh({ force: true });
            return false;
        }
    });


    //// Interaction; not needed for initial display.
    vlayerControl = new OpenLayers.Control.SelectFeature([vlayer], {

        clickout: true, toggle: false,
        multiple: false, hover: false,
        toggleKey: "ctrlKey", // ctrl key removes from selection
        multipleKey: "shiftKey" // shift key adds to selection


    });

    map.addControl(vlayerControl);
    vlayerControl.activate();
    vlayer.events.on({
        'featureselected': onFeatureSelect,
        'featureunselected': onFeatureUnselect
    });

    // Needed only for interaction, not for the display.
    function onPopupClose(evt) {
        // 'this' is the popup.
        var feature = this.feature;
        if (feature.layer) { // The feature is not destroyed
            vlayerControl.unselect(feature);
        } else { // After "moveend" or "refresh" events on POIs layer all 
            //     features have been destroyed by the Strategy.BBOX
            this.destroy();
        }
    }
    function onFeatureSelect(evt) {
        feature = evt.feature;
        var format = new OpenLayers.Format.WKT();
        inputwkt = format.write(feature);
        var featureCenter = feature.geometry.getBounds().getCenterLonLat();
        popup = new OpenLayers.Popup.FramedCloud("featurePopup",
                                         featureCenter,
                                         null,
                                         "<h2>" + feature.attributes.title + "</h2>" +
                                         "type:" + feature.attributes.type + "</br>" + "LonLat:" + featureCenter,
                                         null, true, onPopupClose);
        feature.popup = popup;
        popup.feature = feature;
        map.addPopup(popup, true);
        //document.getElementById("scale").innerHTML = featureCenter;

        map.panTo(featureCenter);
    }
    function onFeatureUnselect(evt) {
        feature = evt.feature;
        if (feature.popup) {
            popup.feature = null;
            map.removePopup(feature.popup);
            feature.popup.destroy();
            feature.popup = null;
        }
    }

    //vector1,vector2 SelectTest
    OpenLayers.Feature.Vector.style['default']['strokeWidth'] = '1';

    var renderer = OpenLayers.Util.getParameters(window.location.href).renderer;
    renderer = (renderer) ? [renderer] : OpenLayers.Layer.Vector.prototype.renderers;

    var vectors1 = new OpenLayers.Layer.Vector("Vector Layer 1", {
        renderers: renderer,
        styleMap: new OpenLayers.StyleMap({
            "default": new OpenLayers.Style(OpenLayers.Util.applyDefaults({
                externalGraphic: "../img/marker-green.png",
                graphicOpacity: 1,
                rotation: 0,
                pointRadius: 10
            }, OpenLayers.Feature.Vector.style["default"])),
            "select": new OpenLayers.Style({
                externalGraphic: "../img/ship2.jpg"
            })
        })
    });
    var vectors2 = new OpenLayers.Layer.Vector("Vector Layer 2", {
        renderers: renderer,
        styleMap: new OpenLayers.StyleMap({
            "default": new OpenLayers.Style(OpenLayers.Util.applyDefaults({
                fillColor: "red",
                strokeColor: "white",
                graphicName: "square",
                rotation: 0,
                pointRadius: 15
            }, OpenLayers.Feature.Vector.style["default"])),
            "select": new OpenLayers.Style(OpenLayers.Util.applyDefaults({
                graphicName: "square",
                rotation: 0,
                pointRadius: 15
            }, OpenLayers.Feature.Vector.style["select"]))
        })
    });
    //            map.addLayers([vectors1]);


    selectControl = new OpenLayers.Control.SelectFeature(
                [wfsGet],
                {
                    clickout: false, toggle: false,
                    multiple: false, hover: false,
                    toggleKey: "ctrlKey", // ctrl key removes from selection
                    multipleKey: "shiftKey", // shift key adds to selection
                    box: true
                }
            );

    map.addControl(selectControl);
    // selectControl.activate();

    //map.setCenter(new OpenLayers.LonLat(0, 0), 2);
    //    vectors1.addFeatures(createFeatures());
    //    vectors2.addFeatures(createFeatures());

    vectors1.events.on({
        "featureselected": function (e) {
            showStatus("selected feature " + e.feature.id + " on Vector Layer 1");
        },
        "featureunselected": function (e) {
            showStatus("unselected feature " + e.feature.id + " on Vector Layer 1");
        }
    });
    vectors2.events.on({
        "featureselected": function (e) {
            showStatus("selected feature " + e.feature.id + " on Vector Layer 2");
        },
        "featureunselected": function (e) {
            showStatus("unselected feature " + e.feature.id + " on Vector Layer 2");
        }
    });


    function createFeatures() {
        var extent = map.getExtent();
        var features = [];
        for (var i = 0; i < 100; ++i) {
            features.push(new OpenLayers.Feature.Vector(
                    new OpenLayers.Geometry.Point(extent.left + (extent.right - extent.left) * Math.random(),
                    extent.bottom + (extent.top - extent.bottom) * Math.random()
                )));
        }
        return features;
    }

    function showStatus(text) {
        document.getElementById("status").innerHTML = text;
    }

    //end of vector1,2 test


} //end of init() 

function setHTML(response) {

    document.getElementById('nodelist').innerHTML = response.responseText;
}
function setFail(response) {

    document.getElementById("nodelist").innerHTML = response.responseText;
}


function selectPoint() {
    var vector = document.getElementById("selectPoint").checked;
    if (vector != selectControl) {
        selectControl.activate();
        vlayerControl.deactivate();
    }
    else {
        selectControl.deactivate();
        vlayerControl.activate();
    }

}
function update() {
    var box = document.getElementById("box").checked;

    if (box != selectControl.box) {
        selectControl.box = box;
        if (selectControl.activate) {
            selectControl.deactivate();
            selectControl.activate();
        }
    }

}

// 缓冲区 核心功能。。
//      //BuffJson 定向到connect.aspx 页面，请求缓冲区。
function BuffJson() {
    var wkt = new OpenLayers.Format.WKT(); var bufferFeature; var wktext;
    var xmlrequest = new XMLHttpRequest();
    //  alert(inputwkt);
    var bufdist = document.getElementById("BuffDist").value
    if (bufdist.toString().length > 5) {
        alert("input correct degrees");
    }
    // 需要验证用户输入的逻辑性
    xmlrequest.open("GET", "connect.aspx?geom=" + inputwkt + "&dist=" + bufdist, true);
    xmlrequest.onreadystatechange = function () {
        if (xmlrequest.readyState == 4 && xmlrequest.status == 200) {
            var objs = eval(xmlrequest.responseText);
            //alert(objs.length); // 2
            // alert(objs[0].st_astext.toString());
            wktext = objs[0].st_astext.toString();
            bufferFeature = wkt.read(wktext);
            //                    var str1 = wkt.write(bufferFeature);
            //                    alert(str1);
        }
        vlayer.addFeatures(bufferFeature);
    }
    xmlrequest.send();

    //return bufferFeature;                       
}

           
