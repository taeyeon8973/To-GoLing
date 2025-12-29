import AsyncStorage from '@react-native-async-storage/async-storage';

const KEY = 'logs';

export const LogRepository = {
  // 로그 불러오기
  getLogs: async () => {
    try {
      const jsonString = await AsyncStorage.getItem(KEY);
      return jsonString != null ? JSON.parse(jsonString) : [];
    } catch (e) {
      console.error(e);
      return [];
    }
  },

  // 로그 저장하기
  addLog: async (log) => {
    try {
      const currentLogs = await LogRepository.getLogs();
      const newLogs = [...currentLogs, log];
      await AsyncStorage.setItem(KEY, JSON.stringify(newLogs));
    } catch (e) {
      console.error(e);
    }
  },
};