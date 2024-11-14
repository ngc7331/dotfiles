dotvenv() {
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
    else
        echo ".venv/bin/activate not found"
        echo "maybe you need to run 'python3 -m venv .venv' to create it?"
    fi
}

dotconda() {
    # NOTE: the official default is $HOME/anaconda3 or $HOME/miniconda, but I prefer $HOME/.conda
    CONDA_DIR=${CONDA_DIR:-$HOME/.conda}
    if [ -f "${CONDA_DIR}/bin/activate" ]; then
        source "${CONDA_DIR}/bin/activate"
    else
        echo "${CONDA_DIR}/bin/activate not found"
        echo "maybe you need to install anaconda3 or miniconda?"
        echo "or set CONDA_DIR in your .profile?"
    fi
}

dotesp() {
    # NOTE: the official default is $HOME/esp, but I prefer $HOME/.espressif
    ESP_IDF_VERSION=${ESP_IDF_VERSION:-v5.3.1}
    ESP_DIR=${ESP_DIR:-$HOME/.espressif/$ESP_IDF_VERSION}
    if [ -f "${ESP_DIR}/esp-idf/export.sh" ]; then
        source "${ESP_DIR}/esp-idf/export.sh"
    else
        echo "${ESP_DIR}/esp-idf/export.sh not found"
        echo "maybe you need to install esp-idf?"
        echo "or set ESP_DIR / ESP_IDF_VERSION in your .profile?"
    fi
}
