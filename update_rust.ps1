pushd

try {

    cd "_update"

    if (!(Test-Path "env")) {
        python -m venv env
        .\env\Scripts\pip install -r requirements.txt
    }

    if (!(Test-Path "tmp")) {
        mkdir tmp
    }

    .\env\Scripts\python update.py

} finally {
    popd
}
