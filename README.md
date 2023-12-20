# docker-fc2-live-dl

[![CodeFactor](https://www.codefactor.io/repository/github/jim60105/docker-fc2-live-dl/badge?style=for-the-badge)](https://www.codefactor.io/repository/github/jim60105/docker-fc2-live-dl)  [![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/jim60105/docker-fc2-live-dl/scan.yml?label=IMAGE%20SCAN&style=for-the-badge)](https://github.com/jim60105/docker-fc2-live-dl/actions/workflows/scan.yml)

This is the docker image for [HoloArchivists/fc2-live-dl: Tool to download FC2 live streams](https://github.com/HoloArchivists/fc2-live-dl) from the community.

Get the Dockerfile at [GitHub](https://github.com/jim60105/docker-fc2-live-dl), or pull the image from [ghcr.io](https://ghcr.io/jim60105/fc2-live-dl) or [quay.io](https://quay.io/repository/jim60105/fc2-live-dl?tab=tags).

## Usage Command

Mount the current directory as `/recordings` and run fc2-live-dl with additional input arguments.  
The downloaded files will be saved to where you run the command.

```bash
 docker run -it -v ".:/recordings" ghcr.io/jim60105/fc2-live-dl [options] [fc2 url]
```

The `[options]`, `[fc2 url]` placeholder should be replaced with the options and arguments for fc2-live-dl. Check the [fc2-live-dl README](https://github.com/HoloArchivists/fc2-live-dl?tab=readme-ov-file#usage) for more information.

You can find all available tags at [ghcr.io](https://github.com/jim60105/docker-fc2-live-dl/pkgs/container/fc2-live-dl/versions?filters%5Bversion_type%5D=tagged) or [quay.io](https://quay.io/repository/jim60105/fc2-live-dl?tab=tags).

## Available Pre-built Image

This repository contains three Dockerfiles for building Docker images based on different base images:

| Dockerfile            | Base Image                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------ |
| [alpine.Dockerfile](alpine.Dockerfile)            | [Python official image 3.11-alpine](https://hub.docker.com/_/python/)                                                              |
| [ubi.Dockerfile](ubi.Dockerfile)        | [Red Hat Universal Base Image 9 Minimal](https://catalog.redhat.com/software/containers/ubi9/ubi-minimal/615bd9b4075b022acc111bf5) |
| [distroless.Dockerfile](distroless.Dockerfile) | [Google Distroless python3-debian12](https://github.com/GoogleContainerTools/distroless)                      |

And, built with the following code version of fc2-live-dl: main branch, v2.2.0, v2.1.3.

| Code Version | Alpine | UBI | Distroless |
| ------------ | ------ | --- | ---------- |
| [main branch](https://github.com/HoloArchivists/fc2-live-dl)  | `alpine`, `latest` | `ubi` | `distroless` |
| [v2.2.0](https://github.com/HoloArchivists/fc2-live-dl/releases/tag/v2.2.0)       | `v2.2.0`, `v2.2.0-alpine`| `v2.2.0-ubi` | `v2.2.0-distroless` |
| [v2.1.3](https://github.com/HoloArchivists/fc2-live-dl/releases/tag/v2.1.3)       | `v2.1.3`, `v2.1.3-alpine`| `v2.1.3-ubi` | `v2.1.3-distroless` |

> [!TIP]
> I've notice that that both the UBI version and the Distroless version offer no advantages over the Alpine version. So, unless you have specific requirements, _**please use the Alpine version**_. All of these base images are great, they were simply not suitable for our project.

### Build Command

> [!IMPORTANT]  
> Clone the Git repository recursively to include submodules:  
> `git clone --recursive https://github.com/jim60105/docker-fc2-live-dl.git`

> [!NOTE]  
> If you are using an earlier version of the docker client, it is necessary to [enable the BuildKit mode](https://docs.docker.com/build/buildkit/#getting-started) when building the image. This is because I used the `COPY --link` feature which enhances the build performance and was introduced in Buildx v0.8.  
> With the Docker Engine 23.0 and Docker Desktop 4.19, Buildx has become the default build client. So you won't have to worry about this when using the latest version.

For example, if you want to build the alpine image:

```bash
docker build -f alpine.Dockerfile -t fc2-live-dl:alpine .
```

## LICENSE

> [!NOTE]  
> The main program, [HoloArchivists/fc2-live-dl](https://github.com/HoloArchivists/fc2-live-dl), is distributed under [MIT](https://github.com/HoloArchivists/fc2-live-dl/blob/main/LICENSE).  
> Please consult their repository for access to the source code and licenses.  
> The following is the license for the Dockerfiles and CI workflows in this repository.

> [!CAUTION]
> A GPLv3 licensed Dockerfile means that you _**MUST**_ **distribute the source code with the same license**, if you
>
> - Re-distribute the image. (You can simply point to this GitHub repository if you doesn't made any code changes.)
> - Distribute a image that uses code from this repository.
> - Or **distribute a image based on this image**. (`FROM ghcr.io/jim60105/fc2-live-dl` in your Dockerfile)
>
> "Distribute" means to make the image available for other people to download, usually by pushing it to a public registry. If you are solely using it for your personal purposes, this has no impact on you.
>
> Please consult the [LICENSE](LICENSE) for more details.

<img src="https://github.com/jim60105/docker-fc2-live-dl/assets/16995691/102ae35d-cd95-4b38-8dbd-e1bfe6a1696f" alt="open graph" width="300" />

[GNU GENERAL PUBLIC LICENSE Version 3](LICENSE)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
