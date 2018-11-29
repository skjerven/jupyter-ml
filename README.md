## Jupyter-ML

This is a simple container for running a Machine Learning-focused JupyterHub instance in a Docker container.  It's based off of [Jupyter-Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/) ([Git repo](https://github.com/jupyter/docker-stacks)), and makes use of the [jupyter-tensorflow image](https://github.com/jupyter/docker-stacks/tree/master/tensorflow-notebook).

There are a number of pacakges in this image, but the main ones are:

* Tensorflow
* Tensorboard
* Python 3
* Keras
* Scipy
* Matplotlib
* Cython
* Numba
* Bokeh
* H5py
* Pandas
* Scikit-learn & Scikit-image

## Pre-requisites

All you need to run this is 

* docker
* docker-compose

These should be pre-installed on Nimbus VMs, and if you want to run on a local machine you can install them via your favorite package manager (e.g. apt, yum, brew)

## Getting Started

You can either clone this repo and build the image yourself, or simply pull the image from DockerHub.

### Building ###

To clone the repo and build you can run the following:

```
git clone ADDRESS HERE

cd jupyter-ml

docker build -t <docker repo>/jupyter-ml .
```

This will take several minutes...go get a coffee.  Rebuilding the image is helpful if you want to add your packages.

### Pulling ###

If you'd rather just use the pre-built image, you can pull from DockerHub:

```
docker pull bskjerven/jupyter-ml:latest
```

## Overview of Running Jupyter Hub

Running this container will start a Jupyter Notebook server, and expose it on port 8888.  You can then point your web browser to

```
http://<host>:888/?token=<token>
```

Here `<host>` is the hostname or IP address of the server where your container is running.  If you're running this on your local machine, you can use either

`127.0.0.1` or `localhost`

If you're running on a Nimbus VM, you'll use the public IP address (`146.X.X.X`)

The `<token>` is a secret token created by the Jupyter Notebook server at startup.  You can query the running to get this value, and enter in the login page you see (more on this later).

 **NOTE**: If you're running on a Nimbus VM you'll need to edit your security groups and open up port **8888**.

### Starting via `docker run`

To run this from the command line:

```
docker run --rm -p 8888:8888 -v /some/tutorial/path:/home/jovyan/work bskjerven/jupyter-ml
```

The Docker run flags are

* `--rm` Automatically remove the container after it exits

* `-p 8888:8888` Expose port 8888 on the host machine as port 8888 inside the container

* `-v /some/tutorial/path:/home/jovyan/work` Mount the host directory `/some/tutorial/path` to the directory `/home/jovyan/work` inside the container (`jovyan` is the default user for the Juypter Notebook containers


Once running, you'll see output from the Jupyter server:

```
Container must be run with group "root" to update passwd file
Executing the command: jupyter notebook
[I 23:13:09.150 NotebookApp] Writing notebook server cookie secret to /home/jovyan/.local/share/jupyter/runtime/notebook_cookie_secret
[I 23:13:11.074 NotebookApp] jupyter_tensorboard extension loaded.
[I 23:13:11.125 NotebookApp] JupyterLab extension loaded from /opt/conda/lib/python3.6/site-packages/jupyterlab
[I 23:13:11.125 NotebookApp] JupyterLab application directory is /opt/conda/share/jupyter/lab
[I 23:13:11.128 NotebookApp] Serving notebooks from local directory: /home/jovyan
[I 23:13:11.128 NotebookApp] The Jupyter Notebook is running at:
[I 23:13:11.128 NotebookApp] http://(16aed84461a6 or 127.0.0.1):8888/?token=2234ed6d0818641b2bcb4ceba6496f1abcfd5b363636ed5c
[I 23:13:11.128 NotebookApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 23:13:11.129 NotebookApp]

    Copy/paste this URL into your browser when you connect for the first time,
    to login with a token:
        http://(16aed84461a6 or 127.0.0.1):8888/?token=2234ed6d0818641b2bcb4ceba6496f1abcfd5b363636ed5c
```

The important piece is that last line:

```
Copy/paste this URL into your browser when you connect for the first time,
    to login with a token:
        http://(16aed84461a6 or 127.0.0.1):8888/?token=2234ed6d0818641b2bcb4ceba6496f1abcfd5b363636ed5c
```

The Notebook server is printing the token we need to use to login.  You can either point your browser to:

```
http://127.0.0.1:8888/?token=2234ed6d0818641b2bcb4ceba6496f1abcfd5b363636ed5c
```
and it will automatically enter the token for you, or you can open

```
http://127.0.0.1:8888
```
and copy and paste the token into the first box in the login screen.

**NOTE** Remember to update your hostname or host appropriately (I'm using a local server in this example) and also use the token generated by your server (the one is this example won't work for you).


### Running via `docker-compose`

There is another way we can start this container...use a tool called `docker-compose`.

`docker-compose` is tool that allows you to write simple config files to define how you want a a container to be created.  You can also use it to start multiple containers and define how they interact with each other (this is called orchestration).  Even though we're working with only a single container, `docker-compose` offers an easy way to start our Jupyter Hub container without having to keep track of lots of command line options.

All of the parameters we want to use to start our Jupyter container are contained in the file `docker-compose.yml`:

```
version: '3'

services:
  jupyter:
    container_name: jupyterhub
    image: bskjerven/jupyter-ml
    volumes:
      - /some/path:/home/jovyan/work
    ports:
      - 8888:8888
    #user: root
    #working_dir: /home/skj002/work
    #environment:
      #- JUPYTER_ENABLE_LAB=yes
      #- NB_USER=skj002
      #- NB_UID=1086611592
      #- NB_GID=515598196
      #- CHOWN_HOME=yes
      #- CHOWN_HOME_OPTS=-R
```

Each container we want to run is broken up into `services` (we've named it `jupyter` in this case).  From there, each line corresponds to a standard `docker run -<some flag>` option

* `container_name` is what we want to call the container (jupyterhub in this case).  This makes it easier to reference it, as opposed to using Docker's default naming conventions

* `image` is the Docker repo and image name that we'll start the container from (it will get pulled down from Dockerhub if it's not present on our system).

* `volumes` Each line starting with `-` defines a volume mount we want to present in the container

* `ports` Define what ports we're exposing

The last options are commented out (more on that later), but for the sake of completeness:

* `user` Define what user we want to run the containers (root in this case)
* `working_dir` When the container starts, we can define what directory we want to begin in with this option (remember...it's the directory relative to the container, not the host)
* `environment` Each line is an environment variable we can set in the container.  More on what those options are below.


To acutally start our container, all we need to do is run:

```
docker-compose up -d
```

If it's succesfull, should see

```
Creating jupyterhub ... done
```

and you can now point your browser to `http://<host>:8888`

The `-d` flag means to run this container in the background, so we can have our terminal back to use.  The one issue with this is that we can't see any of the log output, so we can't see our generated token.  Docker has an option for this:

```
docker exec jupyterhub jupyter notebook list
```


The `docker exec` command lets us run a command in an already container.  Here, we're going to run the command `jupyter notebook list` in the container created by our `docker-compose` command (named `jupyterhub`).

You should see a line similar to:

```
Currently running servers:
http://0.0.0.0:8888/?token=29931732c9e100bfe774b422e80e2a50cc83d2cc589152b9 :: /home/jovyan
```

We can copy the token value displayed into our login page.

Alternatively, we can run

```
docker logs jupyterhub
```
and all the log output from our running container will be displayed (helpful for debugging).



## Advanced options for Jupyter 

The Jupyter container we're runnning will run a startup script when the container is created.  There are a number of options avaiable for this script, all of which are documented on the [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html#notebook-options) site.  The main options I'll cover are the ones commented out in the `docker-compose.yml` file:

* `JUPYTER_ENABLE_LAB=yes`  This will start a Jupyter Lab server as opposed to the traditional Jupyter Notebook

* `NB_USER=<username>` By default the container runs with the default user `jovyan`.  You can specify a different user if you want with the `NB_USER` environment variable.  The will cause the container to rename the `jovyan` home folder.  You must run the container with root (`--user root` option) and you must change the working directory (`-w /home/$NB_USER`)

* `NB_UID` & `-NB_GID` Used to change the unique user ID and group ID of the username in the container

* `CHOWN_HOME=yes` Tells the startup script to change ownership of the home folder to `$NB_USER`

* `CHOWN_HOME_OPTS=-R`  When changing ownership of the home directory, do so recursively


Most of these options (and those on the Jupyter documentation) are aimed at allowing users to mount in specific directories and set specific permissions.  For the purposes of this tutorial, you shoulb be without any of them (although it's fun to try out Jupyter Lab if you want).


## Tensorboard

Tensorboard has been installed in this container, including plugins that allow us to run Tensorboard from a Jupyter Notebook or Jupyter Lab.

### Using Tensorboard with Jupyter Notebook

Refer to [jupyter-tensorboard](https://github.com/lspvic/jupyter_tensorboard) git page (Usage section).

### Using Tensorboard with Jupyter Lab

Refer to [jupyterlab-tensorboard](https://github.com/chaoleili/jupyterlab_tensorboard) git page.
