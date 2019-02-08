# About

Building this Dockerfile gives you simple ready to use development environment for _ROOT_ (https://root.cern).

It installs _ROOT_ and its documented prerequisites (https://root.cern.ch/build-prerequisites#fedora) on a _CentOS_ 7 base image. It also installs _anaconda2_ (_Python_ 2.x instead of 3.x for compatibility with built root binaries).

# Features

Running this container gives you access to a jupyter notebook server with the option to use _ROOT_ _C++_ kernel or a _Python 2_ kernel with the option of running ROOT (https://root.cern.ch/notebooks/HowTos/HowTo_ROOT-Notebooks.html).

Also _SSH_ can be enabled. _X11 forwarding_ is also enabled which can be used to load _ROOT GUI_ windows. To enable _SSH_ run the following command (replace _$root-environment-container_ with the name/id of you container).
```
docker exec -d $root-environment-container /usr/sbin/sshd -D
```

# How to run

To build the container simply go to the directory containing _Dockerfile_ (with this exact name) and run the following command replacing _$notebook_image_name_ with the name you want to give the image (e.g. _root_).
```
#docker build -t $notebook_image_name .
```

Running the container launches the notebook server on port 8888. If you want to use _SSH_ you would need to map port 22. Use this command to run the container. It is also recommended to mount a volume in order to save the notebooks you work on, you do this via the _-v_ flag for example ```-v $workdir\notebooks":/home/notebooks"``` mounts your local directory _$workdir\notebooks_ to container's _/home/notebooks_
```
docker run -d --name="root" -p 8888:8888 -p 22:22 -v $workdir\notebooks":/home/notebooks" $notebook_image_name
```
