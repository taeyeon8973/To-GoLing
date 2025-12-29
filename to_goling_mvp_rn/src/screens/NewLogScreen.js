import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity, ScrollView, Alert, ActivityIndicator } from 'react-native';
import 'react-native-get-random-values';
import { v4 as uuidv4 } from 'uuid';
import { LocationService } from '../services/location';
import { LogRepository } from '../services/storage';

export default function NewLogScreen({ navigation }) {
  const [note, setNote] = useState('');
  const [place, setPlace] = useState('');
  const [tags, setTags] = useState('');
  const [loading, setLoading] = useState(false);
  const [location, setLocation] = useState(null);

  useEffect(() => {
    (async () => {
      const loc = await LocationService.getCurrentPosition();
      if (loc) {
        setLocation(loc);
        setPlace(`위도: ${loc.latitude.toFixed(4)}, 경도: ${loc.longitude.toFixed(4)}`);
      }
    })();
  }, []);

  const handleSave = async () => {
    if (!note.trim()) {
      Alert.alert('알림', '메모를 입력해주세요!');
      return;
    }

    setLoading(true);
    const newLog = {
      id: uuidv4(),
      timestamp: new Date().toISOString(),
      note,
      place,
      tags,
      latitude: location?.latitude,
      longitude: location?.longitude,
      isAnonymous: true,
    };

    await LogRepository.addLog(newLog);
    setLoading(false);
    navigation.goBack();
  };

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={{ padding: 20 }}>
        <TouchableOpacity style={styles.photoBox}>
          <Text style={{ color: '#999' }}>📷 탭하여 사진 촬영 (준비중)</Text>
        </TouchableOpacity>

        <Text style={styles.label}>장소</Text>
        <TextInput
          style={styles.input}
          value={place}
          onChangeText={setPlace}
          placeholder="장소를 입력하세요"
        />

        <Text style={styles.label}>메모</Text>
        <TextInput
          style={[styles.input, { height: 100 }]}
          value={note}
          onChangeText={setNote}
          placeholder="지금 이 순간을 기록하세요"
          multiline
        />

        <Text style={styles.label}>#태그</Text>
        <TextInput
          style={styles.input}
          value={tags}
          onChangeText={setTags}
          placeholder="#카페, #산책"
        />

        <TouchableOpacity 
          style={[styles.saveButton, loading && { opacity: 0.7 }]} 
          onPress={handleSave}
          disabled={loading}
        >
          {loading ? <ActivityIndicator color="white" /> : <Text style={styles.saveText}>저장하기</Text>}
        </TouchableOpacity>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F7FB' },
  photoBox: {
    height: 200, backgroundColor: 'white', borderRadius: 20,
    justifyContent: 'center', alignItems: 'center', marginBottom: 20,
    borderWidth: 1, borderColor: '#eee'
  },
  label: { fontSize: 16, fontWeight: 'bold', marginBottom: 8, color: '#333' },
  input: {
    backgroundColor: 'white', padding: 15, borderRadius: 12, marginBottom: 20,
    borderWidth: 1, borderColor: '#ddd', fontSize: 16
  },
  saveButton: {
    backgroundColor: '#007AFF', padding: 16, borderRadius: 12, alignItems: 'center', marginTop: 10
  },
  saveText: { color: 'white', fontSize: 16, fontWeight: 'bold' }
});