#!/bin/bash

# tested with a clean 64 bit installation of Raspbian-Lite

function install_core (){
    echo "Installing OVOS core"
    echo

    # set up the Raspberry Pi
    sudo apt install -y build-essential python3-dev python3-pip swig libssl-dev libfann-dev portaudio19-dev libpulse-dev cmake libncurses-dev pulseaudio-utils pulseaudio
    pulseaudio -D

    # install ovos-core
    pip3 install git+https://github.com/OpenVoiceOS/ovos-backend-client
    pip3 install git+https://github.com/OpenVoiceOS/ovos-core
    pip3 install git+https://github.com/OpenVoiceOS/ovos-audio
    pip3 install git+https://github.com/OpenVoiceOS/ovos-ocp-audio-plugin
    pip3 install git+https://github.com/OpenVoiceOS/ovos-messagebus
    # pip3 install padatious

    # dinkum listener
    pip3 install git+https://github.com/OpenVoiceOS/ovos-dinkum-listener
    pip3 install git+https://github.com/OpenVoiceOS/ovos-vad-plugin-silero

    #Precise-lite wake-word (ww) cluster
    pip3 install git+https://github.com/OpenVoiceOS/ovos-ww-plugin-precise
    pip3 install git+https://github.com/OpenVoiceOS/ovos-ww-plugin-precise-lite
    pip3 install --upgrade setuptools
    pip3 install tflite_runtime
    pip3 install PyYAML
    pip3 install git+https://github.com/OpenVoiceOS/ovos-workshop
    pip3 install git+https://github.com/OpenVoiceOS/ovos-lingua-franca
    pip3 install PyAudio

    # install speech to text (stt)
    pip3 install git+https://github.com/OpenVoiceOS/ovos-microphone-plugin-alsa
    pip3 install git+https://github.com/OpenVoiceOS/ovos-stt-plugin-server

    # install text to speech (tts)
    pip3 install git+https://github.com/OpenVoiceOS/ovos-tts-plugin-mimic3-server
    sudo apt install -y espeak-ng
    pip3 install git+https://github.com/OpenVoiceOS/ovos-tts-plugin-piper
    pip3 install git+https://github.com/OpenVoiceOS/ovos-tts-server-plugin

    pip3 install git+https://github.com/OpenVoiceOS/ovos-config
    pip3 install git+https://github.com/OpenVoiceOS/ovos-utils
    pip3 install git+https://github.com/OpenVoiceOS/ovos-bus-client
    pip3 install git+https://github.com/OpenVoiceOS/ovos-plugin-manager
    pip3 install git+https://github.com/OpenVoiceOS/ovos-workshop
    pip3 install git+https://github.com/OpenVoiceOS/ovos-lingua-franca
    pip3 install git+https://github.com/OpenVoiceOS/ovos-cli-client

    # install phal components
    pip3 install git+https://github.com/OpenVoiceOS/ovos-PHAL
    pip3 install git+https://github.com/OpenVoiceOS/ovos-phal-plugin-connectivity-events
    pip3 install git+https://github.com/OpenVoiceOS/ovos-phal-plugin-system
    pip3 install git+https://github.com/OpenVoiceOS/ovos-PHAL-plugin-ipgeo
    pip3 install git+https://github.com/OpenVoiceOS/ovos-PHAL-plugin-oauth
    pip3 install git+https://github.com/OpenVoiceOS/ovos-phal-plugin-dashboard
    pip3 install git+https://github.com/OpenVoiceOS/ovos-phal-plugin-alsa

    # install required skills
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-volume
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-fallback-unknown
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-stop
    pip3 install git+https://github.com/OpenVoiceOS/skill-alerts
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-personal
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-naptime
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-date-time

    # You can uncomment these lines if the deprecation notices are flooding your logs or slowing the system
    #sed -i '/\@deprecated/d' $HOME/.local/lib/python3.9/site-packages/ovos_utils/fingerprinting.py
    #sed -i '/\@deprecated/d' $HOME/.local/lib/python3.9/site-packages/ovos_utils/configuration.py
    #sed -i '/\@deprecated/d' $HOME/.local/lib/python3.9/site-packages/ovos_utils/ovos_service_api.py
    #sed -i '/\@deprecated/d' $HOME/.local/lib/python3.9/site-packages/ovos_utils/signal.py

    if [[ ! -d $HOME/.config/mycroft ]]; then
        mkdir -p $HOME/.config/mycroft
    fi
    cp $SCRIPT_DIR/stage-ovos/02-ovos/files/mycroft.conf $HOME/.config/mycroft/
    echo $SCRIPT_DIR
    echo
    echo "Done installing OVOS core"
    }

function install_systemd (){
    echo
    echo "Installing systemd files"
    echo

    cd $SCRIPT_DIR/stage-ovos/00-system/files
    sed -i s/multi-user/default/g ovos.service
    for f in *.service ; do
      sed -i s,/usr/libexec,/home/ovos/.local/bin,g $f
      # extend the timeouts
      # sed -i s/=1m/=2m/g $f
    done

    # install the hook files
    cp ovos-systemd*  $HOME/.local/bin/
    chmod +x $HOME/.local/bin/ovos-systemd*

    # sdnotify is required
    pip3 install sdnotify

    # install the service files
    if [[ ! -d $HOME/.config/systemd/user ]]; then
        mkdir -p $HOME/.config/systemd/user
    fi
    sed -i s/User=root/#User=root/g ovos-admin-phal.service
    cp *.service $HOME/.config/systemd/user/

    if [[ $enabled == "YES" ]]; then
        echo
        echo "Enabling service files"
        echo
        systemctl --user enable ovos
        systemctl --user enable ovos-messagebus
        systemctl --user enable ovos-dinkum-listener
        systemctl --user enable ovos-audio
        systemctl --user enable ovos-skills
        systemctl --user enable ovos-phal
        systemctl --user enable ovos-admin-phal
        systemctl --user daemon-reload
    fi

    cd $SCRIPT_DIR
    echo
    echo "Done installing systemd files"
    echo
    }

function install_extra_skills (){
    echo
    echo "Installing extra skills"
    echo
    # from NeonGeckoCom
    pip3 install git+https://github.com/NeonGeckoCom/skill-user_settings
    pip3 install git+https://github.com/NeonGeckoCom/skill-spelling
    pip3 install git+https://github.com/NeonGeckoCom/skill-local_music
    pip3 install git+https://github.com/NeonGeckoCom/skill-caffeinewiz

    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-weather
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-hello-world

    # common query
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-ddg
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-wolfie
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-wikipedia

    # fallback
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-fallback-chatgpt

    # OCP
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-news
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-somafm
    pip3 install git+https://github.com/OpenVoiceOS/skill-ovos-youtube-music

    # fun
    pip3 install git+https://github.com/JarbasSkills/skill-icanhazdadjokes

    # Here is where to include your local skills
    if [[ ! -d $HOME/.local/share/mycroft/skills ]]; then
        mkdir -p $HOME/.local/share/mycroft/skills
    fi

    echo
    echo "Done installing extra skills"
    echo
    }

############################################################################################
echo
echo "This file will install ovos-core to this device"
echo "using the latest commits from github."
echo
echo "First lets setup some things."
echo


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

read -p "Do you want to install systemd files (Y/n): " systemd
if [[ -z "$systemd" || $systemd == y* || $systemd == Y* ]]; then
    systemd="YES"
    echo
    read -p "Do you want to automatically start the ovos services? (Y/n): " enabled
    if [[ -z "$enabled" || $enabled == y* || $enabled == Y* ]]; then
        enabled="YES"
    fi
fi
echo
read -p "Would you like to install extra skills to match the downloadable image? (Y/n): " extra_skills
if [[ -z "$extra_skills" || $extra_skills == y* || $extra_skills == Y* ]]; then
    extra_skills="YES"
fi
echo
echo "We are now ready to install OVOS"
echo
read -p "Type 'Y' to start install (any other key aborts): " install

# update your system
sudo apt update -y
sudo apt upgrade -y

if [[ $install == Y* || $install == y* ]]; then
    if [[ ! -d $HOME/.local/bin ]]; then
        mkdir -p $HOME/.local/bin
    fi
    PATH=/home/ovos/.local/bin:$PATH
    install_core

    if [[ $systemd == "YES" ]]; then
        install_systemd
    fi

    if [[ $extra_skills == "YES" ]]; then
        install_extra_skills
    fi

    echo "Done installing OVOS"
    echo
    read -p "Would you like to start ovos now? (Y/n): " start
    if [[ -z "$start" || $start == y* || $start == Y* ]]; then
        systemctl --user start ovos
    else
        echo
        echo "You can start the ovos services with 'systemctl --user start ovos'"
        echo
    fi
    echo ""
    echo "1. Consider creating an .asoundrc and check your microphone with alsamixer, arecord, and aplay."
    echo ""
    echo "2. You can find documentation at https://github.com/OpenVoiceOS/community-docs/blob/master/docs/install_raspbian.md?rgh-link-date=2023-06-16T19%3A13%3A14Z#step-3-install-ovos-core"
    echo ""
    echo "3. After a reboot /home/ovos/.local/bin will be added to your path and give you access the ovos command line utilities."
    echo ""
    echo "Enjoy your OVOS device"
fi

exit 0