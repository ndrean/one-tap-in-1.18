//import "leaflet/dist/leaflet.css";

export async function initMap(mapID) {
  //await loadLeafletCSS();
  const { default: L } = await import("leaflet");
  const { MaptilerLayer } = await import("@maptiler/leaflet-maptilersdk");

  const map = L.map(mapID, {
    renderer: L.canvas(),
    minzoom: 1,
    maxzoom: 10,
    referrerPolicy: "origin",
  });

  const maptilerKey = document.getElementById("map-hook").dataset.maptilerKey;

  map.setView([0, 0], 0);
  const maptLayer = new MaptilerLayer({
    apiKey: maptilerKey,
    crossOrigin: "anonymous",
    style: "https://api.maptiler.com/maps/streets/style.json",
  });

  maptLayer.addTo(map);

  const group = L.layerGroup().addTo(map);

  L.Marker.prototype.options.icon = L.icon({
    iconUrl: "/images/marker-icon.png",
    iconRetinaUrl: "/images/marker-icon-2x.png",
    shadowUrl: "/images/marker-shadow.png",
    iconSize: [25, 41],
    iconAnchor: [12, 41],
  });
  return { L, map, group, maptLayer };
}

/*
async function loadLeafletCSS() {
  if (!document.getElementById("inline-leaflet-css")) {
    // Vite-specific: Dynamically inject Leaflet CSS with ?inline
    const css = await import("leaflet/dist/leaflet.css");
    const style = document.createElement("style");
    style.setAttribute("id", "inline-leaflet-css");
    style.textContent = css.default;
    document.head.appendChild(style);
  }
}
*/
