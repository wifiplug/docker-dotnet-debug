# Introduction

This image provides versions of the .NET Core runtime built for easier debugging support. The base image is built from the .NET runtime with a SSH server and the VSDebugger pre-installed.

# Setting Up

To use the image you need to copy a SSH public key and modify how your application is ran. To generate an SSH keypair you can use the following command, it is recommended that you enter a passphrase when prompted:

```sh
ssh-keygen -t rsa -f ./debugkey
```

This will generate two files, `debugkey` and `debugkey.pub`. The first is the private key and should be stored securely, the latter is used next. In your docker image, add the following line to write the public key to the SSH servers authorised keys.

```docker
RUN mkdir /root/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNv3QhqPOc0NthhDDbgkuspynfzZMJtLahoHPvTub9sWBZN5gTUNBMdVF8DEn9MQ8Uuf81rGAW0Jr8LDg7tSvKSNnL1+6wi7MolwE+KXzWwwX7DdvFMzx+lM9VHxC6BckjicG6pCTJVZKqzuONWb3uL/JjSeDDjYb8vMkhE4Uv4L8g4MzpZlP4QlJ8LRfv+pPqhoK6rloHvc3cFfRIn2wyoeXNcR/PGr/xP0Wv3c3y8FXlw936mOTAbZjWxnnXG7ok+iuKQcs80ayStL9LFISzCg7H6+wQlXvLAPOlsUXv+eB62AAvs6koAR5vGm4Sdr0dxJvyTaL+6U+V7FvC5FTn" > root/.ssh/authorized_keys
```

Now create a file named `run.sh` in your image, entering the first line followed by your usual entrypoint. For example:

```sh
#!/bin/bash 
/usr/sbin/sshd -D &
dotnet ExampleApp.dll
```

Then alter your dockerfile to copy the script and run it in your entrypoint. A full example of your applications dockerfile should look similar to this:

```docker
# Build
FROM microsoft/dotnet:2.1-sdk AS build
WORKDIR /app
COPY ./src/ExampleApp ./

RUN dotnet restore
RUN dotnet publish -c RELEASE -o build

# Run
FROM wifiplug/dotnet-debug AS runtime
WORKDIR /app

COPY --from=build /app/build .
COPY ./run.sh /app
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNv3QhqPOc0NthhDDbgkuspynfzZMJtLahoHPvTub9sWBZN5gTUNBMdVF8DEn9MQ8Uuf81rGAW0Jr8LDg7tSvKSNnL1+6wi7MolwE+KXzWwwX7DdvFMzx+lM9VHxC6BckjicG6pCTJVZKqzuONWb3uL/JjSeDDjYb8vMkhE4Uv4L8g4MzpZlP4QlJ8LRfv+pPqhoK6rloHvc3cFfRIn2wyoeXNcR/PGr/xP0Wv3c3y8FXlw936mOTAbZjWxnnXG7ok+iuKQcs80ayStL9LFISzCg7H6+wQlXvLAPOlsUXv+eB62AAvs6koAR5vGm4Sdr0dxJvyTaL+6U+V7FvC5FTn" > root/.ssh/authorized_keys

EXPOSE 80

ENTRYPOINT ["bash", "/app/run.sh"]
```