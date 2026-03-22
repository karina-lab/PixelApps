chooseport() {
  while true; do
    local event=$(/system/bin/getevent -lc 1 2>&1)
    if echo "$event" | grep -q "KEY_VOLUMEUP"; then
      return 0
    elif echo "$event" | grep -q "KEY_VOLUMEDOWN"; then
      return 1
    fi
  done
}

ask_user() {
  ui_print "- $1"
  ui_print "  Vol+ = Yes, Vol- = No"
  if chooseport; then
    ui_print "  Selected: Yes"
	sleep 0.5
	if [ "$1" = "Install Satellite Gateway?" ]; then
		ui_print "- Just why?"
	fi
	ui_print " "
    return 0
  else
    ui_print "  Selected: No"
	sleep 0.5
	ui_print " "
    return 1
  fi
}

install_component() {
    local SUB_FOLDER="apps/$1"
    local DEST_DIR="$2"

    mkdir -p "$DEST_DIR"

    ui_print "- Extracting $SUB_FOLDER files..."
    
    unzip -o "$ZIPFILE" "$SUB_FOLDER/*" -d "$TMPDIR" >&2

    if [ -d "$TMPDIR/$SUB_FOLDER" ]; then
        cp -af "$TMPDIR/$SUB_FOLDER/." "$DEST_DIR/"
        
        set_perm_recursive "$DEST_DIR" 0 0 0755 0644
        ui_print "  Success: $1 installed."
		ui_print " "
		rm -rf "$TMPDIR/$SUB_FOLDER"
    else
        ui_print "  Error: Files not found in ZIP! (Expected: $SUB_FOLDER/)"
        return 1
    fi
}

PIXEL_VER=0
INSTALL_WALLPAPERS=0
INSTALL_XMLS=0
INSTALL_STUDIO=0
INSTALL_SCREENSHOTS=0
INSTALL_MAGICCUE=0
INSTALL_GEMINI=0
INSTALL_SATELLITE=0
INSTALL_PWM=0

for i in 1 2 3 4 5
do
    if [ -d "/product/app/PixelWallpapers202$i" ]; then
        PIXEL_VER=$i
        ui_print "- Found 202$i Pixel"
		ui_print " "
        break
    fi
done

if [ "$PIXEL_VER" -eq 5 ]; then
	ui_print "- Hi, Pixel 10 owner!"
	ui_print "- Please wait for Pixel 11 to come out :)"
	abort "- Nothing to install for now!"
fi

if ask_user "Install Wallpapers from Pixel 10 series?"; then
	INSTALL_WALLPAPERS=1
else
	INSTALL_WALLPAPERS=0
fi

if ask_user "Install Sysconfigs?"; then
	INSTALL_XMLS=1
else
	INSTALL_XMLS=0
fi

if [ "$PIXEL_VER" -lt 3 ]; then
	if ask_user "Install Pixel Studio?"; then
		INSTALL_STUDIO=1
	else
		INSTALL_STUDIO=0
	fi
fi

if [ "$PIXEL_VER" -lt 4 ]; then
	if ask_user "Install Pixel Screenshots?"; then
		INSTALL_SCREENSHOTS=1
	else
		INSTALL_SCREENSHOTS=0
	fi
fi

if ask_user "Install Device Intelligence (Magic Cue)?"; then
	INSTALL_MAGICCUE=1
else
	INSTALL_MAGICCUE=0
fi

if ask_user "Install Gemini as a system app?"; then
	INSTALL_GEMINI=1
else
	INSTALL_GEMINI=0
fi

if ask_user "Install Password manager as a system app?"; then
	INSTALL_PWM=1
else
	INSTALL_PWM=0
fi

if [ "$PIXEL_VER" -lt 4 ]; then
	if ask_user "Install Satellite Gateway?"; then
		INSTALL_SATELLITE=1
	else
		INSTALL_SATELLITE=0
	fi
fi

DEST_DIR="$MODPATH/system/product"

if [ "$INSTALL_WALLPAPERS" -eq 1 ]; then
	install_component "Pixel Wallpapers" "$DEST_DIR/app/PixelWallpapers202$PIXEL_VER"
	mv "$DEST_DIR/app/PixelWallpapers202$PIXEL_VER/PixelWallpapers2025.apk" "$DEST_DIR/app/PixelWallpapers202$PIXEL_VER/PixelWallpapers202$PIXEL_VER.apk"
fi

if [ "$INSTALL_XMLS" -eq 1 ]; then
	install_component "Sysconfig" "$DEST_DIR"
fi

if [ "$INSTALL_STUDIO" -eq 1 ]; then
	install_component "Pixel Studio" "$DEST_DIR"
fi

if [ "$INSTALL_SCREENSHOTS" -eq 1 ]; then
	install_component "Pixel Screenshots" "$DEST_DIR"
fi

if [ "$INSTALL_MAGICCUE" -eq 1 ]; then
	install_component "Magic Cue" "$DEST_DIR"
fi

if [ "$INSTALL_GEMINI" -eq 1 ]; then
	install_component "Gemini" "$DEST_DIR"
fi

if [ "$INSTALL_PWM" -eq 1 ]; then
	install_component "Password Manager" "$DEST_DIR"
fi

if [ "$INSTALL_SATELLITE" -eq 1 ]; then
	install_component "Satellite Gateway" "$DEST_DIR"
fi

rm -rf "$TMPDIR/*"
rm -rf "$MODPATH/apps"