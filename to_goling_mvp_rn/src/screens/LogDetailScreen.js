import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

export default function LogDetailScreen({ route }) {
  const { log } = route.params;

  return (
    <View style={styles.container}>
      <Text style={styles.date}>{new Date(log.timestamp).toLocaleString()}</Text>
      
      <View style={styles.card}>
        <Text style={styles.place}>{log.place || '위치 정보 없음'}</Text>
        <Text style={styles.note}>{log.note}</Text>
        {log.tags && <Text style={styles.tags}>{log.tags}</Text>}
      </View>

      {log.latitude && (
        <Text style={styles.coord}>
          좌표: {log.latitude.toFixed(4)}, {log.longitude.toFixed(4)}
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F7FB', padding: 20 },
  date: { fontSize: 14, color: 'gray', marginBottom: 10 },
  card: {
    backgroundColor: 'white', padding: 20, borderRadius: 20,
    shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 10, elevation: 2
  },
  place: { fontSize: 18, fontWeight: 'bold', marginBottom: 10 },
  note: { fontSize: 16, lineHeight: 24, color: '#333', marginBottom: 20 },
  tags: { color: '#007AFF', fontSize: 14 },
  coord: { marginTop: 20, fontSize: 12, color: '#aaa', textAlign: 'center' }
});