# flit

Experimental tool for understanding and tweaking https://github.com/flutter/ apps


## Getting started

- Check this out as a sibling of the flutter checkout folder
- Start the iOS simulator ```open -a simulator.app```
- Precache flutter
```
cd ../flutter
./bin/flutter precache
cd ../flit
```
- Start the app runner: 
```
cd mutation_runner
pub get
../../flutter/bin/cache/dart-sdk/bin/dart lib/main.dart 
```
- Start the desktop UI server (from the flit root)
```
cd server2
pub get
pub serve
```
- visit http://localhost:8080 the test UI should now appear
