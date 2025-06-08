export const MapHook = ({ mapID }) => ({
  async mounted() {
    const { initMap } = await import("./map.js");
    return await initMap(mapID);
  },
});
