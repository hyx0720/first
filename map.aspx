<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="map.aspx.cs" Inherits="Openlayer.map" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Map of USA </title>
    <!--<meta http-equiv="Content-Type" content="text/html; charset=gb2312">-->
    <!--    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">-->
    <meta http-equiv="Content-Type" content="text/html; charset=gb2312">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0">
    <link rel="stylesheet" href="style.css" type="text/css" />
    <!-- 加载OpenLayers 类库 -->
    <script src="OpenLayers.js" type="text/javascript"></script>
    <%--<script src="http://openlayers.org/dev/OpenLayers.js" type="text/javascript"></script>--%>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
    <style>
        html, body
        {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 20px;
        }
        #OpenLayers_Control_Zoom_5
        {
            margin-top: 50px;
        }
        
        #map
        {
            border: 1px solid black;
        }
        .olControlEditingToolbar
        {
            margin-right: 50px;
        }
        
        .olControlPanel button
        {
            position: relative;
            display: block;
            left: 50px;
            margin: 2px;
            height: 20px;
            background-color: white;
            float: left;
            overflow: visible; /* needed to remove padding from buttons in IE */
        }
        .olControlPanel .navHistory span:first-child
        {
            background-image: url("../theme/default/img/navigation_history.png");
            height: 20px;
            width: 50px;
            top: 4px;
        }
        .olControlPanel .navHistoryPreviousItemActive span:first-child
        {
            background-position: 0 0;
        }
        .olControlPanel .navHistoryPreviousItemInactive span:first-child
        {
            background-position: 0 -24px;
        }
    </style>
    <script>
        OpenLayers.ProxyHost = 'MyProxy.ashx?URL=';

        function init() {
            // 使用指定的文档元素创建地图
            // var bounds = new OpenLayers.Bounds(-135.111, 17.66, -60.73, 58.13);
            var option = {
                units: 'degrees',
                projection: new OpenLayers.Projection("EPSG:4326"),
                // maxExtent: bounds,
                //maxScale: 20000000,
                center: new OpenLayers.LonLat(-98.11, 39.11)

            };
            var map = new OpenLayers.Map("map", option);

            var tile = new OpenLayers.Layer.WMS("topp:states", "http://localhost:8000/geoserver/wms",
        {
            layers: 'topp:states',
            srs: 'EPSG:4326',
            format: 'image/png',
            transparent: true
        },
        { isBaseLayer: false, singleTile: false, ratio: 1, wrapDateLine: true });


            var capit = new OpenLayers.Layer.WMS("capital", "http://localhost:8000/geoserver/wms",
        {
            layers: 'sf:natcapitals',
            srs: 'EPSG:4326',
            format: 'image/png',
            transparent: true

        }, { isBaseLayer: false, wrapDateLine: true });

            var test = new OpenLayers.Layer.WMS("testcap", "http://localhost:8000/geoserver/wms", {
                layers: 'cite:natcapitals',
                srs: 'EPSG:4326',
                format: 'image/png',
                transparent: true
            }, { isBaseLayer: false });

            //            var base = new OpenLayers.Layer.OSM();

            var base = new OpenLayers.Layer.WMS("Earth", "http://localhost:8000/geoserver/wms",
                    {
                        layers: 'cite:singleNight',
                        srs: 'EPSG:4326',
                        format: 'image/png'
                    }, { singleTile: false, wrapDateLine: true });

            var vlayer = new OpenLayers.Layer.Vector("Editable", {

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
            //         
            //    layers: 'nurc:Img_Sample',

            //Select related func
            //            function onPopupClose(evt) {
            //                selectCon.unselect(selectedFeature);
            //            }
            //popup function


            map.addLayer(tile);
            map.addLayer(base);
            map.addLayer(vlayer);
            map.addLayer(capit);
            map.addLayer(test);

            //add control
            map.addControl(new OpenLayers.Control.LayerSwitcher({ 'ascending': false }));

            locate = new OpenLayers.Control.MousePosition({ 'div': OpenLayers.Util.getElement('location') });
            map.addControl(locate);
            scale = new OpenLayers.Control.Scale({ 'div': OpenLayers.Util.getElement('scale') });
            map.addControl(scale);
            // 设定视图缩放地图程度为最大
            map.zoomToMaxExtent();
            //控件panel
            var world = new OpenLayers.Control.ZoomToMaxExtent({
                title: "Zoom to the max extent",
                text: "World"
            });

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

            var editbar1 = new OpenLayers.Control.EditingToolbar(vlayer, {
                title: "edittoolbar",
                text: 'edit'
            });
            var clc = new EraseLayer(vlayer, { title: "EraseAllFeature", text: "Clear" });

            panel.addControls([world, editbar1, clc]);

            //  panel.addControls([nav.next, nav.previous]);
            map.addControl(panel);

            //查询功能
            // support GetFeatureInfo
            //           

            //Popup遇到问题是access not allowed ，

            info = new OpenLayers.Control.WMSGetFeatureInfo(
                        {
                            url: "http://localhost:8000/geoserver/wms",
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
            //            info.activate();

            map.events.register('click', map, mapclick);
            //map.layers[0].params.LAYERS
            function mapclick(e) {
                document.getElementById("nodelist").innerHTML = "loading";
                var params = {
                    REQUEST: "GetFeatureInfo",
                    EXCEPTIONS: "application/vnd.ogc.se_xml",
                    BBOX: map.getExtent().toBBOX(),
                    X: e.xy.x,
                    Y: e.xy.y,
                    INFO_FORMAT: 'text/html',
                    QUERY_LAYERS: 'topp:states,cite:natcapitals',
                    FEATURE_COUNT: 50,
                    Layers: 'topp:states,cite:natcapitals',
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

                OpenLayers.loadURL("http://58.198.183.152:8000/geoserver/wms", params, this, setHTML, setFail);
                //  OpenLayers.loadURL("geoserverProxy.aspx?url=http://58.198.182.214:8080/geoserver/wms", params, this, setHTML, setFail);
                OpenLayers.Event.stop(e);

            }





            //label test
            //            var labelTest = new OpenLayers.Layer.Vector("POI", {
            //                strategies: [new OpenLayers.Strategy.BBOX({ resFactor: 1.1 })],
            //                protocol: new OpenLayers.Protocol.HTTP({
            //                    url: "textfile.txt",
            //                    format: new OpenLayers.Format.Text()
            //                })
            //            });
            //            map.addLayer(labelTest);

            //create Feature point test 
            var point = new OpenLayers.Geometry.Point(125, 31);
            var pointFeature = new OpenLayers.Feature.Vector(point);
            var point2 = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(128, 42));
            pointFeature.attributes = {
                name: "shipfleet",
                title: "ship",
                type: "battleship",
                favColor: 'red',
                align: 'cm'
            };


            vlayer.addFeatures([pointFeature, point2]);

            //marker test
            //            var markers = new OpenLayers.Layer.Markers("Markers");
            //            map.addLayer(markers);

            //            var size = new OpenLayers.Size(15, 20);
            //            var offset = new OpenLayers.Pixel(-(size.w / 2), -size.h);
            //            var icon = new OpenLayers.Icon('img/marker-gold.png', size, offset);
            //            markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(0, 0), icon));
            //            markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(0, 0), icon.clone()));



            //// Interaction; not needed for initial display.
            vlayerControl = new OpenLayers.Control.SelectFeature(vlayer, {

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
                popup = new OpenLayers.Popup.FramedCloud("featurePopup",
                                         feature.geometry.getBounds().getCenterLonLat(),
                                         null,
                                         "<h2>" + feature.attributes.title + "</h2>" +
                                         "type:" + feature.attributes.type,
                                         null, true, onPopupClose);
                feature.popup = popup;
                popup.feature = feature;
                map.addPopup(popup, true);
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
            map.addLayers([vectors1]);


            selectControl = new OpenLayers.Control.SelectFeature(
                [vectors1],
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

            map.setCenter(new OpenLayers.LonLat(0, 0), 2);
            vectors1.addFeatures(createFeatures());
            vectors2.addFeatures(createFeatures());

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
        function buffer() {
            xml = new XMLHttpRequest();
            xml.onreadystatechange = function () {
                if (xml.readyState == 4 && xml.status == 200) {
                    a = xml.responseText;
                    //document.getElementById("myDiv").innerHTML = xml.responseText;
                }
            }
            xml.open("GET", "connect.aspx", true);

            xml.send();

            //document.getElementById("hello").innerHTML = xml.responseText;

        }
    </script>
    <script src="access.js" type="text/javascript" language="javascript"></script>
</head>
<body onload="init()">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <div>
        <%-- <input id="selectPoint" type="checkbox" onchange='selectPoint()' /><label for="selectPoint">select
            Vector1 layer</label>--%>
        <%--<input id="box" type="checkbox" checked="checked" name="box" onchange="update()" />
                <label for="box">
                    select feature in a box
                </label>--%>
        <div id="hello">
        </div>
        <div id="panel" style="position: absolute; margin-left: 600px">
        </div>
        <div id="map" class="smallmap" style="width: 800px; height: 480px;">
            <!--<input id="clear" type="button"  value="clear" style=" position:relative; left:100px;" onclick="cl();" /> -->
        </div>
        <div id="wrapper">
            <div id="location">
            </div>
            <div id="scale" style="float: inherit;">
                map scale
            </div>
        </div>
        <input id="BuffDist" type="text" value="buffer distance in Degrees" />
        <input id="BuffJson1" type='button' value="DrawBuffer" onclick="BuffJson()" />
        <div id="nodelist">
            <em></em>
        </div>
        <div id="status">
        </div>
        <asp:UpdatePanel ID="UP1" runat="Server">
            <ContentTemplate>
                <asp:TextBox ID="TextBox1" runat="server" Text="input keywords"></asp:TextBox>
                <asp:Button ID="Button1" runat="server" Text="QueryFeature" OnClick="Button1_Click" />
                <asp:GridView ID="GridView1" runat="server">
                </asp:GridView>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    </form>
</body>
</html>
