# gitlab-ci-react-native-android
This Docker image contains react-native and the Android SDK and most common packages necessary for building Android apps in a CI tool like GitLab CI. 

A `.gitlab-ci.yml` with caching of your project's dependencies would look like this:

```
image: zeemyself/rn-android

stages:
- build

cache:
  paths:
  - node_modules/
  - android/.gradle/

build:
  stage: build
  image: zeemyself/rn-android
  script:
    - yarn
    - cd android/
    - chmod +x ./gradlew
    - ./gradlew assembleRelease
  artifacts:
    paths:
      - android/app/build/outputs/apk
  when: manual
```
