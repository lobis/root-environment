# About

Building this Dockerfile gives you simple ready to use development environment for _ROOT_ (https://root.cern).

It installs _ROOT_ and its documented prerequisites (https://root.cern.ch/build-prerequisites#fedora) on a _CentOS_ 7 base image. It also installs _anaconda2_ (_Python_ 2.x instead of 3.x for compatibility with built root binaries).

# How to run

To build the container simply go to the directory containing _Dockerfile_ (with this exact name) and run the following command replacing _$notebook_image_name_ with the name you want to give the image (e.g. _root_).
```
$image_name = "lobis/root"
docker build -t $notebook_image_name .
```

Alternatively you can directly pull the image from Docker Hub which is synchronized with this repository. This is the recommended method of obtaining the image.
```
docker pull lobis/root
```

Running the container launches the notebook server on port 8888. If you want to use _SSH_ you would need to map port 22. Use this command to run the container. It is also recommended to mount a volume in order to save the notebooks you work on, you do this via the _-v_ flag for example ```-v $workdir\notebooks":/home/notebooks"``` mounts your local directory _$workdir\notebooks_ to container's _/home/notebooks_
```
docker run -d --name="root" -p 8888:8888 -p 22:22 -v $workdir\notebooks":/home/notebooks" $notebook_image_name
```
# Features

Running this container gives you access to a jupyter notebook server with the option to use _ROOT_ _C++_ kernel or a _Python 2_ kernel with the option of running ROOT (https://root.cern.ch/notebooks/HowTos/HowTo_ROOT-Notebooks.html).

Also _SSH_ can be enabled. _X11 forwarding_ is also enabled which can be used to load _ROOT GUI_ windows. To enable _SSH_ run the following command (replace _$root-environment-container_ with the name/id of you container) after running your container.
```
docker exec -d $root-environment-container /usr/sbin/sshd -D
```
In order to test the notebook functionality you can follow the example provided in the documentation (https://root.cern.ch/notebooks/HowTos/HowTo_ROOT-Notebooks.html). Run the following code in a _Python 2_ notebook.

```
import ROOT

h = ROOT.TH1F("gauss","Example histogram",100,-4,4)
h.FillRandom("gaus")

c = ROOT.TCanvas("myCanvasName","The Canvas Title",800,600)
h.Draw()

c.Draw()

ROOT.enableJSVis()
```

Which should give you a nice interactive gaussian histogram.

# Quick setup in Windows (PowerShell)

Using Windows PowerShell you can run the following code snippets in order to quickly build and run the container.

## Build

The following commands will download the Dockerfile and build the image giving it the name "root".

```
$workdir = "~\Documents\ROOT"
md -Force "$workdir"
cd $workdir

wget https://raw.githubusercontent.com/luisobis/root-environment/master/Dockerfile -outfile Dockerfile

$image_name = "lobis/root"
docker build -t $image_name .
```

Alternatively you can directly pull the image from Docker Hub.
```
docker pull lobis/root
```

## Run

The following commands will launch the container with SSH enabled and create and mount a _notebooks_ directory in order to have persistance. This is what I use to set up my working environment.

```
$workdir = "~\Documents\ROOT"
cd $workdir
md -Force "$workdir\notebooks"

$image_name = "lobis/root"

docker stop root
docker rm root
docker system prune -f

docker run -d --name="root" -p 8888:8888 -p 22:22 -v $workdir\notebooks":/home/notebooks" $image_name
docker exec -d root /usr/sbin/sshd -D
docker exec -it root /bin/bash
```
