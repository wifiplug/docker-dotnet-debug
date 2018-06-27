FROM microsoft/dotnet:2.1-runtime AS base 
MAINTAINER WIFIPLUG

# install SSH, required for communication to debugger
RUN apt-get update \ 
 && apt-get install -y --no-install-recommends openssh-server \ 
 && mkdir -p /run/sshd

# copy in configuration
COPY sshd_config /etc/ssh/sshd_config

# install debugger
RUN apt-get install zip unzip
RUN curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l ~/vsdbg

# expose debugger
EXPOSE 2222