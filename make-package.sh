#!/bin/bash -x

dirname=$1

if [[ -z "$dirname" ]]; then
	echo "No directory name provided."
	exit
fi

if [[ ! -d "${dirname}" ]]; then
	echo "Folder '${dirname}' doesn't exist."
	exit
fi

dirname=${dirname%/*}

pushd ${dirname}

zip -r "../${dirname}.zip" *

popd

