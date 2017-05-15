#!/bin/bash

CONFIG_DIR=/etc/openhab/

####################
# Configure timezone

TIMEZONEFILE=$CONFIG_DIR/timezone

if [ -f "$TIMEZONEFILE" ]
then
    cp $TIMEZONEFILE /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
fi

###########################
# Configure Addon libraries

SOURCE=/opt/openhab/addons-available
DEST=/opt/openhab/addons
ADDONFILE=$CONFIG_DIR/addons.cfg

if [ -n "$OPENHAB_ADDONS_CFG" -a -e "$OPENHAB_ADDONS_CFG" ]; then
    cp "$OPENHAB_ADDONS_CFG" "$ADDONFILE"
fi

function addons {
    # Remove all links first
    rm $DEST/*

    # create new links based on input file
    while read STRING
    do
        STRING=${STRING%$'\r'}
        echo Processing $STRING...
        if [ -f $SOURCE/$STRING-*.jar ]
        then
            ln -s $SOURCE/$STRING-*.jar $DEST/
            echo link created.
        else
            echo not found.
        fi
    done < "$ADDONFILE"
}

if [ -f "$ADDONFILE" ]
then
    addons
else
    echo addons.cfg not found.
fi

###########################################
# Download Demo if no configuration is given

if [ -n "$OPENHAB_OPENHAB_CFG" -a -e "$OPENHAB_OPENHAB_CFG" ]; then
    cp "$OPENHAB_OPENHAB_CFG" "$CONFIG_DIR/openhab.cfg"
fi

if [ -f "$CONFIG_DIR/openhab.cfg" ]
then
    echo configuration found.
    rm -rf /tmp/demo-openhab*
else
    echo --------------------------------------------------------
    echo          NO openhab.cfg CONFIGURATION FOUND
    echo
    echo                = using demo files =
    echo
    echo Consider running the Docker with a openhab configuration
    echo
    echo --------------------------------------------------------
    cp -R /opt/openhab/demo-configuration/configurations/* /etc/openhab/
    ln -s /opt/openhab/demo-configuration/addons/* /opt/openhab/addons/
    ln -s /etc/openhab/openhab_default.cfg /etc/openhab/openhab.cfg
    # Redirect newbie right to demo site
    sed -i -- 's/openhab.app"/openhab.app?sitemap=demo"/g' /opt/openhab/webapps/static/index.html
fi

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
