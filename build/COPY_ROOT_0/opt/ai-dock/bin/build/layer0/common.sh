#!/bin/false

source /opt/ai-dock/etc/environment.sh

build_common_main() {
    apt-get update
    # Add the deadsnakes PPA to get access to older python versions
    add-apt-repository ppa:deadsnakes/ppa -y
    apt-get update
    
    build_common_install_jupyter
    build_common_install_python_kernels # Renamed for clarity

}

build_common_do_install_python_venv() {
    $APT_INSTALL \
        "python${2}-full" \
        "python${2}-dev" \
        "python${2}-venv"
        
    venv="${VENV_DIR}/${1}"
    "python${2}" -m venv "$venv"
    
    "$venv/bin/pip" install --no-cache-dir --upgrade\
        pip \
        ipykernel \
        ipywidgets
        
    "$venv/bin/python" -m ipykernel install \
        --name="$1" \
        --display-name="Python ${2} (${1})"
}

build_common_install_python_kernels() {
    if [[ $PYTHON_VERSION != "all" ]]; then
        build_common_do_install_python_venv "${PYTHON_VENV_NAME}" "${PYTHON_VERSION}"
    else
        # Install multiple Python versions as selectable Jupyter kernels
        echo "Installing additional Python kernels..."
        build_common_do_install_python_venv "python_310" "3.10"
        build_common_do_install_python_venv "python_311" "3.11"
        #build_common_do_install_python_venv "python_312" "3.12"
    fi
}

build_common_install_jupyter() {
    $APT_INSTALL \
        python3.12-full \
        python3.12-dev \
        python3.12-venv
    python3.12 -m venv "$JUPYTER_VENV"
    source /opt/nvm/nvm.sh
    nvm use default
    "$JUPYTER_VENV_PIP" install --no-cache-dir --upgrade \
        pip \
        jupyterlab \
        notebook \
        ipykernel \
        ipywidgets
    
    "$JUPYTER_VENV_PYTHON" -m ipykernel install \
        --name="pytorch_312" \
        --display-name="PyTorch (Python 3.12)"
    printf "Removing default ipython kernel from Jupyter venv...\n"
    rm -rf "$JUPYTER_VENV/share/jupyter/kernels/python3"
}

build_common_main "$@"