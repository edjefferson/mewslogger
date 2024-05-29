// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"



let map
let markers = {}
let mewses = {}
let myLocMarker
let mainMarker


const boroughList = {0: "Camden",
1: "Lambeth",
2: "Tower Hamlets",
3: "Enfield",
4: "Wandsworth",
5: "Hackney",
6: "Kensington And Chelsea",
7: "City Of Westminster",
8: "Haringey",
9: "Islington",
10: "Bromley",
11: "Lewisham",
12: "Hammersmith And Fulham",
13: "Richmond Upon Thames",
14: "Redbridge",
15: "Merton",
16: "Sutton",
17: "Southwark",
18: "Barnet",
19: "Greenwich",
20: "Waltham Forest",
21: "Havering",
22: "Harrow",
23: "Ealing",
24: "Kingston Upon Thames",
25: "Newham",
26: "Croydon",
27: "Brent",
28: "Hounslow",
29: "Hillingdon",
30: "Barking And Dagenham",
31: "Bexley",
32: "City Of London"}





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
    "../location.svg",
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

const imageUpload = (e) => {  
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
    })
  }
}


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
  fetch("../lad.json")
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

const searchParams = new URLSearchParams(window.location.search);

let borough
if (searchParams.has('bname')) {
  borough = searchParams.get('bname')
}




const addMewsToMap = (map) => {
  

  fetch("all_mews.json")
    .then((response) => 
      response.json()
    ).then((data) => {
      data.mewses.forEach((d) => {
        mewses[d.id] = d
        let popupContents  = `<p><a href=\"/mews/${d.id}">${d.name} (${d.id})</p></a><p><a id="mews_${d.id}" class="openMews">Edit</a>`
        let popUp = L.popup().setContent(popupContents)

        popUp.addEventListener("add",() => (document.getElementById(`mews_${d.id}`).addEventListener("click",() => openMews(d.id))))
        popUp.addEventListener("remove",() => (document.getElementById(`mews_${d.id}`).removeEventListener("click",() => openMews(d.id))))
        if (d.visited) {
          markers[d.id] = L.marker([d.lat, d.lng], {title: d.name + " (" + d.id + ")", icon: greenIcon}).addTo(map).bindPopup(popUp);

        }
        else if (d.boroughs.includes(borough)) {
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

const setMewsLatLng = (popUp,mews_id, latlng) => {
  console.log("egg")
  fetch('../update_mews_lat_lng', {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
    },
    body: JSON.stringify({mews_id: mews_id, latlng: latlng})
  }).then(() => {
    popUp.close()
    console.log(latlng)
    mainMarker.setLatLng(latlng)
  })
}

const addMewDataToMap = (mews_id) => {
  fetch(`../mews/${mews_id}.json`)
    .then((response) => 
      response.json()
    ).then((data) => {

      map.setView([data.lat,data.lng], 18);

      
      data.sources.forEach((source) => {
        let popupContents  = `<p><a id="source_${source.id}" class="setLatLng">Set Lat Lng</a>`
        let popUp = L.popup().setContent(popupContents)

        popUp.addEventListener("add",() => (document.getElementById(`source_${source.id}`).addEventListener("click",(e) => setMewsLatLng(popUp,data.id,source.latlng))))
        popUp.addEventListener("remove",() => (document.getElementById(`source_${source.id}`).removeEventListener("click",(e) => setMewsLatLng(popUp,data.id,source.latlng))))

        L.marker(source.latlng,  {icon: blueIcon}).addTo(map).bindPopup(popUp);
      })
      mainMarker = L.marker([data.lat, data.lng], {title: data.name + " (" + data.id + ")", icon: redIcon}).addTo(map)
      
      console.log(data)
     })
}

const ready = () => {
  if (document.getElementById("map2")) {
    document.getElementById("closepopup").addEventListener("click",closePopup)

    document.getElementById('inputPhoto').addEventListener('change', imageUpload);
    document.getElementById("visitedcheck").addEventListener("change",toggleVisited)


    document.getElementById("map2").innerHTML = "";
    map = []
    markers = {}
    mewses = {}

    document.getElementById("findme").addEventListener("click",findMe)

    map = L.map('map2').setView([51.5072, -0.1276], 15);

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
  } else
  if (document.getElementById("mewsmap")) {
    map = L.map('mewsmap').setView([51.5072, -0.1276], 15);

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        }).addTo(map);

    addBordersToMap(map)
    addMewDataToMap(document.getElementById("mewsmap").getAttribute("data-mews-id"))
  }
  
}

window.addEventListener("load",ready)
document.addEventListener("turbo:render",ready)