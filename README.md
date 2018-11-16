# rn-android
Docker image for build android APK from gitlabci

Example of  `.gitlab-ci.yml`

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
