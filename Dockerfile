
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
	&& wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip"

RUN echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
	&& ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle

RUN echo "Install google drive" \
    && mkdir gdrive \
    && cd gdrive \
    && curl -fLo gdrive "https://docs.google.com/uc?id=0B3X9GlR6EmbnQ0FtZmJJUXEyRTA&export=download" \
    && chmod +x gdrive

ENV PATH "$PATH:/gdrive"

ENV TZ=Asia/Bangkok
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone