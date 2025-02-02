##########################################################################################
#
# Installer Script
#
##########################################################################################

SKIPMOUNT=false

PROPFILE=false

POSTFSDATA=false

LATESTARTSERVICE=false

REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

REPLACE="
"

print_modname() {
  ui_print "*******************************"
  ui_print "        iOS Emoji v1.0.0       "
  ui_print "*******************************"
}

on_install() {
  #Definitions
  MSG_DIR="/data/data/com.facebook.orca"
  FB_DIR="/data/data/com.facebook.katana"
  EMOJI_DIR="app_ras_blobs"
  FONT_DIR=$MODPATH/system/fonts
  FONT_EMOJI="NotoColorEmoji.ttf"
  ui_print "- Extracting module files"
  
  #Create folder fonts
  if [ ! -d "$MODPATH/system" ]; then
    mkdir $MODPATH/system
  fi
  if [ ! -d "$MODPATH/system/fonts" ]; then
    mkdir $MODPATH/system/fonts
  fi
  
  #Download latest IOS Emoji
  VERSION_EMOJI=$(curl -fsSL https://github.com/samuelngs/apple-emoji-linux/releases | grep -oE "ios-[0-9]+\.[0-9]+" | head -1)
  ui_print "- Installing emoji $VERSION_EMOJI"
  curl -sL https://github.com/samuelngs/apple-emoji-linux/releases/download/$VERSION_EMOJI/AppleColorEmoji.ttf -o $MODPATH/system/fonts/$FONT_EMOJI

  #Compatibility with different devices and potential Android 13?
  variants='SamsungColorEmoji.ttf LGNotoColorEmoji.ttf HTC_ColorEmoji.ttf AndroidEmoji-htc.ttf ColorUniEmoji.ttf DcmColorEmoji.ttf CombinedColorEmoji.ttf NoyoColorEmojiLegacy.ttf'
  for i in $variants ; do
        if [ -f "/system/fonts/$i" ]; then
            cp $FONT_DIR/$FONT_EMOJI $FONT_DIR/$i && ui_print "- Replacing $i"
        fi
  done
  
  #Facebook Messenger
  if [ -d "$MSG_DIR" ]; then
    ui_print "- Replacing Messenger Emojis"
    cd $MSG_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$FONT_EMOJI ./FacebookEmoji.ttf
  fi
  
  #Facebook App
  if [ -d "$FB_DIR" ]; then
    ui_print "- Replacing Facebook Emojis"
    cd $FB_DIR
    rm -rf $EMOJI_DIR
    mkdir $EMOJI_DIR
    cd $EMOJI_DIR
    cp $MODPATH/system/fonts/$FONT_EMOJI ./FacebookEmoji.ttf
  fi
  
  #Veryfin Android version
  android_ver=$(getprop ro.build.version.sdk)
  #if Android 12 detected
  if [ $android_ver -ge 31 ]; then
        DATA_FONT_DIR="/data/fonts/files"
    if [ -d "$DATA_FONT_DIR" ] && [ "$(ls -A $DATA_FONT_DIR)" ]; then
            ui_print "- Android 12 Detected"
            ui_print "- Checking [$DATA_FONT_DIR]"
        for dir in $DATA_FONT_DIR/*/ ; do
                cd $dir
            for file in * ; do
                if [ "$file" == *ttf ] ; then
                    cp $FONT_DIR/$FONT_EMOJI $file && ui_print "- Replacing $file"
                fi
                done
        done
    fi
  fi
  
  
  [[ -d /sbin/.core/mirror ]] && MIRRORPATH=/sbin/.core/mirror || unset MIRRORPATH
  FONTS=/system/etc/fonts.xml
  FONTFILES=$(sed -ne '/<family lang="und-Zsye".*>/,/<\/family>/ {s/.*<font weight="400" style="normal">\(.*\)<\/font>.*/\1/p;}' $MIRRORPATH$FONTS)
  for font in $FONTFILES
  do
    ln -s /system/fonts/NotoColorEmoji.ttf $MODPATH/system/fonts/$font
  done
}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700
  set_perm_recursive /data/data/com.facebook.katana/app_ras_blobs 0 0 0755 755
  set_perm_recursive /data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf 0 0 0755 700
}
