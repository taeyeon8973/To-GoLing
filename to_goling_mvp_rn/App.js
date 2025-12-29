import 'react-native-get-random-values'; // 무조건 1등
import React, { useEffect } from 'react';
import { Alert } from 'react-native';
import { NavigationContainer, createNavigationContainerRef } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import NfcManager, { NfcEvents } from 'react-native-nfc-manager'; // NFC 부품

import MainTabs from './src/screens/MainTabs';
import NewLogScreen from './src/screens/NewLogScreen';
import LogDetailScreen from './src/screens/LogDetailScreen';

const Stack = createNativeStackNavigator();
// 앱 어디서든 화면 이동을 할 수 있게 해주는 리모컨
export const navigationRef = createNavigationContainerRef();

export default function App() {

  useEffect(() => {
    async function initNfc() {
      try {
        // 1. NFC 기능 시동 걸기
        await NfcManager.start();

        // 2. "혹시 나 꺼져있을 때 태그 찍어서 켰니?" 확인 (앱 실행 직후 체크)
        const bgTag = await NfcManager.getBackgroundTag();
        if (bgTag) {
          // 태그로 앱을 켰다면 바로 글쓰기 화면으로!
          setTimeout(() => {
            if (navigationRef.isReady()) {
              navigationRef.navigate('NewLog');
            }
          }, 500); // 네비게이션 준비될 때까지 0.5초 대기
        }

        // 3. 앱 켜진 상태에서 태그 감지 리스너 등록
        NfcManager.setEventListener(NfcEvents.DiscoverTag, (tag) => {
          console.log('NFC 태그 발견!', tag);
          // 태그 닿으면 바로 글쓰기 화면으로 이동
          if (navigationRef.isReady()) {
            navigationRef.navigate('NewLog');
          }
        });

        // 4. 안드로이드에게 "나 NFC 태그 기다릴게"라고 등록
        await NfcManager.registerTagEvent();
        
      } catch (ex) {
        console.warn('NFC 에러:', ex);
      }
    }

    initNfc();

    // 앱 꺼질 때 뒷정리
    return () => {
      NfcManager.setEventListener(NfcEvents.DiscoverTag, null);
      NfcManager.unregisterTagEvent().catch(() => {});
    };
  }, []);

  return (
    <NavigationContainer ref={navigationRef}>
      <Stack.Navigator>
        {/* 메인 탭 화면 */}
        <Stack.Screen 
          name="Main" 
          component={MainTabs} 
          options={{ headerShown: false }} 
        />
        
        {/* 새 기록 작성 화면 */}
        <Stack.Screen 
          name="NewLog" 
          component={NewLogScreen} 
          options={{ title: '순간 기록하기', presentation: 'modal' }} 
        />

        {/* 상세 화면 */}
        <Stack.Screen 
          name="Detail" 
          component={LogDetailScreen} 
          options={{ title: '기록 상세' }} 
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}