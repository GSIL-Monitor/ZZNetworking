#!/bin/bash
VERSION=1.0.1
DOWNLOAD_FILE=cronet-$VERSION.jar
CURRENT_DIR=$PWD
cd ZZNetworking/Implementation/Chromium
if [ -e /tmp/$DOWNLOAD_FILE ]; then
    echo "Lib has been downloaded, use local cache."
    cp /tmp/$DOWNLOAD_FILE $DOWNLOAD_FILE
else
    echo "Downloading assets..."
    curl -o $DOWNLOAD_FILE "https://maven.byted.org/repository/ss_app_ios/com/bytedance/ss_app_ios/cronet/$VERSION/$DOWNLOAD_FILE"
    EXITCODE=$?
    if [ $EXITCODE -ne 0 ]; then
        echo "Download lib failed, exit."
        cd $CURRENT_DIR
    exit $EXITCODE
    fi
    cp $DOWNLOAD_FILE /tmp/$DOWNLOAD_FILE
fi

unzip -o $DOWNLOAD_FILE
EXITCODE=$?

cd $CURRENT_DIR

exit $EXITCODE



















