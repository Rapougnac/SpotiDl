# spotidl - A Spotify Downloader (As if there weren't enough of them [<img src="https://cdn.discordapp.com/emojis/834119948170821652.png?size=512" height="45" />](https://bit.ly/31BnJAp))

Lemme just a moment (like 2-3 years).. to create this magnificent project

## Targets
For now, I'll focus on building a mobile app, but if I have the time, I'll make this repository compatible with desktop. (Maybe web, but idk.).


## Why this project ? 
Yeah, this is a good question- 
There's already a bunch of apps that downloads music from youtube.

But there is 2 points why:
1. A friend of mine was talking to me to make this project, I started with [`react-native`](https://reactnative.dev/) in [TypeScript](https://www.typescriptlang.org/).<br /> But I wasn't good at this, so I left this project aside for a while. It's only recently that I started this project again, but in [Dart](https://dart.dev/) this time.
2. I've not seen a lot of downloaders in dart, so, I'll make one.

## How it works ? 
Actually, it's very simple, its search from YouTube and download the possibly matched song.
The search algorithm is based on the duration of the video.  
E.g: 
If try to download "Imagine Dragons Believer", it'll compare the duration of the music in spotify to the matched song.
This is not 100% precise, but it'll work most of the time