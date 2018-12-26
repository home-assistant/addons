#!/bin/bash
# Execute cli if requested
if [ "$1" = "snips" ]
then
    shift
    exec snips "$@"
fi


ASSISTANT_FILE=/usr/share/snips/assistant/assistant.json
if [ ! -f "$ASSISTANT_FILE" ]
then
    echo "Couldn't find any assistant"
    exit 1
fi

SUPERVISORD_CONF_FILE="/etc/supervisor/conf.d/supervisord.conf"
ASR_TYPE=`cat $ASSISTANT_FILE|jq --raw-output '.asr.type'`
ANALYTICS_ENABLED=`cat $ASSISTANT_FILE|jq --raw-output '.analyticsEnabled'`
SNIPS_MOSQUITTO_FLAG="-h localhost -p 1883"


if [ -z "$SNIPS_AUDIO_SERVER_MQTT_ARGS" ]
then
    SNIPS_AUDIO_SERVER_MQTT_ARGS="--frame=256"
fi

if [ -d "/opt/snips/asr" ]
then
    SNIPS_ASR_MODEL=""
else
    SNIPS_ASR_MODEL=""
fi
if [ -z "$SNIPS_ASR_ARGS" ]
then
    SNIPS_ASR_ARGS="$SNIPS_ASR_MODEL --beam_size=8"
fi

if [ -z "$SNIPS_ASR_MQTT_ARGS" ]
then
    SNIPS_ASR_MQTT_ARGS=""
fi

if [ -z "$SNIPS_DIALOGUE_MQTT_ARGS" ]
then
    SNIPS_DIALOGUE_MQTT_ARGS=""
fi

if [ -z "$SNIPS_ASR_GOOGLE_MQTT_ARGS" ]
then
    SNIPS_ASR_GOOGLE_MQTT_ARGS=""
fi

if [ -z "$SNIPS_HOTWORD_ARGS" ]
then
    SNIPS_HOTWORD_ARGS=""
fi
if [ -z "$SNIPS_HOTWORD_MQTT_ARGS" ]
then
    SNIPS_HOTWORD_MQTT_ARGS=""
fi

if [ -z "$SNIPS_ANALYTICS_MQTT_ARGS" ]
then
    SNIPS_ANALYTICS_MQTT_ARGS=""
fi

if [ -z "$SNIPS_QUERIES_MQTT_ARGS" ]
then
    SNIPS_QUERIES_MQTT_ARGS=""
fi


# Read "global" arguments
USE_INTERNAL_MQTT=true
ALL_SNIPS_COMPONENTS=("snips-asr-google" "snips-asr" "snips-audio-server" "snips-tts" "snips-hotword" "snips-nlu" "snips-dialogue" "snips-analytics" "snips-debug")
declare -A SNIPS_COMPONENTS
for c in ${ALL_SNIPS_COMPONENTS[@]}
do
    SNIPS_COMPONENTS[$c]=true
done

if [ "$ASR_TYPE" != "google" ]
then
    SNIPS_COMPONENTS["snips-asr-google"]=false
elif [ "$ASR_TYPE" != "snips" ]
then
    SNIPS_COMPONENTS["snips-asr"]=false
fi

if [ "$ANALYTICS_ENABLED" != "true" ]
then
    SNIPS_COMPONENTS["snips-analytics"]=false
fi


for i in `seq 1 $#`
do
    j=$((i+1))
    TYPE_ARG="${!i}"
    VALUE_ARG="${!j}"
    if [[ "$TYPE_ARG" = "--verbose" || "$TYPE_ARG" = "-v" ]]
    then
        SNIPS_DEBUG=true
    fi
done

if [ "${SNIPS_DEBUG}" == true ]
then
    echo "Execution env:"
    env
    LOGLEVEL="-v"
    SNIPS_COMPONENTS["snips-debug"]=true
else
    LOGLEVEL=""
    SNIPS_COMPONENTS["snips-debug"]=false
fi


for i in `seq 1 $#`
do
    j=$((i+1))
    TYPE_ARG="${!i}"
    VALUE_ARG="${!j}"
    if [ "$TYPE_ARG" = "--exclude-components" ]
    then
        USE_EXCLUDE=true
        if [ "USE_INCLUDE" = true ]
        then
            echo "Cannot use --include-components and --exclude-components simultaneously"
            exit 1
        fi

        for i in `echo $VALUE_ARG|tr ',' ' '`
        do
            if [ -z ${SNIPS_COMPONENTS[$i]} ]
            then
                echo "Unknown snips component $i. Must be one of [${ALL_SNIPS_COMPONENTS[@]}]."
                exit 1
            fi
            unset SNIPS_COMPONENTS["$i"]
        done
    elif [ "$TYPE_ARG" = "--include-components" ]
    then
        USE_INCLUDE=true
        if [ "USE_EXCLUDE" = true ]
        then
            echo "Cannot use --include-components and --exclude-components simultaneously"
            exit 1
        elif [ -z "$VALUE_ARG" ]
        then
            echo "--include-components must be followed by a command-line list of components to include (${ALL_SNIPS_COMPONENTS[@]})"
            exit 1
        fi

        for c in ${ALL_SNIPS_COMPONENTS[@]}
        do
            SNIPS_COMPONENTS[$c]=false
        done
        for i in `echo $VALUE_ARG|tr ',' ' '`
        do
            if [[ -z "${SNIPS_COMPONENTS[$i]}" && $i != "none" ]]
            then
                echo "Unknown snips component $i. Must be one of [${ALL_SNIPS_COMPONENTS[@]} none]."
                exit 1
            fi
            SNIPS_COMPONENTS["$i"]=true
        done
    elif [ "$TYPE_ARG" = "--mqtt" ]
    then
        if [ -z "$VALUE_ARG" ]
        then
            echo "'<mqtt_server>:<mqtt_port>' must be specified when using --mqtt"
            exit 1
        elif [ `echo "$VALUE_ARG" | tr -cd ':' | wc -c` != 1 ]
        then
            echo "--mqtt value must follow the pattern '<mqtt_server>:<mqtt_port>' with server and port separated by a single ':'"
            exit 1
        elif [ `echo "$VALUE_ARG" | tr -cd '#' | wc -c` != 0 ]
        then
            echo "--mqtt value must follow the pattern '<mqtt_server>:<mqtt_port>'. '#' character is not allowed."
            exit 1
        fi

        SNIPS_MQTT_HOST=`echo "$VALUE_ARG"| cut -d : -f 1`
        if [ -z "$SNIPS_MQTT_HOST" ]
        then
            echo "Must specify a server when using --mqtt"
            exit 1
        fi

        SNIPS_MQTT_PORT=`echo "$VALUE_ARG"| cut -d : -f 2`
        case "$SNIPS_MQTT_PORT" in
            ''|*[!0-9]*)
                echo "Must specify a numeric value for port when using --mqtt"
                exit 1 ;;
            *) ;;
        esac

        USE_INTERNAL_MQTT=false
        SNIPS_MQTT_FLAG="--mqtt '$SNIPS_MQTT_HOST:$SNIPS_MQTT_PORT'"
        SNIPS_MOSQUITTO_FLAG="-h $SNIPS_MQTT_HOST -p $SNIPS_MQTT_PORT"
    fi
done

# Generate global configuration
cat <<EOT > $SUPERVISORD_CONF_FILE
[supervisord]
nodaemon=true

EOT


# Generate snips-asr-google
if [ "${SNIPS_COMPONENTS['snips-asr-google']}" = true ]
then
    echo Spawning /usr/bin/snips-asr-google $LOGLEVEL $SNIPS_ASR_GOOGLE_ARGS $SNIPS_MQTT_FLAG $SNIPS_ASR_GOOGLE_MQTT_ARGS
    cat <<EOT >> $SUPERVISORD_CONF_FILE

[program:snips-asr-google]
command=/usr/bin/snips-asr-google $LOGLEVEL $SNIPS_ASR_GOOGLE_ARGS $SNIPS_MQTT_FLAG $SNIPS_ASR_GOOGLE_MQTT_ARGS
autorestart=true
directory=/root
environment=RUMQTT_READ_TIMEOUT_MS="50"
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
EOT
else
    echo "snips-asr-google is disabled"
fi


# Generate snips-asr
if [ "${SNIPS_COMPONENTS['snips-asr']}" = true ]
then
    echo Spawning /usr/bin/snips-asr $LOGLEVEL $SNIPS_ASR_ARGS $SNIPS_MQTT_FLAG $SNIPS_ASR_MQTT_ARGS
    cat <<EOT >> $SUPERVISORD_CONF_FILE

[program:snips-asr]
command=/usr/bin/snips-asr $LOGLEVEL $SNIPS_ASR_ARGS $SNIPS_MQTT_FLAG $SNIPS_ASR_MQTT_ARGS
autorestart=true
directory=/root
environment=RUMQTT_READ_TIMEOUT_MS="50"
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
EOT
else
    echo "snips-asr is disabled"
fi


# Generate snips-audio-server
if [ "${SNIPS_COMPONENTS['snips-audio-server']}" = true ]
then
    echo Spawning /usr/bin/snips-audio-server $LOGLEVEL $SNIPS_AUDIO_SERVER_ARGS $SNIPS_MQTT_FLAG $SNIPS_AUDIO_SERVER_MQTT_ARGS
    cat <<EOT >> $SUPERVISORD_CONF_FILE

[program:snips-audio-server]
command=/usr/bin/snips-audio-server $LOGLEVEL $SNIPS_AUDIO_SERVER_ARGS $SNIPS_MQTT_FLAG $SNIPS_AUDIO_SERVER_MQTT_ARGS
autorestart=true
directory=/root
environment=RUMQTT_READ_TIMEOUT_MS="50"
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
EOT
else
    echo "snips-audio-server is disabled"
fi


# Generate snips-tts
if [ "${SNIPS_COMPONENTS['snips-tts']}" = true ]
then
    echo Spawning /usr/bin/snips-tts $LOGLEVEL $SNIPS_TTS_ARGS $SNIPS_MQTT_FLAG $SNIPS_TTS_MQTT_FLAG
    cat <<EOT >> $SUPERVISORD_CONF_FILE
[program:snips-tts]
command=/usr/bin/snips-tts $LOGLEVEL $SNIPS_TTS_ARGS $SNIPS_MQTT_FLAG $SNIPS_TTS_MQTT_FLAG
autorestart=true
directory=/root
environment=RUMQTT_READ_TIMEOUT_MS="50"
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
EOT
else
    echo "snips-tts is disabled"
fi


# Generate snips-hotword
if [ "${SNIPS_COMPONENTS['snips-hotword']}" = true ]
then
    echo Spawning /usr/bin/snips-hotword $SNIPS_HOTWORD_ARGS $LOGLEVEL $SNIPS_MQTT_FLAG $SNIPS_HOTWORD_MQTT_ARGS
    cat <<EOT >> $SUPERVISORD_CONF_FILE
[program:snips-hotword]
command=/usr/bin/snips-hotword $SNIPS_HOTWORD_ARGS $LOGLEVEL $SNIPS_MQTT_FLAG $SNIPS_HOTWORD_MQTT_ARGS
autorestart=true
directory=/root
environment=RUMQTT_READ_TIMEOUT_MS="50"
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
EOT
else
    echo "snips-hotword is disabled"
fi


# Generate snips-nlu
if [ "${SNIPS_COMPONENTS['snips-nlu']}" = true ]
then
    echo Spawning /usr/bin/snips-nlu $LOGLEVEL $SNIPS_MQTT_FLAG $SNIPS_QUERIES_MQTT_ARGS
    cat <<EOT >> $SUPERVISORD_CONF_FILE
[program:snips-nlu]
command=/usr/bin/snips-nlu $LOGLEVEL $SNIPS_MQTT_FLAG $SNIPS_QUERIES_MQTT_ARGS
autorestart=true
directory=/root
environment=RUMQTT_READ_TIMEOUT_MS="50"
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
EOT
else
    echo "snips-nlu is disabled"
fi


# Generate snips-dialogue
if [ "${SNIPS_COMPONENTS['snips-dialogue']}" = true ]
then
    echo Spawning /usr/bin/snips-dialogue $LOGLEVEL $SNIPS_DIALOGUE_ARGS $SNIPS_MQTT_FLAG $SNIPS_DIALOGUE_MQTT_ARGS
    cat <<EOT >> $SUPERVISORD_CONF_FILE
[program:snips-dialogue]
command=/usr/bin/snips-dialogue $LOGLEVEL $SNIPS_DIALOGUE_ARGS $SNIPS_MQTT_FLAG $SNIPS_DIALOGUE_MQTT_ARGS
autorestart=true
directory=/root
environment=RUMQTT_READ_TIMEOUT_MS="50"
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
EOT
else
    echo "snips-dialogue is disabled"
fi


# Generate snips-analytics
if [ "${SNIPS_COMPONENTS['snips-analytics']}" = true ]
then
    echo Spawning /usr/bin/snips-analytics $LOGLEVEL $SNIPS_MQTT_FLAG $SNIPS_ANALYTICS_MQTT_ARGS 
    cat <<EOT >> $SUPERVISORD_CONF_FILE
[program:snips-analytics]
command=/usr/bin/snips-analytics $LOGLEVEL $SNIPS_MQTT_FLAG $SNIPS_ANALYTICS_MQTT_ARGS
autorestart=unexpected
directory=/root
environment=RUMQTT_READ_TIMEOUT_MS="50"
exitcodes=0
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
EOT
else
    echo "snips-analytics is disabled"
fi


# Generate snips-debug
if [ "${SNIPS_COMPONENTS['snips-debug']}" = true ]
then
    echo Spawning snips-debug
    cat <<EOT >> $SUPERVISORD_CONF_FILE
[program:snips-debug]
command=mosquitto_sub -v $SNIPS_MOSQUITTO_FLAG -t "hermes/#" -T "hermes/audioServer/+/audioFrame"
autorestart=true
directory=/root
stderr_logfile=/dev/fd/1
stderr_logfile_maxbytes=0
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
EOT
else
    echo "snips-debug is disabled"
fi


if [ "${USE_INTERNAL_MQTT}" = true ]
then
    service mosquitto start
    sleep 2
fi

export RUMQTT_READ_TIMEOUT_MS=50
/usr/bin/supervisord -c $SUPERVISORD_CONF_FILE

