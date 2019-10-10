#!/usr/bin/env bashio
# Execute cli if requested
if bashio::var.equals $1 "snips"
then
    shift
    exec snips "$@"
fi


ASSISTANT_FILE=/usr/share/snips/assistant/assistant.json
if ! bashio::fs.file_exists $ASSISTANT_FILE
then
    bashio::exit.nok "Couldn't find any assistant"
fi

SUPERVISORD_CONF_FILE="/etc/supervisor/conf.d/supervisord.conf"
ASR_TYPE=bashio::jq $ASSISTANT_FILE '.asr.type'
ANALYTICS_ENABLED=bashio::jq $ASSISTANT_FILE '.analyticsEnabled'
SNIPS_MOSQUITTO_FLAG="-h localhost -p 1883"


if bashio::var.is_empty $SNIPS_AUDIO_SERVER_MQTT_ARGS
then
    SNIPS_AUDIO_SERVER_MQTT_ARGS="--frame=256"
fi

if bashio::fs.directory_exists "/opt/snips/asr"
then
    SNIPS_ASR_MODEL=""
else
    SNIPS_ASR_MODEL=""
fi
if bashio::var.is_empty $SNIPS_ASR_ARGS
then
    SNIPS_ASR_ARGS="$SNIPS_ASR_MODEL --beam_size=8"
fi

if bashio::var.is_empty $SNIPS_ASR_MQTT_ARGS 
then
    SNIPS_ASR_MQTT_ARGS=""
fi

if bashio::var.is_empty $SNIPS_DIALOGUE_MQTT_ARGS
then
    SNIPS_DIALOGUE_MQTT_ARGS=""
fi

if bashio::var.is_empty $SNIPS_ASR_GOOGLE_MQTT_ARGS
then
    SNIPS_ASR_GOOGLE_MQTT_ARGS=""
fi

if bashio::var.is_empty $SNIPS_HOTWORD_ARGS
then
    SNIPS_HOTWORD_ARGS=""
fi
if bashio::var.is_empty $SNIPS_HOTWORD_MQTT_ARGS
then
    SNIPS_HOTWORD_MQTT_ARGS=""
fi

if bashio::var.is_empty $SNIPS_ANALYTICS_MQTT_ARGS
then
    SNIPS_ANALYTICS_MQTT_ARGS=""
fi

if bashio::var.is_empty $SNIPS_QUERIES_MQTT_ARGS
then
    SNIPS_QUERIES_MQTT_ARGS=""
fi


# Read "global" arguments
USE_INTERNAL_MQTT=true
ALL_SNIPS_COMPONENTS=("snips-asr-google" "snips-asr" "snips-injection" "snips-audio-server" "snips-tts" "snips-hotword" "snips-nlu" "snips-dialogue" "snips-analytics" "snips-debug")
declare -A SNIPS_COMPONENTS
for c in "${ALL_SNIPS_COMPONENTS[@]}"
do
    SNIPS_COMPONENTS[$c]=true
done

if ! bashio::var.equals $ASR_TYPE "google"
then
    SNIPS_COMPONENTS["snips-asr-google"]=false
elif ! bashio::var.equals $ASR_TYPE "snips"
then
    SNIPS_COMPONENTS["snips-asr"]=false
fi

if ! bashio::var.true $ANALYTICS_ENABLED
then
    SNIPS_COMPONENTS["snips-analytics"]=false
fi


for i in $(seq 1 $#)
do
    j=$((i+1))
    TYPE_ARG="${!i}"
    VALUE_ARG="${!j}"
    if bashio::var.equals $TYPE_ARG "--verbose" || bashio::var.equals $TYPE_ARG "-v" 
    then
        SNIPS_DEBUG=true
    fi
done

if bashio::var.true $SNIPS_DEBUG
then
    bashio::log.info "Execution env:"
    env
    LOGLEVEL="-v"
    SNIPS_COMPONENTS["snips-debug"]=true
else
    LOGLEVEL=""
    SNIPS_COMPONENTS["snips-debug"]=false
fi

USE_INCLUDE=false
USE_EXCLUDE=false

for i in $(seq 1 $#)
do
    j=$((i+1))
    TYPE_ARG="${!i}"
    VALUE_ARG="${!j}"
    if bashio::var.equals $TYPE_ARG "--exclude-components"
    then
        USE_EXCLUDE=true
        if bashio::var.true $USE_INCLUDE
        then
            bashio::exit.nok "Cannot use --include-components and --exclude-components simultaneously"
        fi

        for j in $(echo $VALUE_ARG|tr ',' ' ')
        do
            if bashio::var.is_empty ${SNIPS_COMPONENTS[$i]}
            then
                bashio::exit.nok "Unknown snips component $j. Must be one of ${ALL_SNIPS_COMPONENTS[*]}."
            fi
            unset SNIPS_COMPONENTS["$i"]
        done
    elif bashio::var.equals $TYPE_ARG "--include-components"
    then
        USE_INCLUDE=true
        if bashio::var.true $USE_EXCLUDE
        then
            bashio::exit.nok "Cannot use --include-components and --exclude-components simultaneously"
        elif bashio::var.is_empty $VALUE_ARG
        then
            bashio::exit.nok "--include-components must be followed by a command-line list of components to include ${ALL_SNIPS_COMPONENTS[*]}"
        fi

        for c in "${ALL_SNIPS_COMPONENTS[@]}"
        do
            SNIPS_COMPONENTS[$c]=false
        done
        for j in $(echo $VALUE_ARG|tr ',' ' ')
        do
            if bashio::var.is_empty ${SNIPS_COMPONENTS[$i]} && ! bashio::var.equals $j "none" 
            then
                bashio::exit.nok "Unknown snips component $j. Must be one of ${ALL_SNIPS_COMPONENTS[*]}."
            fi
            SNIPS_COMPONENTS["$i"]=true
        done
    elif bashio::var.equals $TYPE_ARG "--mqtt"
    then
        if bashio::var.is_empty $VALUE_ARG
        then
            bashio::exit.nok "'<mqtt_server>:<mqtt_port>' must be specified when using --mqtt"
        elif [ "$(echo "$VALUE_ARG" | tr -cd ':' | wc -c)" != 1 ]
        then
            bashio::exit.nok "--mqtt value must follow the pattern '<mqtt_server>:<mqtt_port>' with server and port separated by a single ':'"
        elif [ "$(echo "$VALUE_ARG" | tr -cd '#' | wc -c)" != 0 ]
        then
            bashio::exit.nok "--mqtt value must follow the pattern '<mqtt_server>:<mqtt_port>'. '#' character is not allowed."
        fi

        SNIPS_MQTT_HOST=$(echo "$VALUE_ARG"| cut -d : -f 1)
        if bashio::var.is_empty "$SNIPS_MQTT_HOST"
        then
            bashio::exit.nok "Must specify a server when using --mqtt"
        fi

        SNIPS_MQTT_PORT=$(echo "$VALUE_ARG"| cut -d : -f 2)
        case "$SNIPS_MQTT_PORT" in
            ''|*[!0-9]*)
                bashio::exit.nok "Must specify a numeric value for port when using --mqtt";;
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
if bashio::var.true ${SNIPS_COMPONENTS['snips-asr-google']}
then
    bashio::log.info "Spawning /usr/bin/snips-asr-google $LOGLEVEL $SNIPS_ASR_GOOGLE_ARGS $SNIPS_MQTT_FLAG $SNIPS_ASR_GOOGLE_MQTT_ARGS"
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
    bashio::log.info "snips-asr-google is disabled"
fi


# Generate snips-asr
if bashio::var.true ${SNIPS_COMPONENTS['snips-asr']}
then
    bashio::log.info "Spawning /usr/bin/snips-asr $LOGLEVEL $SNIPS_ASR_ARGS $SNIPS_MQTT_FLAG $SNIPS_ASR_MQTT_ARGS"
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
    bashio::log.info "snips-asr is disabled"
fi


# Generate snips-audio-server
if bashio::var.true ${SNIPS_COMPONENTS['snips-audio-server']}
then
    bashio::log.info "Spawning /usr/bin/snips-audio-server $LOGLEVEL $SNIPS_AUDIO_SERVER_ARGS $SNIPS_MQTT_FLAG $SNIPS_AUDIO_SERVER_MQTT_ARGS"
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
    bashio::log.info "snips-audio-server is disabled"
fi


# Generate snips-tts
if bashio::var.true ${SNIPS_COMPONENTS['snips-tts']}
then
    bashio::log.info "Spawning /usr/bin/snips-tts $LOGLEVEL $SNIPS_TTS_ARGS $SNIPS_MQTT_FLAG $SNIPS_TTS_MQTT_FLAG"
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
    bashio::log.info "snips-tts is disabled"
fi


# Generate snips-hotword
if bashio::var.true ${SNIPS_COMPONENTS['snips-hotword']}
then
    bashio::log.info "Spawning /usr/bin/snips-hotword $SNIPS_HOTWORD_ARGS $LOGLEVEL $SNIPS_MQTT_FLAG $SNIPS_HOTWORD_MQTT_ARGS"
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
    bashio::log.info "snips-hotword is disabled"
fi


# Generate snips-nlu
if bashio::var.true ${SNIPS_COMPONENTS['snips-nlu']}
then
    bashio::log.info "Spawning /usr/bin/snips-nlu $LOGLEVEL $SNIPS_MQTT_FLAG $SNIPS_QUERIES_MQTT_ARGS"
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
    bashio::log.info "snips-nlu is disabled"
fi


# Generate snips-dialogue
if bashio::var.true ${SNIPS_COMPONENTS['snips-dialogue']}
then
    bashio::log.info "Spawning /usr/bin/snips-dialogue $LOGLEVEL $SNIPS_DIALOGUE_ARGS $SNIPS_MQTT_FLAG $SNIPS_DIALOGUE_MQTT_ARGS"
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
    bashio::log.info "snips-dialogue is disabled"
fi


# Generate snips-analytics
if bashio::var.true ${SNIPS_COMPONENTS['snips-analytics']}
then
    bashio::log.info "Spawning /usr/bin/snips-analytics $LOGLEVEL $SNIPS_MQTT_FLAG $SNIPS_ANALYTICS_MQTT_ARGS"
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
    bashio::log.info "snips-analytics is disabled"
fi


# Generate snips-debug
if bashio::var.true ${SNIPS_COMPONENTS['snips-debug']}
then
    bashio::log.info Spawning snips-debug
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
    bashio::log.info "snips-debug is disabled"
fi


if bashio::var.true ${USE_INTERNAL_MQTT}
then
    service mosquitto start
    sleep 2
fi

export RUMQTT_READ_TIMEOUT_MS=50
/usr/bin/supervisord -c $SUPERVISORD_CONF_FILE
