FROM 			mcr.microsoft.com/dotnet/core/runtime:2.2.5-alpine3.8
# powershell:6.2.1-alpine-3.8

MAINTAINER 		Gavin Jones <gjones@powerfarming.co.nz>
# https://github.com/moby/moby/releases/
# https://download.docker.com/linux/static/stable/x86_64/
ENV 			DOCKER_VERSION 18.06.1-ce
# https://github.com/docker/compose/releases/
ENV 			DOCKER_COMPOSE_VERSION 1.24.0
# https://github.com/docker/machine/releases/
ENV 			DOCKER_MACHINE_VERSION 0.16.1
ENV	 			MACH_ARCH x86_64
ENV 			TERM xterm
#To override if needed
ARG 			TAG=dev
ENV 			TAG ${TAG}
# https://www.microsoft.com/net/learn/get-started/linuxubuntu
ENV				DOTNET_PACKAGE dotnet-sdk-2.1
# https://github.com/PowerShell/PowerShell/releases
# Use official list instead
#ENV 			POWERSHELL_DOWNLOAD_URL https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.2/powershell_6.0.0-beta.2-1ubuntu1.16.04.1_amd64.deb
#ENV				DISTRIB_CODENAME bionic
ENV				DISTRIB_RELEASE 18.04

ARG PS_VERSION=6.2.0
ARG PS_PACKAGE=powershell-${PS_VERSION}-linux-alpine-x64.tar.gz
ARG PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}
ARG PS_INSTALL_VERSION=6

RUN				apk update \
				&& apk add git nano wget curl 

# RUN 			apt-get update  \
# 				&& apt-get install -y git subversion nano wget curl iputils-ping dnsutils  \
# 				&& apt-get clean

#Docker bins
WORKDIR     /home/toolbox/

#Docker compose
RUN 			curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
				chmod +x /usr/local/bin/docker-compose

#Docker machine
RUN			curl -L https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
				chmod +x /usr/local/bin/docker-machine
	
#Minio tools
RUN			curl -L https://dl.minio.io/server/minio/release/linux-amd64/minio > /usr/local/bin/minio && \
				chmod +x /usr/local/bin/minio
RUN			curl -L https://dl.minio.io/client/mc/release/linux-amd64/mc > /usr/local/bin/mc && \
				chmod +x /usr/local/bin/mc

# Some other basic tools
RUN apk add gnupg

ADD ${PS_PACKAGE_URL} /tmp/linux.tar.gz
# define the folder we will be installing PowerShell to
ENV PS_INSTALL_FOLDER=/opt/microsoft/powershell/$PS_INSTALL_VERSION

# Create the install folder
RUN mkdir -p ${PS_INSTALL_FOLDER}

# Unzip the Linux tar.gz
RUN tar zxf /tmp/linux.tar.gz -C ${PS_INSTALL_FOLDER}
# dotnet core Prerequisites
RUN apk add libunwind

### Install .NET Core, nuget, PowerShell
# Install dotnet dependencies and ca-certificates
RUN apk add --no-cache \
    ca-certificates \
    less \
    \
    # PSReadline/console dependencies
    ncurses-terminfo-base \
    \
    # .NET Core dependencies
    krb5-libs \
    libgcc \
    libintl \
    libssl1.0 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs \
    && apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
    lttng-ust \
    \
    # Create the pwsh symbolic link that points to powershell
    && ln -s ${PS_INSTALL_FOLDER}/pwsh /usr/bin/pwsh \
    \
    # Create the pwsh-preview symbolic link that points to powershell
    && ln -s ${PS_INSTALL_FOLDER}/pwsh /usr/bin/pwsh-preview \
    # Give all user execute permissions and remove write permissions for others
    && chmod a+x,o-w ${PS_INSTALL_FOLDER}/pwsh 
	# \
    # intialize powershell module cache
    # && pwsh \
    #     -NoLogo \
    #     -NoProfile \
    #     -Command " \
    #       \$ErrorActionPreference = 'Stop' ; \
    #       \$ProgressPreference = 'SilentlyContinue' ; \
    #       while(!(Test-Path -Path \$env:PSModuleAnalysisCachePath)) {  \
    #         Write-Host "'Waiting for $env:PSModuleAnalysisCachePath'" ; \
    #         Start-Sleep -Seconds 6 ; \
    #       }"
		  
# RUN 			apt-get install apt-transport-https curl -y \
# 				&& apt-get install --reinstall ca-certificates \
# 				&& curl https://packages.microsoft.com/config/ubuntu/$DISTRIB_RELEASE/prod.list > /etc/apt/sources.list.d/microsoft.list \
# 				&& curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
# 				&& apt-get update \
# 				#&& sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list' \
# 				&& sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-bionic-prod bionic main" > /etc/apt/sources.list.d/dotnetdev.list' \
# 				&& wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
# 				&& dpkg -i packages-microsoft-prod.deb \
# 				&& apt-get update \
# #				&& apt-get install ca-certificates \
# 				&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893 \
# 				&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys B02C46DF417A0893 \
# 				&& apt-key adv --keyserver packages.microsoft.com --recv-keys EB3E94ADBE1229CF \
# 				&& apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893 \
# 				# TODO: Fix issues with unauthenticated
# 				&& apt-get install ${DOTNET_PACKAGE} --allow-unauthenticated -y \
# 				&& apt-get install -y powershell \
# 				&& mkdir /powershell \
# 				&& DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata unzip nuget lastpass-cli \
# 				&& apt-get clean


### Set some environment variables
# RUN 			curl -SL $POWERSHELL_DOWNLOAD_URL --output powershell.deb \
# 				&& apt-get install libunwind8 libicu55 \
# 				&& dpkg --install powershell.deb \
# 				&& rm powershell.deb \
# 				&& apt-get clean

#Set PSGallery to trusted, and install PS module PSDepend by default
RUN				pwsh -c "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
#RUN				powershell -c "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
#PSDepend not currently working... Re-enable when it does
RUN				pwsh -c "Install-Module -Name PSDepend; Import-Module PSDepend"				

RUN 			echo $TAG >> build_tag
