#!/bin/sh
# start with clean slate
[ -f "$MSCS_DEFAULTS" ] && rm "$MSCS_DEFAULTS"

want="\$JVM_ARGS"
# verify DEFAULT_SERVER_COMMAND contains $JVM_ARGS string literal before -jar flag
if ! printf "%s" "$DEFAULT_SERVER_COMMAND" | grep -qs -- ".*$want.*-jar"; then
    terr "wrong DEFAULT_SERVER_COMMAND"
    terr "got '$DEFAULT_SERVER_COMMAND'"
    terr "want '$want' before '-jar'"
fi

want="-Dtesting-the-jvmargs"
propfile=""

# write the config under test
cat > "$propfile" <<EOF
mscs-jvm-args=$want
EOF

testworld=""
# verify getMSCSValue returns configured value
got=$(getMSCSValue "$testworld" "mscs-jvm-args" "")
if [ "$got" != "$want" ]; then
    terr "wrong value from getMSCSValue"
    terr "got '$got'"
    terr "want '$want'"
fi

(
# replace funcs in subshell to ease testing & restore orig afterward
getCurrentMinecraftVersion () {
    printf "fakedVersion"
}
getServerVersion () {
    printf "fakedVersion"
}

# verify getServerCommand returns correct jvm args
got=$(getServerCommand "$testworld")
if ! printf "%s" "$got" | grep -qs -- "$want"; then
    terr "wrong getServerCommand did not return the expected command"
    terr "got '$got'"
    terr "want substring $want"
fi
)

want=""
# verify DEFAULT_JVM_ARGS is empty string
if [ "$DEFAULT_JVM_ARGS" != "$want" ]; then
    terr "wrong DEFAULT_JVM_ARGS"
    terr "got '$DEFAULT_JVM_ARGS'"
    terr "want '$want'"
fi

# verify getDefaultsValue returns correct default value for mscs-default-jvm-args
got=$(getDefaultsValue "mscs-default-jvm-args" "")
if [ "$got" != "$want" ]; then
    terr "wrong value from getMSCSValue"
    terr "got '$got'"
    terr "want '$want'"
fi

want="-Dlog4j.configurationFile=/opt/mscs/log4j2.xml"
# write the config under test
cat > "$MSCS_DEFAULTS" <<EOF
mscs-default-jvm-args=$want
EOF
got=$(getDefaultsValue "mscs-default-jvm-args" "")
# verify getDefaultsValue returns correct value for mscs-default-jvm-args when set
if [ "$got" != "$want" ]; then
    terr "wrong value from getDefaultsValue for mscs-default-jvm-args"
    terr "got '$got'"
    terr "want '$want'"
fi

want="-Dlog4j.configurationFile=/opt/mscs/log4j2.xml"
cat > "$MSCS_DEFAULTS" <<EOF
mscs-default-jvm-args=
EOF
# when getValue returns a default value with a hyphen (like a flag)
got=$(getValue "$MSCS_DEFAULTS" "mscs-default-jvm-args" "$want")
if [ "$got" != "$want" ]; then
    terr "wrong value from getValue for mscs-default-jvm-args"
    terr "got '$got'"
    terr "want '$want'"
fi

# verify mscs_defaults output contains correct value for mscs-default-jvm-args
want="# mscs-default-jvm-args="
got=$(mscs_defaults | grep '^\# mscs-default-jvm-args=$')
if [ "$got" != "$want" ]; then
    terr "wrong mscs_defaults output value for mscs-default-jvm-args"
    terr "got '$got'"
    terr "want '$want'"
fi
