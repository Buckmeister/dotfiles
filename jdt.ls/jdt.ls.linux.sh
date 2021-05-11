#!/usr/bin/env bash

JAR=/usr/local/share/jdt.ls/plugins/org.eclipse.equinox.launcher_1.6.100.v20201223-0822.jar
JDTLS_CONFIG=/usr/local/share/jdt.ls/config_linux

"$JAVA_HOME/bin/java" \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dlog.protocol=true \
  -Dlog.level=ALL \
  -Xms1g \
  -Xmx2G \
  -jar "$JAR" \
  -configuration "$JDTLS_CONFIG" \
  -data "${1:-$HOME/.tmp}" \
  --add-modules=ALL-SYSTEM \
  --add-opens java.base/java.util=ALL-UNNAMED \
  --add-opens java.base/java.lang=ALL-UNNAMED
