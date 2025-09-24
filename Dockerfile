FROM ghcr.io/cirruslabs/flutter:3.32.0
RUN apt-get update && apt-get -y install cmake ninja-build clang pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev && rm -rf /var/lib/apt/lists/*
RUN yes | sdkmanager "platforms;android-33"
RUN yes | sdkmanager "platforms;android-35"
RUN yes | sdkmanager "ndk;27.0.12077973"
RUN yes | sdkmanager "cmake;3.22.1"
RUN yes | sdkmanager --licenses