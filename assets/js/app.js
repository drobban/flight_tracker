// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"

import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import layers2x from 'leaflet/dist/images/layers-2x.png';
import layers from 'leaflet/dist/images/layers.png';
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

console.log(layers2x);
console.log(layers);
console.log(markerIcon2x);
console.log(markerIcon);
console.log(markerShadow);


// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Add this to your app.js phoenix application

let Hooks = {}

Hooks.Map = {
  mounted(){

	var civilian_transport = L.icon({
	    iconUrl: 'assets/images/civilian-transport.png', // Path to your PNG image
	    iconSize: [32, 32], // Size of the icon (width, height in pixels)
	    iconAnchor: [16, 32], // Point of the icon which will correspond to the marker's position (center bottom)
	    className: 'moving_element',
	    popupAnchor: [0, -32] // Position of the popup relative to the icon (above the marker)
	});

    const markers = {}
    const map = L.map('mapid').setView([51.505, -0.09], 14)
    const paths = {}
    let geojsonLayer = L.geoJSON().addTo(map).setStyle({color: "#6435c9"})

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution:'© OpenStreetMap contributors',
        maxZoom: 19,
    }).addTo(map);

    this.map = map;
    this.markers = markers;

    this.handleEvent("update_marker_position", ({reference, lat, lon, center_view}) => {
      markers[reference].setLatLng(L.latLng(lat, lon))

      if (center_view) {
        map.flyTo(L.latLng(lat, lon))
      }
    });
    
    this.handleEvent("draw_path", ({reference, coordinates, color}) => {
      data = {
        "type": "LineString",
        "coordinates": coordinates
      }

      geojsonLayer.addData(data)
    });

    this.handleEvent("view_init", ({reference, lat, lon, zoom_level = 20}) => {
      geojsonLayer.remove()

      geojsonLayer = L.geoJSON().addTo(map).setStyle({color: "#6435c9"})

      map.setView(L.latLng(lat, lon), zoom_level)
    });

    this.handleEvent("set_zoom_level", ({zoom_level}) => {
      map.setZoom(zoom_level)
    });

    this.handleEvent("add_marker", ({reference, lat, lon}) => {      
	const marker_icons = {
		"civilian-transport": { icon: civilian_transport },
		"": {}
	}
      // lets not add duplicates for the same marker!
      if (markers[reference] == null) {
        const marker = L.marker(L.latLng(lat, lon), marker_icons["civilian-transport"])

        marker.addTo(map)

        markers[reference] = marker
      } else {
        markers[reference].setLatLng(L.latLng(lat, lon))
      }
    });

    this.handleEvent("add_marker_with_popup", ({reference, lat, lon, link}) => {      
      // lets not add duplicates for the same marker!
      if (markers[reference] == null) {
        const marker = L.marker(L.latLng(lat, lon))

        marker.bindPopup(`<a href=\"${link}\">${reference}</a>`)

        marker.addTo(map)

        markers[reference] = marker
      }
    });

    this.handleEvent("clear", () => {
      geojsonLayer.remove()

      geojsonLayer = L.geoJSON().addTo(map)

      for (const [reference, value] of Object.entries(markers)) {
        marker = markers[reference];

        marker.remove();

        delete markers[reference];
      }

    });

    this.handleEvent("remove_marker", ({reference}) => {
      if (markers[reference] != null) {
        marker = markers[reference]

        marker.remove()

        delete markers[reference]
      }

      geojsonLayer.remove()
    });
    // Send bounds when map loads
    this.pushBounds();

    // Send bounds when map is moved or zoomed
    this.map.on("moveend", () => {
	    this.pushBounds();
    });
    this.map.on("zoomend", () => {
	    this.pushBounds();
    });
  },

  pushBounds() {
    // Get current bounds
    const bounds = this.map.getBounds();
    const payload = {
      bounds: {
        north_west: { lat: bounds.getNorthWest().lat, lng: bounds.getNorthWest().lng },
        south_east: { lat: bounds.getSouthEast().lat, lng: bounds.getSouthEast().lng },
      },
    };
    console.log(this.markers);
   
  for (const key in this.markers) {
    const marker = this.markers[key];
    if (!bounds.contains(marker.getLatLng())) {
      marker.remove();
      delete this.markers[key];
    }
  } 

    // Push event to LiveView
    this.pushEvent("update_bounds", payload);
  },
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
	params: {_csrf_token: csrfToken}, 
	hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket



