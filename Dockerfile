FROM jupyter/tensorflow-notebook

# Install conda packages (this is as done as the container user)
USER $NB_UID
RUN conda install --quiet --yes \
      bokeh \
      tensorboard && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Add Tensorboard to Jupyterlab console
RUN pip install --pre jupyter-tensorboard
RUN jupyter tensorboard enable --user && \
    jupyter labextension install jupyterlab_tensorboard
