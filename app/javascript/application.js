// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

let map
let markers = {}
let mewses = {}

document.getElementById('inputPhoto').addEventListener('change', (e) => {  
  const data = new FormData();
  const image = e.target.files[0];
  data.append('mews_id', e.target.getAttribute("data-mews-id"));
  data.append('name', 'sendNameHere');
  data.append('image', image);

  fetch('/imageupload', {
    method: 'POST',    
    body: data,
    headers: {
      "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
    },
  }).then((res) => 
    res.json()
  ).then((d) => {
    console.log(d)
    let imageBlock = document.getElementById("images")    
    let img = document.createElement("img")
    img.src = d.thumb_url
    imageBlock.appendChild(img)
  });
});


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




 
const closePopup = () => {
  document.getElementById("mewspopup").style.display = "none"
}
document.getElementById("closepopup").addEventListener("click",closePopup)


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


const addBordersToMap = (map) => {
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

}

const openMews = (id) => {
  console.log(id)
  document.getElementById("inputPhoto").setAttribute("data-mews-id",id)
  document.getElementById("mewspopup").style.display = "block"
  let imageBlock = document.getElementById("images")
  imageBlock.innerHTML = ""
  mewses[id].images.forEach((i) => {
    let img = document.createElement("img")
    img.src = i
    imageBlock.appendChild(img)
  })
}


const addMewsToMap = (map) => {
  

  fetch("all_mews.json")
    .then((response) => 
      response.json()
    ).then((data) => {
      data.mewses.forEach((d) => {
        mewses[d.id] = d
        let popupContents  = `<p>${d.name} (${d.id})</p><p><a id="mews_${d.id}" class="openMews">Edit</a>`
        let popUp = L.popup().setContent(popupContents)

        popUp.addEventListener("add",() => (document.getElementById(`mews_${d.id}`).addEventListener("click",() => openMews(d.id))))
        popUp.addEventListener("remove",() => (document.getElementById(`mews_${d.id}`).removeEventListener("click",() => openMews(d.id))))

        if (d.boroughs.includes("Kensington And Chelsea")) {
          markers[d.id] = L.marker([d.lat, d.lng], {title: d.name + " (" + d.id + ")", icon: redIcon}).addTo(map).bindPopup(popUp);

        } else {
          markers[d.id] = L.marker([d.lat, d.lng], {title: d.name}).addTo(map).bindPopup(popUp);
        }
     })
    
        
 

    }
   
    )
}


const findMe = () => {

  navigator.geolocation.getCurrentPosition((position) => {
   //doSomething(position.coords.latitude, position.coords.longitude);
    L.marker([position.coords.latitude,position.coords.longitude], {icon: blueCircle}).addTo(map)

    map.panTo(new L.LatLng(position.coords.latitude,position.coords.longitude));
  });
  

}

document.getElementById("findme").addEventListener("click",findMe)


navigator.geolocation.getCurrentPosition((position) => {
  //doSomething(position.coords.latitude, position.coords.longitude);
   map = L.map('map').setView([position.coords.latitude,position.coords.longitude], 15);
   L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
  }).addTo(map);
  L.marker([position.coords.latitude,position.coords.longitude], {icon: blueCircle}).addTo(map)

  
    addMewsToMap(map)
    addBordersToMap(map)
 });