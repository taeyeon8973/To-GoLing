import React, { useState, useCallback } from 'react';
import { View, Text, FlatList, StyleSheet, TouchableOpacity, ScrollView, RefreshControl, Image, SafeAreaView } from 'react-native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { useFocusEffect } from '@react-navigation/native';
import MapView, { Marker } from 'react-native-maps';
import { LogRepository } from '../services/storage';
import { Ionicons } from '@expo/vector-icons'; 

// 🎨 공통 스타일 (배경색, 카드 모양 등)
const theme = {
  bg: '#F5F7FB',
  text: '#111827',
  primary: '#5E6BFF', // 플러터 느낌의 보라빛 파랑
  card: '#FFFFFF',
  radius: 24,
};

// 1. 홈(지도+대시보드) 탭 (사진 1번 복원)
function MapDashboardScreen({ navigation }) {
  const [logs, setLogs] = useState([]);
  const [refreshing, setRefreshing] = useState(false);

  const loadData = async () => {
    const data = await LogRepository.getLogs();
    setLogs(data);
  };

  useFocusEffect(
    useCallback(() => {
      loadData();
    }, [])
  );

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  return (
    <ScrollView 
      style={styles.container} 
      contentContainerStyle={{ padding: 20, paddingBottom: 100 }}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
    >
      {/* 헤더 */}
      <View style={styles.headerRow}>
        <Text style={styles.headerTitle}>AI가 쓴 오늘의 일기</Text>
      </View>

      {/* AI 요약 카드 */}
      <View style={styles.card}>
        <Text style={styles.cardText}>
          {logs.length === 0 
            ? '오늘 기록된 순간이 아직 없어요.\n오른쪽 아래 + 버튼으로 첫 기록을 남겨보세요.' 
            : `오늘 총 ${logs.length}개의 순간을 기록했어요.\nAI가 곧 멋진 일기를 써줄 거예요!`}
        </Text>
      </View>

      <View style={{ height: 24 }} />

      {/* 작년 오늘 */}
      <Text style={styles.headerTitle}>작년 오늘</Text>
      <View style={styles.card}>
        <Text style={styles.cardText}>작년 오늘의 기록이 없어요.</Text>
      </View>

      <View style={{ height: 24 }} />

      {/* 지도 섹션 */}
      <Text style={styles.headerTitle}>지도</Text>
      <View style={styles.mapContainer}>
        <MapView
          style={styles.map}
          initialRegion={{
            latitude: 37.4598, // 서울대 입구 근처 (사진 참고)
            longitude: 126.9519,
            latitudeDelta: 0.015,
            longitudeDelta: 0.015,
          }}
          scrollEnabled={false} // 대시보드에서는 스크롤 막기
          liteMode={true} // 가볍게
        >
          {logs.map((log) => (
             log.latitude && (
              <Marker
                key={log.id}
                coordinate={{ latitude: log.latitude, longitude: log.longitude }}
              />
            )
          ))}
        </MapView>
        {/* 터치하면 전체 지도로 이동하게 하려면 여기에 투명 버튼 추가 가능 */}
      </View>
      <Text style={styles.subText}>최근 기록 위치</Text>

    </ScrollView>
  );
}

// 2. 피드 탭 (사진 2번 복원)
function FeedScreen() {
  const [logs, setLogs] = useState([]);
  const [refreshing, setRefreshing] = useState(false);

  const loadData = async () => {
    const data = await LogRepository.getLogs();
    setLogs(data.reverse());
  };

  useFocusEffect(useCallback(() => { loadData(); }, []));

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  return (
    <View style={styles.container}>
      <View style={styles.navBar}>
        <Text style={styles.navTitle}>익명 피드</Text>
      </View>
      
      {logs.length === 0 ? (
        <View style={styles.centerEmpty}>
          <Text style={styles.emptyText}>아직 익명으로 공유된 기록이 없어요.{'\n'}새 기록에서 익명 공유를 켜보세요.</Text>
        </View>
      ) : (
        <FlatList
          data={logs}
          keyExtractor={(item) => item.id}
          refreshing={refreshing}
          onRefresh={onRefresh}
          contentContainerStyle={{ padding: 16 }}
          renderItem={({ item }) => (
            <View style={styles.feedCard}>
              <Text style={styles.feedPlace}>{item.place || '어딘가에서'}</Text>
              <Text style={styles.feedNote}>{item.note}</Text>
              {item.tags ? <Text style={styles.feedTags}>{item.tags}</Text> : null}
              <Text style={styles.feedDate}>익명 · {new Date(item.timestamp).toLocaleDateString()}</Text>
            </View>
          )}
        />
      )}
    </View>
  );
}

// 3. 발견(트렌드) 탭 (사진 3번 복원)
function DiscoverScreen() {
  return (
    <View style={styles.container}>
      <View style={styles.navBar}>
        <Text style={styles.navTitle}>루틴 · 발견 · 트렌드</Text>
      </View>
      <ScrollView contentContainerStyle={{ padding: 20 }}>
        <Text style={styles.headerTitle}>Seoul 지역 챌린지</Text>
        
        {/* 챌린지 아이템 */}
        <View style={styles.actionCard}>
          <View style={{ flex: 1 }}>
            <Text style={styles.actionTitle}>#하늘사진</Text>
            <Text style={styles.actionSub}>오늘 하늘 한 컷</Text>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            <Text style={{ fontWeight: 'bold', marginRight: 8 }}>+20p</Text>
            <TouchableOpacity style={styles.smallBtn}><Text style={styles.smallBtnText}>참여</Text></TouchableOpacity>
          </View>
        </View>

         <View style={styles.actionCard}>
          <View style={{ flex: 1 }}>
            <Text style={styles.actionTitle}>#동네산책</Text>
            <Text style={styles.actionSub}>가까운 골목 기록</Text>
          </View>
          <View style={{ flexDirection: 'row', alignItems: 'center' }}>
            <Text style={{ fontWeight: 'bold', marginRight: 8 }}>+10p</Text>
            <TouchableOpacity style={styles.smallBtn}><Text style={styles.smallBtnText}>참여</Text></TouchableOpacity>
          </View>
        </View>

        <View style={{ height: 24 }} />
        <Text style={styles.headerTitle}>AI 큐레이션 기사</Text>
        
        <View style={styles.articleCard}>
           <Text style={styles.articleTitle}>오늘 Seoul 20대는 어디에 모였나?</Text>
           <Text style={styles.articleSub}>카페·학교 주변 업로드 급증. 오후 5시 피크.</Text>
           <View style={{ flexDirection: 'row', marginTop: 12 }}>
             <TouchableOpacity style={styles.tagBtn}><Text style={styles.tagBtnText}>트렌드</Text></TouchableOpacity>
             <TouchableOpacity style={{ padding: 8 }}><Text style={{ color: 'gray' }}>보기</Text></TouchableOpacity>
           </View>
        </View>

      </ScrollView>
    </View>
  );
}

// 4. 프로필 탭 (사진 4번 복원)
function ProfileScreen() {
  const [logCount, setLogCount] = useState(0);

  useFocusEffect(useCallback(() => {
    LogRepository.getLogs().then(d => setLogCount(d.length));
  }, []));

  return (
    <View style={styles.container}>
      <View style={styles.navBar}>
        <Text style={styles.navTitle}>내 아카이브</Text>
      </View>
      <ScrollView contentContainerStyle={{ padding: 20 }}>
        <View style={styles.card}>
          <Text style={styles.headerTitle}>Lucy의 기록</Text>
          <View style={{ height: 8 }} />
          <Text style={styles.cardText}>총 {logCount}개의 순간을 기록했어요.</Text>
        </View>

        <View style={{ height: 24 }} />
        <Text style={styles.headerTitle}>최근 기록</Text>
        <Text style={[styles.subText, { marginTop: 8 }]}>아직 기록이 없어요.</Text>
      </ScrollView>
    </View>
  );
}

const Tab = createBottomTabNavigator();

export default function MainTabs({ navigation }) {
  return (
    <View style={{ flex: 1, backgroundColor: theme.bg }}>
      <Tab.Navigator
        screenOptions={({ route }) => ({
          headerShown: false,
          tabBarStyle: {
            backgroundColor: '#fff',
            borderTopWidth: 0,
            elevation: 0,
            height: 60,
            paddingBottom: 8,
            paddingTop: 8,
          },
          tabBarLabelStyle: { fontSize: 12, fontWeight: '500' },
          tabBarActiveTintColor: '#111',
          tabBarInactiveTintColor: '#999',
          tabBarIcon: ({ focused, color }) => {
            let name = 'map-outline';
            if (route.name === '지도') name = focused ? 'map' : 'map-outline';
            else if (route.name === '피드') name = focused ? 'chatbubble-ellipses' : 'chatbubble-ellipses-outline';
            else if (route.name === '발견') name = focused ? 'trending-up' : 'trending-up-outline';
            else if (route.name === '프로필') name = focused ? 'person' : 'person-outline';
            return <Ionicons name={name} size={24} color={color} />;
          },
        })}
      >
        <Tab.Screen name="지도" component={MapDashboardScreen} />
        <Tab.Screen name="피드" component={FeedScreen} />
        <Tab.Screen name="발견" component={DiscoverScreen} />
        <Tab.Screen name="프로필" component={ProfileScreen} />
      </Tab.Navigator>

      {/* 둥근 + 버튼 (플로팅) */}
      <TouchableOpacity
        style={styles.fab}
        onPress={() => navigation.navigate('NewLog')}
      >
        <Ionicons name="add" size={28} color="#111" />
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: theme.bg },
  
  // 네비게이션 바 (헤더)
  navBar: { backgroundColor: theme.bg, padding: 16, alignItems: 'center', paddingTop: 50 },
  navTitle: { fontSize: 18, fontWeight: '600', color: theme.text },

  // 텍스트 스타일
  headerTitle: { fontSize: 18, fontWeight: '700', color: theme.text, marginBottom: 8 },
  subText: { fontSize: 13, color: '#9CA3AF' },
  emptyText: { textAlign: 'center', color: '#6B7280', fontSize: 15, lineHeight: 22 },

  // 카드 스타일 (둥근 모서리, 흰색 배경)
  card: {
    backgroundColor: theme.card,
    borderRadius: theme.radius,
    padding: 20,
    marginBottom: 4,
  },
  cardText: { fontSize: 15, lineHeight: 22, color: '#374151' },

  // 지도 컨테이너
  mapContainer: {
    height: 200,
    borderRadius: theme.radius,
    overflow: 'hidden',
    backgroundColor: '#E5E7EB',
    marginTop: 8,
    marginBottom: 4,
  },
  map: { width: '100%', height: '100%' },
  
  // 피드 스타일
  feedCard: {
    backgroundColor: theme.card,
    borderRadius: theme.radius,
    padding: 20,
    marginBottom: 12,
  },
  feedPlace: { fontSize: 15, fontWeight: '700', marginBottom: 4 },
  feedNote: { fontSize: 15, color: '#374151', marginBottom: 8 },
  feedTags: { fontSize: 13, color: '#6B7280', marginBottom: 4 },
  feedDate: { fontSize: 12, color: '#9CA3AF' },
  centerEmpty: { flex: 1, justifyContent: 'center', alignItems: 'center', paddingBottom: 100 },

  // 발견 탭 스타일
  actionCard: {
    backgroundColor: theme.card, borderRadius: theme.radius, padding: 16, marginBottom: 8,
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between'
  },
  actionTitle: { fontSize: 14, fontWeight: '700' },
  actionSub: { fontSize: 12, color: 'gray', marginTop: 2 },
  smallBtn: { backgroundColor: '#EEF2FF', paddingHorizontal: 12, paddingVertical: 8, borderRadius: 8 },
  smallBtnText: { color: theme.primary, fontWeight: '600', fontSize: 13 },
  
  articleCard: { backgroundColor: theme.card, borderRadius: theme.radius, padding: 20 },
  articleTitle: { fontSize: 15, fontWeight: '700', marginBottom: 6 },
  articleSub: { fontSize: 13, color: 'gray' },
  tagBtn: { backgroundColor: '#EEF2FF', paddingHorizontal: 12, paddingVertical: 6, borderRadius: 8, marginRight: 8 },
  tagBtnText: { color: theme.primary, fontSize: 12, fontWeight: '600' },

  // 플로팅 버튼 (우측 하단 +)
  fab: {
    position: 'absolute', bottom: 90, right: 20,
    width: 56, height: 56, borderRadius: 20, // 동글동글한 사각형
    backgroundColor: '#DCE4FF', // 사진 속 연보라색
    justifyContent: 'center', alignItems: 'center',
    shadowColor: '#000', shadowOpacity: 0.1, shadowRadius: 10, elevation: 5
  },
});