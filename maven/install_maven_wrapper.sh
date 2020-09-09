#!/bin/sh

SOURCEDIR=/tmp/maven-wrapper-src
TARGETDIR=$PWD

echo "About to install maven wrapper to ${TARGETDIR}"
echo "proceed? [y/N]"

read -r answer
if [ "$answer" != "${answer#[Yy]}" ]; then

  command -v git >/dev/null 2>&1 || {
    echo >&2 "Error: No 'git' command in PATH!"
    exit
  }
  echo

  echo "Retrieving maven wrapper repository"
  git clone https://github.com/takari/maven-wrapper.git "${SOURCEDIR}"
  echo

  echo "Copying maven wrapper to ${TARGETDIR}"
  cp -r "${SOURCEDIR}/.mvn" "${TARGETDIR}"
  cp "${SOURCEDIR}/mvnw.cmd" "${TARGETDIR}"
  cp "${SOURCEDIR}/mvnw" "${TARGETDIR}"
  echo

  echo "Cleaning up ${SOURCEDIR}"
  rm -rf "${SOURCEDIR}"
  echo
fi
