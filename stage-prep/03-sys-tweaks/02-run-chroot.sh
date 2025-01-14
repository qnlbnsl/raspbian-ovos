git clone https://github.com/foundObjects/zram-swap
cd zram-swap
./install.sh
cd ..
rm -rf zram-swap

cat >> /boot/config.txt << EOF

disable_splash=1

[pi3]

force_turbo=1
boot_delay=1

[all]

EOF

if [[ ! ${VIRTUAL_ENV} ]]; then
    source /home/ovos/.venv/bin/activate;
fi

pip3 install wheel

deactivate
