
FROM openjdk:8-jdk

RUN echo "Android SDK 28.0.3"
ENV ANDROID_SDK_TOOLS "26.1.1"

ENV ANDROID_HOME "/sdk-tools-linux"
ENV PATH "$PATH:${ANDROID_HOME}/tools"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      wget \
      tar \
      unzip \
      lib32stdc++6 \
      lib32z1 \
      git \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN echo "Download Android SDK" \
    && wget -q http://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O sdk-tools-linux.zip \
    && unzip -q sdk-tools-linux.zip -d sdk-tools-linux \
    && rm sdk-tools-linux.zip

RUN echo "Print sdkmanager version" && /sdk-tools-linux/tools/bin/sdkmanager --version

RUN echo "Make sure repositories.cfg exists" && \
    mkdir -p ~/.android/ && \
    touch ~/.android/repositories.cfg

RUN echo "Repos list" && \
    /sdk-tools-linux/tools/bin/sdkmanager --list

RUN echo "Install SDK" \
    && yes | /sdk-tools-linux/tools/bin/sdkmanager "platforms;android-26" "platforms;android-27" \
    && yes | /sdk-tools-linux/tools/bin/sdkmanager "platform-tools" \
    && yes | /sdk-tools-linux/tools/bin/sdkmanager "build-tools;28.0.3"
    # && echo y | /android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-android-m2repository \
    # && echo y | /android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-google-google_play_services \
    # && echo y | /android-sdk-linux/tools/android --silent update sdk --no-ui --all --filter extra-google-m2repository




# RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip > /sdk.zip && \
#     unzip /sdk.zip -d /sdk && \
#     rm -v /sdk.zip

# RUN mkdir -p $ANDROID_HOME/licenses/ \
#   && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license \
#   && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

# ADD packages.txt /sdk
# RUN mkdir -p /root/.android && \
#   touch /root/.android/repositories.cfg && \
#   ${ANDROID_HOME}/tools/bin/sdkmanager --update 

# RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt && \
#     ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}

RUN echo "Installing Yarn Deb Source" \
	&& curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN echo "Installing Node.JS" \
	&& curl -sL https://deb.nodesource.com/setup_10.x | bash 

ENV BUILD_PACKAGES yarn nodejs
RUN echo "Installing Additional Libraries" \
	 && rm -rf /var/lib/gems \
	 && apt-get update && apt-get install $BUILD_PACKAGES -qqy --no-install-recommends

ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 4.4

RUN echo "Downloading Gradle" \
	&& wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"

RUN echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
	&& ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle

RUN echo "Install google drive" \
    && mkdir gdrive \
    && cd gdrive \
    && curl -fLo "https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download" \
    && chmod +x gdrive \
    && echo 4/dADusQpoBy0uE7XUcG1jJKH8tg7w7S0sprrEoK7uf3f7LFG5u_zdEnE | ./gdrive about

ENV PATH "$PATH:/gdrive"