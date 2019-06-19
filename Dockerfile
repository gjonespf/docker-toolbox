FROM 			mcr.microsoft.com/dotnet/core/runtime:2.2.5-alpine3.8
# powershell:6.2.1-alpine-3.8

MAINTAINER 		Gavin Jones <gjones@powerfarming.co.nz>
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

ARG 			PS_VERSION=6.2.0
ARG 			PS_PACKAGE=powershell-${PS_VERSION}-linux-alpine-x64.tar.gz
ARG 			PS_PACKAGE_URL=https://github.com/PowerShell/PowerShell/releases/download/v${PS_VERSION}/${PS_PACKAGE}
ARG 			PS_INSTALL_VERSION=6

RUN				apk update \
				&& apk add --no-cache git nano wget curl gnupg libunwind bash

#Docker bins
WORKDIR     	/home/toolbox/

#Docker via bins to get latest
#Just use Alpine package for now
RUN 			apk add --no-cache docker

#Docker compose
RUN 			curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
				chmod +x /usr/local/bin/docker-compose

#Docker machine
RUN				curl -L https://github.com/docker/machine/releases/download/v${DOCKER_MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
				chmod +x /usr/local/bin/docker-machine
	
#Minio tools
RUN				curl -L https://dl.minio.io/server/minio/release/linux-amd64/minio > /usr/local/bin/minio && \
				chmod +x /usr/local/bin/minio
RUN				curl -L https://dl.minio.io/client/mc/release/linux-amd64/mc > /usr/local/bin/mc && \
				chmod +x /usr/local/bin/mc

#
# Installing powershell-core
#
ADD ${PS_PACKAGE_URL} /tmp/linux.tar.gz
ENV PS_INSTALL_FOLDER=/opt/microsoft/powershell/$PS_INSTALL_VERSION
RUN mkdir -p ${PS_INSTALL_FOLDER}
RUN tar zxf /tmp/linux.tar.gz -C ${PS_INSTALL_FOLDER}

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

# Add users/groups to allow binding to host fs
RUN 			addgroup --gid 500 core && \
				adduser -h /home/core -s /bin/bash -u 500 -G core -D core && \
				adduser -h /home/octo -s /bin/bash -u 1000 -G core -D octo

#Set PSGallery to trusted, and install PS module PSDepend by default
#RUN				pwsh -c "Get-PSRepository; Set-PSRepository -Name PSGallery -InstallationPolicy Trusted"
#RUN				pwsh -c "Install-Module -Name PSDepend; Import-Module PSDepend"				

RUN 			echo $TAG >> build_tag
