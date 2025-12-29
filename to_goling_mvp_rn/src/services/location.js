import * as Location from 'expo-location';

export const LocationService = {
  getCurrentPosition: async () => {
    try {
      // 권한 요청
      let { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') return null;

      // 위치 가져오기
      let location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.High,
      });
      
      return {
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
      };
    } catch (e) {
      console.error(e);
      return null;
    }
  },
};