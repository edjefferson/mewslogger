// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

var map = L.map('map').setView([51.505, -0.09], 13);
L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);

fetch("lad.json")
    .then((response) => 
      response.json()
    ).then((data) => {
        data.features.forEach((f) => {
          L.geoJSON(f, {
            style: function (feature) {
                return {color: feature.properties.color, stroke: true, color: "black"};
            }
        }).bindPopup(function (layer) {
            return layer.feature.properties.description;
        }).addTo(map)
        })
        
    }
    )

    const redIcon = new L.Icon({
      iconUrl:
        "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png",
      shadowUrl:
        "https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png",
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    });

    const greenIcon = new L.Icon({
      iconUrl:
        "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png",
      shadowUrl:
        "https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png",
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    });

    const blueCircle = new L.Icon({
      iconUrl:
        "location.svg",
          iconSize: [25, 25],

      shadowSize: [41, 41]
    });

const markVisited = (id) => {

  markers[id].setIcon(greenIcon)
  fetch('update_mews', {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
    },
    body: JSON.stringify({id: id, b: 'Textual content'})
  });
}

let markers = {}
fetch("all_mews.json")
    .then((response) => 
      response.json()
    ).then((data) => {
      data.mewses.forEach((d) => {
        if (d.boroughs.includes("Kensington And Chelsea")) {
          let popupContents  = `<p>${d.name} (${d.id})</p><p><a onClick="markVisited('${d.id}')">Unvisited</a>`
          markers[d.id] = L.marker([d.lat, d.lng], {title: d.name + " (" + d.id + ")", icon: redIcon}).addTo(map).bindPopup(popupContents);

        } else {
          markers[d.id] = L.marker([d.lat, d.lng], {title: d.name}).addTo(map).bindPopup(d.name);
        }
     })}
   
    )

const findMe = () => {

  navigator.geolocation.getCurrentPosition((position) => {
   //doSomething(position.coords.latitude, position.coords.longitude);
    L.marker([position.coords.latitude,position.coords.longitude], {icon: blueCircle}).addTo(map)

    map.panTo(new L.LatLng(position.coords.latitude,position.coords.longitude));
  });
  

}
document.getElementById("findme").addEventListener("click",findMe)