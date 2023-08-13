import React from 'react';

import {ActivityIndicator, StyleSheet} from 'react-native';

import Video from 'react-native-video';

export default function App() {
  return (
    <>
      <ActivityIndicator style={styles.activityIndicator} size={'large'} />
      <Video
        source={{
          uri: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          // uri: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
          // title: 'Custom Title',
          // subtitle: 'Custom Subtitle',
          // description: 'Custom Description',
        }}
        style={[styles.fullScreen, StyleSheet.absoluteFillObject]}
        controls
        fullscreen
        resizeMode={'contain'}
        // chapters={[
        //   {
        //     title: 'Chapter 1',
        //     startTime: 0.0,
        //     endTime: 20.0,
        //   },
        //   {
        //     title: 'Chapter 2',
        //     startTime: 20.0,
        //     endTime: 40.0,
        //   },
        // ]}
        transportBarItems={[
          {
            title: 'Test',
            iconSystemName: 'heart',
            activeIconSystemName: 'heart.fill',
          },
        ]}
        onActionPress={console.log}
      />
    </>
  );
}

const styles = StyleSheet.create({
  fullScreen: {
    position: 'absolute',
    top: 0,
    left: 0,
    bottom: 0,
    right: 0,
  },
  activityIndicator: {
    position: 'absolute',
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
  },
});
