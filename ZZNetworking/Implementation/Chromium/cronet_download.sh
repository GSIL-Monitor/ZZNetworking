#!/bin/bash

# Program:
#	Chromium-net网络栈编译出来的静态库其中有些.a大小超过了100M, 无法上传到git仓库上, 故将其托管到maven(可使用其他平台)上.
#   然后在podspec中通过'prepare_command'选项来执行该脚本文件, 就可以下载相应的.a库libs和头文件includes.
# History:
#   2017/11/13   zhangrenfeng	0.1.0
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

CURRENT_VERSION=1.0.1										# 用来保存当前chromium-net库的编译版本, 用以更新
VERSION_FILE=chromium_version								# 用来保存上一次的版本号, 第一次调用时该文件不存在
DOWNLOAD_FILE=cronet-$CURRENT_VERSION.jar					# 下载的文件名称

CURRENT_DIR=$PWD											# 当前目录
echo -e "The current version is: $CURRENT_VERSION"

STATUS_CODE=0												# 执行状态码

cd ZZNetworking/Implementation/Chromium 					# 进入存储文件的目录, 该下载目录和podspec文件中的设置相关
if [ -e "$VERSION_FILE" ]; then								# 存在版本文件
	previous_version=$((cat $VERSION_FILE))					# 上个版本号
	echo -e "The previous version is: $previous_version"

	if [ "$CURRENT_VERSION" != "$previous_version" ]; then	# 当前版本不是上一版本, 则需要更新
		# 下载文件
		echo "Downloading libs and includes......"
		curl -o $DOWNLOAD_FILE "https://maven.byted.org/repository/ss_app_ios/com/bytedance/ss_app_ios/cronet/$CURRENT_VERSION/$DOWNLOAD_FILE"

		STATUS_CODE=$?										# 执行结果
		if [ "$STATUS_CODE" -ne 0 ]; then					# 执行失败
			echo "Downloading libs and includes failed, exit."
			cd $CURRENT_DIR
			exit $STATUS_CODE
		fi

		unzip -o $DOWNLOAD_FILE								# 解压文件
		STATUS_CODE=$?
		if [ "$STATUS_CODE" -ne 0 ]; then					# 解压失败
			echo "unzip download file:$DOWNLOAD_FILE failed. exit"
			cd $CURRENT_DIR
			exit $STATUS_CODE
		fi

		echo "unzip download file:$DOWNLOAD_FILE success."
		rm -rf $DOWNLOAD_FILE							   # 删除下载文件
		STATUS_CODE=$?
		if [ "$STATUS_CODE" -ne 0 ]; then				   # 删除失败
			echo "remove download file:$DOWNLOAD_FILE failed. exit"
			cd $CURRENT_DIR
			exit $STATUS_CODE
		fi
		echo "remove download file:$DOWNLOAD_FILE success"

		echo "$CURRENT_VERSION" > "$VERSION_FILE"			# 保存当前版本号

		cd $CURRENT_DIR
		exit $STATUS_CODE
	else													# 版本号相同, 则不需要进行更新
		echo "The current version is existed. no need to update."
	fi
else														# 版本文件不存在, 则创建
	# 下载文件
	curl -o $DOWNLOAD_FILE "https://maven.byted.org/repository/ss_app_ios/com/bytedance/ss_app_ios/cronet/$CURRENT_VERSION/$DOWNLOAD_FILE"

	STATUS_CODE=$?										# 执行结果
	if [ "$STATUS_CODE" -ne 0 ]; then					# 执行失败
		echo "Downloading libs and includes failed, exit."
		cd $CURRENT_DIR
		exit $STATUS_CODE
	fi

	unzip -o $DOWNLOAD_FILE								# 解压文件
	STATUS_CODE=$?
	if [ "$STATUS_CODE" -ne 0 ]; then					# 解压失败
		echo "unzip download file:$DOWNLOAD_FILE failed. exit"
		cd $CURRENT_DIR
		exit $STATUS_CODE
	fi

	echo "unzip download file:$DOWNLOAD_FILE success."
	rm -rf $DOWNLOAD_FILE							   # 删除下载文件
	STATUS_CODE=$?
	if [ "$STATUS_CODE" -ne 0 ]; then				   # 删除失败
		echo "remove download file:$DOWNLOAD_FILE failed. exit"
		cd $CURRENT_DIR
		exit $STATUS_CODE
	fi
	echo "remove download file:$DOWNLOAD_FILE success"

	echo -e "First Run: Create version file"
	echo "$CURRENT_VERSION" > "$VERSION_FILE"			# 保存当前版本号

	cd $CURRENT_DIR
	exit $STATUS_CODE

fi
