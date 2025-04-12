<template>
  <div ref="mapContainer" class="w-full h-64 rounded-lg border border-gray-200 dark:border-gray-700"></div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue';
// Note: Leaflet is assumed here. Installation ('npm install leaflet @types/leaflet') and CSS import might be needed.
// import 'leaflet/dist/leaflet.css'; 
// import L from 'leaflet'; 

/**
 * BaseMap
 * 
 * An interactive map component for displaying geographical data.
 * Uses Leaflet library by default.
 * 
 * @props {Array} center - Initial center of the map [latitude, longitude]. Default: [0, 0]
 * @props {Number} zoom - Initial zoom level. Default: 2
 * @props {Array} markers - Array of marker objects { latlng: [lat, lng], popupContent: 'HTML content' }
 * @props {Object} tileLayerOptions - Options for the tile layer (e.g., url, attribution).
 * 
 * @slots marker-popup - Custom content for marker popups. Scope: { marker }
 * 
 * @events map-click - Fired when the map is clicked. Payload: { latlng }
 * @events marker-click - Fired when a marker is clicked. Payload: { markerData }
 * 
 * @example
 * <BaseMap
 *   :center="[51.505, -0.09]"
 *   :zoom="13"
 *   :markers="[{ latlng: [51.5, -0.09], popupContent: 'A marker!' }]"
 *   @map-click="handleMapClick"
 * />
 */

const props = defineProps({
  center: {
    type: Array,
    default: () => [0, 0],
    validator: (value) => Array.isArray(value) && value.length === 2 && typeof value[0] === 'number' && typeof value[1] === 'number',
  },
  zoom: {
    type: Number,
    default: 2,
  },
  markers: {
    type: Array,
    default: () => [],
    validator: (value) => Array.isArray(value) && value.every(m => m.latlng && Array.isArray(m.latlng) && m.latlng.length === 2),
  },
  tileLayerOptions: {
    type: Object,
    default: () => ({
      url: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    })
  }
});

const emit = defineEmits(['map-click', 'marker-click']);

const mapContainer = ref(null);
let mapInstance = null;
let markerLayer = null;

onMounted(() => {
  // // Dynamically import Leaflet to avoid SSR issues if applicable
  // import('leaflet').then(L => {
  //   if (!mapContainer.value) return;
    
  //   // Initialize map
  //   mapInstance = L.map(mapContainer.value).setView(props.center, props.zoom);

  //   // Add tile layer
  //   L.tileLayer(props.tileLayerOptions.url, {
  //     attribution: props.tileLayerOptions.attribution,
  //     maxZoom: 19, // Standard max zoom for OSM
  //   }).addTo(mapInstance);

  //   // Add initial markers
  //   markerLayer = L.layerGroup().addTo(mapInstance);
  //   updateMarkers(L, props.markers);

  //   // Event listeners
  //   mapInstance.on('click', (e) => {
  //     emit('map-click', { latlng: e.latlng });
  //   });

  //   // Handle potential resize issues
  //   const resizeObserver = new ResizeObserver(() => {
  //       mapInstance?.invalidateSize();
  //   });
  //   resizeObserver.observe(mapContainer.value);
    
  //   // Cleanup resize observer on unmount
  //   onUnmounted(() => {
  //       resizeObserver.disconnect();
  //   });

  // }).catch(error => {
  //   console.error("Failed to load Leaflet:", error);
  //   // Optionally display an error message in the map container
  //   if (mapContainer.value) {
  //       mapContainer.value.innerHTML = '<p class="p-4 text-red-600 dark:text-red-400">Error loading map library.</p>';
  //   }
  // });
  // TODO: Re-enable Leaflet integration later
  if (mapContainer.value) {
      mapContainer.value.innerHTML = '<p class="p-4 text-center text-gray-500 dark:text-gray-400">Map integration temporarily disabled. (OpenStreetMap integration planned)</p>';
  }
});

onUnmounted(() => {
  if (mapInstance) {
    mapInstance.remove();
    mapInstance = null;
  }
});

// // Watch for prop changes to update map
// watch(() => props.center, (newCenter) => {
//   mapInstance?.setView(newCenter, props.zoom);
// });

// watch(() => props.zoom, (newZoom) => {
//   mapInstance?.setZoom(newZoom);
// });

// watch(() => props.markers, (newMarkers) => {
//     // Re-import L if needed or ensure it's available
//     import('leaflet').then(L => {
//         updateMarkers(L, newMarkers);
//     }).catch(error => console.error("Failed to load Leaflet for marker update:", error));
// }, { deep: true });
// // TODO: Re-enable watchers when Leaflet integration is active


// function updateMarkers(L, markersData) {
//   if (!mapInstance || !markerLayer || !L) return;

//   markerLayer.clearLayers(); // Clear existing markers

//   markersData.forEach(markerData => {
//     const marker = L.marker(markerData.latlng).addTo(markerLayer);
    
//     if (markerData.popupContent) {
//       marker.bindPopup(markerData.popupContent);
//     }
    
//     marker.on('click', () => {
//       emit('marker-click', { markerData });
//     });
//   });
// }
// // TODO: Re-enable when Leaflet integration is active

</script>

<style>
/* Basic Leaflet CSS import - consider moving to main CSS file or ensure it's loaded globally */
/* @import 'leaflet/dist/leaflet.css'; */

/* Ensure map container has a defined height */
.leaflet-container {
  height: 100%;
  width: 100%;
}

/* Optional: Style adjustments for dark mode popups if needed */
.dark .leaflet-popup-content-wrapper {
  background-color: #1f2937; /* gray-800 */
  color: #f9fafb; /* gray-50 */
}
.dark .leaflet-popup-tip {
   background-color: #1f2937; /* gray-800 */
}
.dark .leaflet-control-attribution a {
    color: #9ca3af; /* gray-400 */
}
</style>