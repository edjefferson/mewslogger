// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

let map
let markers = {}
let mewses = {}

let myLocMarker

document.getElementById('inputPhoto').addEventListener('change', (e) => {  
  const data = new FormData();
  const image = e.target.files[0];
  let id =  e.target.getAttribute("data-mews-id")
  data.append('mews_id', e.target.getAttribute("data-mews-id"));
  data.append('name', 'sendNameHere');
  data.append('image', image);
  if (image) {
    fetch('/imageupload', {
      method: 'POST',    
      body: data,
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
    }).then((res) => 
      res.json()
    ).then((d) => {
      mewses[id].images.push(d.thumb_url)
      let imageBlock = document.getElementById("images")    
      let img = document.createElement("img")
      img.src = d.thumb_url
      imageBlock.appendChild(img)
    });
  }
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
const blueIcon = new L.Icon({
  iconUrl:
    "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png",
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



const saveNotes = (id,text) => {
  fetch('update_notes', {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
    },
    body: JSON.stringify({mews_id: id, text: text})
  }).then(() => mewses[id].notes = text)
}
 
const closePopup = () => {
  let id = document.getElementById("mewsnotes").getAttribute("data-mews-id")
  saveNotes(id, document.getElementById("mewsnotes").value)
  document.getElementById("mewspopup").style.display = "none"
  clearInterval(notesInterval)
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
                return { stroke: true, color: "black", fillColor: "none"};
            }
        }).bindPopup(function (layer) {
            return layer.feature.properties.description;
        }).addTo(map)
        })
        
    }
    )

}

let notesInterval
const openMews = (id) => {
  console.log(id)
  document.getElementById("inputPhoto").setAttribute("data-mews-id",id)
  document.getElementById("visitedcheck").setAttribute("data-mews-id",id)
  document.getElementById("visitedcheck").checked = mewses[id].visited
  document.getElementById("mewsnotes").setAttribute("data-mews-id",id)
  document.getElementById("mewsnotes").value = mewses[id].notes

  notesInterval = setInterval(()=> {
    saveNotes(id, document.getElementById("mewsnotes").value)
  },2000)
  document.getElementById("mewsname").textContent = mewses[id].name
  document.getElementById("mewspopup").style.display = "flex"
  let imageBlock = document.getElementById("images")
  imageBlock.innerHTML = ""
  mewses[id].images.forEach((i) => {
    let img = document.createElement("img")
    img.src = i
    imageBlock.appendChild(img)
  })
}
const toggleVisited = (e) => {
  console.log(e.target)
  let id = e.target.getAttribute("data-mews-id")
  console.log(JSON.stringify({mews_id: id, visited: e.target.checked}))
  fetch('/togglevisited', {
    method: 'POST',    
    body: JSON.stringify({mews_id: id, visited: e.target.checked, time_now: Date.now()}),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
    },
  }).then((res) => 
    {
      console.log(res)
      mewses[id].visited = e.target.checked
      markers[id].setIcon(e.target.checked ? greenIcon : blueIcon)
    }
  )
}
document.getElementById("visitedcheck").addEventListener("change",toggleVisited)


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
        if (d.visited) {
          markers[d.id] = L.marker([d.lat, d.lng], {title: d.name + " (" + d.id + ")", icon: greenIcon}).addTo(map).bindPopup(popUp);

        }
        else if (d.boroughs.includes("Kensington And Chelsea")) {
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
   if (myLocMarker){
    myLocMarker.setLatLng(new L.LatLng(position.coords.latitude,position.coords.longitude))
  } else {
    myLocMarker = L.marker([position.coords.latitude,position.coords.longitude], {icon: blueCircle}).addTo(map)
  }
    map.panTo(new L.LatLng(position.coords.latitude,position.coords.longitude));
  });
  

}

document.getElementById("findme").addEventListener("click",findMe)

map = L.map('map').setView([51.5072, -0.1276], 15);
L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map);
addMewsToMap(map)
addBordersToMap(map)

if (navigator.geolocation) {
  navigator.geolocation.getCurrentPosition((position) => {
    //doSomething(position.coords.latitude, position.coords.longitude);
    map.panTo(new L.LatLng(position.coords.latitude,position.coords.longitude));
    if (myLocMarker){
      myLocMarker.setLatLng(new L.LatLng(position.coords.latitude,position.coords.longitude))
    } else {
      myLocMarker = L.marker([position.coords.latitude,position.coords.longitude], {icon: blueCircle}).addTo(map)
    }
  
    
      
   });
}
