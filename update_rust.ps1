pushd

try {

    cd "_update"

    if (!(Test-Path "env")) {
        virtualenv env
        .\env\Scripts\pip install -r requirements.txt
    }

    if (!(Test-Path "tmp")) {
        mkdir tmp
    }

    .\env\Scripts\python update.py

} finally {
    popd
}
