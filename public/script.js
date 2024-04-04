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

const markVisited = (id) => {
  fetch('update_mews', {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({id: id, b: 'Textual content'})
  });
}
fetch("all_mews.json")
    .then((response) => 
      response.json()
    ).then((data) => {
      document.getElementsByTagName("body")[0].setAttribute("token", data.token)
      data.mewses.forEach((d) => {
        if (d.boroughs.includes("Kensington And Chelsea")) {
          popupContents  = `<p>${d.name} (${d.id})</p><p><a onClick="markVisited('${d.id}')">Unvisited</a>`
          L.marker([d.lat, d.lng], {title: d.name + " (" + d.id + ")", icon: redIcon}).addTo(map).bindPopup(popupContents);

        } else {
          L.marker([d.lat, d.lng], {title: d.name}).addTo(map).bindPopup(d.name);
        }
     })}
   
    )