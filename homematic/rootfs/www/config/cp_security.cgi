#!/bin/tclsh
source once.tcl
sourceOnce common.tcl
sourceOnce session.tcl
sourceOnce file_io.tcl
load tclrpc.so
load tclrega.so

set PFMD_URL "bin://127.0.0.1:2002"

set portnumber 2001
catch { source "/etc/eq3services.ports.tcl" }
if { [info exists EQ3_SERVICE_RFD_PORT] } {
    set portnumber $EQ3_SERVICE_RFD_PORT
}
set RFD_URL "bin://127.0.0.1:$portnumber"

proc array_getValue { pArray name } {
  upvar $pArray arr

  set value {}
  catch { set value $arr($name) }

  return $value
}

proc get_current_key_index {} {
  set KEY_FILE "/etc/config/keys"
  set CURRENT_INDEX "Current user key"
  set PREVIOUS_INDEX "Previous user key"

  # Schl�ssel-Index ermitteln
  set fd [open "|crypttool -g" r]
  set content [read $fd]
  close $fd

  array set keys {}
  foreach line [split $content "\n"] {
    if { [regexp {([^=]*)=(.*)} $line dummy key value] } then {
      set key [string trim $key]
      set value [string trim $value]
      set keys($key) $value
    }
  }

  set currentIndex 0
  if { [info exists keys($CURRENT_INDEX)] } then {
    set currentIndex $keys($CURRENT_INDEX)
  }
  
  return $currentIndex
}

proc set_key { key } {
  global RFD_URL
  
  xmlrpc $RFD_URL changeKey $key
  
  # set always new key with crypttool
  set index [get_current_key_index]
  incr index 1
    
  set fd [open "|crypttool -S -k $key -i $index" r]
  close $fd
}

proc getSGTIN_CCU {} {

  set fp [open "/var/hmip_board_sgtin" r]
  set file_data [read $fp]
  close $fp
  set sgtinCCU [lindex [split $file_data "\n"] 0]

  return $sgtinCCU
}

proc getSGTIN_Backup {migrationMode} {

  switch $migrationMode {
    "CCU2_CCU2" {set path_crRFD "/tmp/backup/usr/local/etc/config/crRFD/data"}
    "CCU2_CCU3" {set path_crRFD "/tmp/backup/usr/local/etc/config/crRFD/data"}
    "CCU3_CCU3" {set path_crRFD "/usr/local/eQ-3-Backup/restore/etc/config/crRFD/data"}
  }

  cd $path_crRFD
  set sgtinBackup [lindex [split [glob *.apkx] "."] 0]

  return "$sgtinBackup"
}

proc getBackupErrorMessage {errorCode migration_mode} {
  set errorCode [expr $errorCode * 1]
  # ERROR CODES:
  #  9 = Check the script /bin/checkUsrBackup.sh - the java call is wrong
  # 10 = OK
  # 11 = Backup fehlerhaft / unvollst�ndig (z.B. *.apkx Datei fehlt)
  # 12 = Internet fehlt / KeyServer Timeout
  # 13 = KeyServer NAK (eine oder beide sind nicht im KeyServer)
  # 14 = Fehler bei Ger�tepersistenz (einlesen fehlgeschlagen oder Versionen / Typen nicht kompatibel)
  # 15 = Migration Fehlgeschlagen (nicht f�r die Backup Validierungs Main)
  # 16 = Adapter (Coprozessor) nicht verf�gbar (basierend auf den Konfigurationen aus dem Backup + Default aus /etc)
  # 17 = Adapter konnte nicht initialisiert werden (besch�digte Application / Fehlerr�ckmeldungen)
  # 18 = Adapter Version nicht unterst�tzt
  # 99 = Unknown error

  if {$errorCode == 13} {
    # TODO This is currently deactivated because we cannot determine for sure if a SGTIN belongs to a CCU or to a DRAP (see TWIST-1928)
    # set sgtinCCU [getSGTIN_CCU]
    # set sgtinBackup [getSGTIN_Backup $migration_mode]
  }

  set code(9) "<br/><b>\$\{backupWrongJavaCall\}</b>"
  set code(10) "<br/><b>\$\{backupOK\}</b>"
  set code(11) "<br/><b>\$\{backupBackupImperfectMissingFile\}</b>"
  set code(12) "<br/><b>\$\{backupNoInternet_KeyserverTimeout\}</b>"
  # TODO Activate the next line and delete the line after that when we can extract the SGTIN (see TWIST-1928)
  # set code(13) "<br/><b>\$\{backupKeyServer_NAK\}</b><br/><br/>SGTIN CCU: $sgtinCCU<br/>SGTIN Backup: $sgtinBackup<br/>&nbsp;"
  set code(13) "<br/><b>\$\{backupKeyServer_NAK\}</b>"
  set code(14) "<br/><b>\$\{backupErrorDevicePersistence_TypesNotCompatibel\}</b>"
  set code(15) "<br/><b>\$\{backupMigrationFailed\}</b>"
  set code(16) "<br/><b>\$\{backupCoProcessor_not_availabel\}</b>"
  set code(17) "<br/><b>\$\{backupCoProcessor_NotInitialized\}</b>"
  set code(18) "<br/><b>\$\{backupCoProcessor_VersionNotSupported\}</b>"
  set code(99) "<br/><b>\$\{backupUnknownError\}</b>"
  return $code($errorCode)
}

proc readBackupStatus {} {
  set fp [open "/tmp/backupStatus.log" r]
  set data [read $fp]
  close $fp
  return $data
}

proc checkUserBackupValidility {migrationMode} {

  switch $migrationMode {
    "CCU2_CCU2" {set pathBackup "/tmp/backup/usr/local/"}
    "CCU2_CCU3" {set pathBackup "/tmp/backup/usr/local/"}
    "CCU3_CCU3" {set pathBackup "/usr/local/eQ-3-Backup/restore/"}
  }

  catch {exec killall java}
  set tmp [catch {exec checkUsrBackup.sh $pathBackup}]
  return [readBackupStatus]
}

proc action_change_key {} {
  global env RFD_URL
  
  http_head
  import key1
  import key2  
  
  if { "$key1" != "$key2" } {
    #put_message "\${dialogSettingsSecurityMessageErrorSecKeyTitle}" "Die beiden eingegebenen Schl&uuml;ssel stimmen nicht &uuml;berein." {\${dialogBack} "showSecurityCP();"}
    put_message "\${dialogSettingsSecurityMessageErrorSecKeyTitle}" "\${dialogSettingsSecurityMessageErrorSecKeyContentKeysNotIdentical}" {\${dialogBack} "showSecurityCP();"}
    return
  }
  if { [string length "$key1"] < 5 } {
    #put_message "Sicherheitsschl&uuml;ssel setzen - Fehler" "Der eingegebene Schl&uuml;ssel ist zu kurz. Geben Sie einen Schl&uuml;ssel ein, der mindestens 5 Zeichen lang ist." {"Zur&uuml;ck" "showSecurityCP();"}
    put_message "\${dialogSettingsSecurityMessageErrorSecKeyTitle}" \${dialogSettingsSecurityMessageErrorSecKeyContentKeyShort} {\${dialogBack} "showSecurityCP();"}
    return
  }
  
  if { 0 == [regexp {^[0-9a-zA-Z_]+$} $key1 dummy] } {
    #put_message "Sicherheitsschl&uuml;ssel setzen - Fehler" "Der eingegebene Schl&uuml;ssel darf keine Sonderzeichen enthalten. Erlaubt sind lediglich die Buchstaben A bis Z, die Ziffern 0 bis 9 sowie der Unterstrich." {"Zur&uuml;ck" "showSecurityCP();"}
    put_message "\${dialogSettingsSecurityMessageErrorSecKeyTitle}" \${dialogSettingsSecurityMessageErrorSecKeyContentIllegalChar} {\${dialogBack} "showSecurityCP();"}
    return
  }
  
  # check the entered key against our current system key
  if { ![catch {exec crypttool -v -t 3 -k "$key1"}]} {

    # "Der eingegebene Schl�ssel entspricht dem aktuellen Schl�ssel der Zentrale. "
    # "Der Schl�ssel wird nicht ge�ndert."
    put_message "\${dialogSettingsSecurityMessageHintSecKeyTitle}" \${dialogSettingsSecurityMessageErrorSecKeyContentKeysIsIdentical} {\${dialogBack} "showSecurityCP();"}
    return
  }
  
  if { [catch {set_key $key1}] } {
    # "Der Schl�ssel konnte nicht gesetzt werden. Das liegt vermutlich daran, da� "
    # "der aktuelle Schl�;ssel noch nicht an alle Komponenten �bertragen wurde. "
    # "Hinweise darauf finden Sie in den Servicemeldungen."
    put_message "\${dialogSettingsSecurityMessageErrorSecKeyTitle}" \${dialogSettingsSecurityMessageErrorSecKeyContentKeyNotAllDevices} {\${dialogBack} "showSecurityCP();"}
    return
  }
  put_message "\${dialogSettingsSecurityMessageOKSecKeyTitle}" \${dialogSettingsSecurityMessageErrorSecKeyContentSetKeySucceed} {\${dialogBack} "showSecurityCP();"}
}

proc action_factory_reset_check {} {
   global env
   
  http_head
  division {class="popupTitle"} {
    puts "\${dialogSettingsSecurityMessagePerformSystemResetTitle}"
  }
  division {class="CLASS20800"} {
    table {class="popupTable"} {border="1"} {
      table_row {
        table_data {
          table {class="CLASS20810"} {width="100%"} {
            set system_has_user_key [catch {exec crypttool -v -t 0}]
            if { $system_has_user_key } {
              table_row {
                table_data {colspan="3"} {align="left"} {
                  puts "\${dialogSetSecKeyRebootHead}"
                }
              }
              table_row {
                td {width="20"} {}
                table_data {align="left"} {
                  puts "\${dialogSetSecKeyRebootLbl}"
                }
                table_data {align="right"} {
                  cgi_text key= {size="16"} {id="text_key"} {type="password"}
                }
              }
            } else {
              table_row {
                table_data {colspan="3"} {
                  puts "\${dialogSettingsSecurityMessagePerformSystemResetContent}"
                  cgi_put "<input type=hidden name=\"key\" value=dummy id=\"text_key\"/>"
                }
              }
            }            
            table_row {
              table_data {align="right"} {class="CLASS20812"} {colspan="3"} {
                division {class="popupControls CLASS20811"} {
                  division {class="CLASS20813"} {onClick="OnNextStep()"} {
                    puts "\${dialogSettingsSecurityMessagePerformBtnSystemReset}"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        table_data {class="CLASS20803"} {
          division {class="CLASS20804"} {onClick="showSecurityCP();"} {
            puts "\${btnCancel}"
          }
        }
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      OnNextStep = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=factory_reset_go&key="+document.getElementById("text_key").value);
      }
    }
     puts "translatePage('#messagebox');"
  }
}

proc action_factory_reset_go {} {
   global env

  http_head
  set system_has_user_key [catch {exec crypttool -v -t 0}]
  if { $system_has_user_key } {
    import key
    # check the entered key against our current system key
    if { [catch {exec crypttool -v -t 3 -k "$key"}]} {
      put_message "\${dialogSetSecKeyRebootFalseTitle}" {
        ${dialogSetSecKeyRebootFalseContent}
      } {"\${dialogBack}" "showSecurityCP();"}
      return
    }
  }
  catch {
    exec run-parts -a stop /etc/config/rc.d
  }
  if { [catch {
    exec crypttool -r
    # exec umount /usr/local
    # exec /usr/sbin/ubidetach -p /dev/mtd6
    # exec /usr/sbin/ubiformat /dev/mtd6 -y
    # exec /usr/sbin/ubiattach -p /dev/mtd6
    # exec /usr/sbin/ubimkvol /dev/ubi1 -N user -m
    # exec mount /usr/local

    if {[getProduct] < 3 } {
      # CCU2
      exec touch /var/doFactoryReset
    } else {
      exec touch /usr/local/.doFactoryReset
    }
    exec kill -SIGQUIT 1
  }]} {

    # TWIST-22
    set comment {
      division {class="popupTitle"} {
      puts "Systemreset: Fehler"
      }
      division {class="CLASS20800"} {
        table {class="popupTable CLASS20801"} {border="1"} {
          table_row {class="CLASS20802"} {
            table_data {
              puts {
              Das System konnte nicht auf Werkseinstellungen zur&uuml;ckgesetzt werden. Die Zentrale wird jetzt neu gestartet.
              Versuchen Sie es danach bitte erneut.<br>
              Falls diese Meldung danach wieder erscheint, deinstallieren Sie bitte jegliche Zusatzsoftware, starten die Zentrale neu und versuchen es nocheinmal.
              }
            }
          }
        }
      }
     }
  }

  put_message "\${dialogPerformRebootTitle}" {
    ${dialogPerformRebootContent}
  } {"\${btnNewLogin}" "window.location.href='/';"}

  # Nicht mehr n�tig, siehe TWIST-22
  set comment {
    else {
      division {class="popupTitle"} {
        puts "Systemreset: Neustart des Systems"
      }
      division {class="CLASS20800"} {
        table {class="popupTable CLASS20801"} {border="1"} {
          table_row {class="CLASS20802"} {
            table_data {
              puts {
                Das System wurde auf Werkseinstellungen zur&uuml;ckgesetzt. Die Zentrale wird jetzt neu gestartet.
                Bitte melden Sie sich nach dem Starten der Zentrale neu an.
              }
            }
          }
        }
      }
    }
    division {class="popupControls"} {
      table {
        table_row {
          table_data {class="CLASS20803" align="center"} {
            division {class="CLASS20804"} {onClick="window.location.href='/';"} {
              puts "Neu anmelden"
            }
          }
        }
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      var pb = "action=reboot";
      var opts = {
        postBody: pb,
        sendXML: false
      };
      new Ajax.Request(url, opts);
    }
  }
}

proc action_backup_restore_check {} {
  global env
  cd /tmp/
  
  http_head
  set i 0
  if { [catch {
    exec tar xf new_config.tar
    file delete -force /tmp/new_config.tar
  
  set config_version [read_version "firmware_version"]
  set ccu1_backup false
  if { [version_compare $config_version 2.0.0] < 0 } {
    set ccu1_backup true  
  }
  
  set system_has_user_key [catch {exec crypttool -v -t 0}]
  set stored_signature [exec cat signature]
  set calculated_signature [exec crypttool -s -t 0 <usr_local.tar.gz]

  if { "false" == $ccu1_backup } {
    set config_has_user_key [expr {"$stored_signature" != "$calculated_signature"} ]
  } else {  #CCU1 used an other default key. So we can�t check with crypttool.
    set config_has_user_key [exec cat key_index]
  }  
  } errorMessage] } {
    # "Die ausgew�hlte Datei enth�lt kein HomeMatic Systembackup. "
    # "Bitte w�hlen Sie eine g�ltige Backup-Datei aus."
    put_message "\${dialogSettingsSecurityMessageSysBackupInvalidFileTitle}" \${dialogSettingsSecurityMessageSysBackupInvalidFileContent} {\${dialogBack} "showSecurityCP();"}
    return
  }

  if { [version_compare $config_version 2.0.0] < 0 } {
    division {id="ccu1Backup" class="j_translate"} {
    put_message "\${dialogVersionControlTitle}" "\${dialogVersionControlContent}" {"\${dialogBack}" "PopupClose();"} {"\${btnOk}" "jQuery('#ccu1Backup').hide(); jQuery('#performUpdateTitle, #performUpdateContent, #performUpdateFooter').show()"}
    cgi_javascript {
      puts "translatePage('#ccu1Backup');"
    }
    }
  } else {
    cgi_javascript {
    puts "jQuery('#performUpdateTitle, #performUpdateContent, #performUpdateFooter').show()"
    }
  }

  division {id="performUpdateTitle" style="display:none" class="popupTitle"} {
    puts "\${dialogSettingsSecurityMessageSysBackupPerformTitle}"
  }
  division {id="performUpdateContent" style="display:none" class="CLASS20800"} {
    table {class="popupTable"} {border="1"} {
      table_row {
        table_data {
          table {class="CLASS20810"} {width="100%"} {
            if { $system_has_user_key || $config_has_user_key } {
              table_row {
                table_data {colspan="3"} {
                  puts {
                    ${dialogSetSecKeyLoadBackupHead}
                  }
                  number_list {
                    li {
                      ${dialogSetSecKeyLoadBackuplblA}
                    }
                    li {
                      ${dialogSetSecKeyLoadBackuplblB}
                    }
                  }
                }
              }
              table_row {
                td {width="20"} {}
                table_data {align="left"} {
                  puts "\${dialogSetSecKeyLoadBackupLblC}"
                }
                table_data {align="right"} {
                  cgi_text key= {size="16"} {id="text_key"} {type="password"}
                }
              }
            } else {
              table_row {
                table_data {colspan="3"} {
                  #puts "Bitte best&auml;tigen Sie hier, um das Systembackup einzuspielen."
                  puts "\${dialogSettingsSecurityMessageSysBackupPerformContent}"
                  cgi_put "<input type=hidden name=\"key\" value=dummy id=\"text_key\"/>"
                }
              }
            }            
            table_row {
              table_data {align="right"} {class="CLASS20812"} {colspan="3"} {
                division {class="popupControls CLASS20811"} {
                  division {class="CLASS20813"} {onClick="OnNextStep()"} {
                    puts "\${dialogSettingsSecurityMessageSysBackupBtnPerformRestore}"
                  }
                }
              }
            }
            table_row {
              table_data {class="CLASS20814"} {colspan="3"} {
                # Unterbrechen Sie w&auml;hrend des Einspielens nicht die Stromversorgung der Zentrale. Dies kann zu Datenverlust
                # f&uuml;hren.
                puts "\${dialogSettingsSecurityMessageSysBackupPerformWarning}"
              }
            }
          }
        }
      }
    }
  }
  division {id="performUpdateFooter" style="display:none" class="popupControls"} {
    table {
      table_row {
        table_data {class="CLASS20803"} {
          division {class="CLASS20804"} {onClick="PopupClose();"} {
            puts "\${btnCancel}"
          }
        }
      }
    }
    cgi_javascript {
      puts "translatePage('#messagebox');"
    }

  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {
      OnNextStep = function() {
        InterfaceMonitor.stop();
        MessageBox.show('${transferUserBackupTitle}','${transferUserBackupContent}'+' <br/><br/><img id="msgBoxBarGraph" src="/ise/img/anim_bargraph.gif"><br/>','','320','60','msgBckID', 'msgBoxBarGraph');
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=backup_restore_go&key="+document.getElementById("text_key").value);
      }
    }
  }
}

proc action_backup_restore_go {} {
  global env
  cd /tmp/
  http_head
    
  set system_version [read_version "/boot/VERSION"]
  set config_version [read_version "firmware_version"]
  set ccu1_backup false
  if { [version_compare $config_version 2.0.0] < 0 } {
    set ccu1_backup true
    set comment {
      put_message "Backup: Versionskontrolle" {
            ACHTUNG! ES WIRD JETZT VERSUCHT EIN BACKUP VON EINER CCU1 EINZUSPIELEN. HIER MUSS EVTL. NOCH EIN ABBRUCH-BUTTON IMPLEMENTIERT WERDEN.
            } {"OK" }
    }
  }

  set system_has_user_key [catch {exec crypttool -v -t 0}]
  set stored_signature [exec cat signature]

  if { "false" == $ccu1_backup } {
    set config_has_user_key [expr {"$stored_signature" != "[exec crypttool -s -t 0 <usr_local.tar.gz]"} ]
  } else {  #CCU1 used an other default key. So we can�t check with crypttool.
    set config_has_user_key [exec cat key_index]
  }
    catch { import key }
    if { $system_has_user_key } {
        # check the entered key against our current system key
        if { [catch {exec crypttool -v -t 3 -k "$key"}]} {
            #Der eingegebene System-Sicherheitsschl&uuml;ssel entspricht nicht dem aktuellen System-Sicherheitsschl&uuml;ssel der Zentrale.
            cgi_javascript {puts "MessageBox.close();"}
            put_message "\${dialogSettingsSecurityMessageSysBackupSecurityErrorTitle}" "\${dialogSettingsSecurityMessageSysBackupSecurityError1Content}"
            return
        }
    }
    if { $config_has_user_key } {
        if { "$stored_signature" != "[exec crypttool -t 3 -k "$key" -s <usr_local.tar.gz]" } {
            # Der eingegebene System-Sicherheitsschl&uuml;ssel entspricht nicht dem zur Backup-Datei geh&ouml;renden System-Sicherheitsschl&uuml;ssel.
            cgi_javascript {puts "MessageBox.close();"}
            put_message "\${dialogSettingsSecurityMessageSysBackupSecurityErrorTitle}" "\${dialogSettingsSecurityMessageSysBackupSecurityError2Content}"
            return
        }
    }

    if { [version_compare $config_version $system_version] > 0 } {
        # set msg "Das Einspielen des Backups ist nicht m&ouml;glich. Das vorliegende Backup basiert auf der Zentralen-Firmware $config_version.<br>\n"
        # append msg "Diese Firmware ist aktueller, als die derzeit auf der Zentrale installierte Version ($system_version).<br>\n"
        # append msg "F&uuml;hren Sie zun&auml;chst ein Update der Zentralen-Firmware durch und starten Sie dann das Einspielen des Systembackups erneut."
        cgi_javascript {puts "MessageBox.close();"}
        put_message "\${dialogSettingsSecurityMessageSysBackupFWUpdateNecessaryTitle}" "\${dialogSettingsSecurityMessageSysBackupFWUpdateNecessaryContentA} $config_version \${dialogSettingsSecurityMessageSysBackupFWUpdateNecessaryContentB} ($system_version) \${dialogSettingsSecurityMessageSysBackupFWUpdateNecessaryContentC}"
        return
    }

    #get key index
    set stored_index [exec cat key_index]
    if { !$system_has_user_key && $config_has_user_key } {
        exec crypttool -S -i $stored_index -k "$key"
    }

    cd /
    catch {
      exec killall hss_led
        exec killall java
        exec run-parts -a stop /etc/config/rc.d
        exec killall crond
    }

    after 5000
    # backup for version >= 2/3
    if { "false" == $ccu1_backup } {  

    set migration_mode "invalid"
      if { [version_compare $config_version 3.0.0] < 0 } {
    # CCU2 Backup
    if { [version_compare $system_version 3.0.0] < 0 } {
      # CCU2 ==> CCU2
      set migration_mode "CCU2_CCU2"
    } else {
      # CCU2 ==> CCU3
      set migration_mode "CCU2_CCU3"
    }
    } else {
      # CCU3 Backup
    set migration_mode "CCU3_CCU3"
    }
    if { "CCU2_CCU2" == $migration_mode } {
      # CCU2 ==> CCU2
      set backuperror false
      set source_version [read_version "/tmp/firmware_version"]
      set source_version [split $source_version .]
      set source_major [lindex $source_version 0]
      set source_minor [lindex $source_version 1]
      set source_patch [lindex $source_version 2]
      if { (($source_major == 2)  && ($source_minor > 17)) || (($source_major == 2) && ($source_minor == 17) && ($source_patch >= 14))} {
        # extract backup to /tmp to enable checkUsrBackup.sh to validate backup
        file delete -force /tmp/backup
        file mkdir /tmp/backup
        cd /tmp/backup
        if { [catch {exec tar xzf /tmp/usr_local.tar.gz} errorMessage] } {
          cgi_javascript {puts "MessageBox.close();"}
          put_message "\${dialogSettingsSecurityMessageSysBackupErrorTitle}" "\${dialogSettingsSecurityMessageSysBackupErrorContent} $errorMessage"
          file delete -force /tmp/firmware_version /tmp/signature /tmp/usr_local.tar.gz /tmp/backup
          return
          #set backuperror true
        } else {
          set backuperror false
          # Check if a backup with HmIP support can be used without problems
          set checkBackupState [checkUserBackupValidility $migration_mode]
          if {$checkBackupState != 10} {
            # It's not possible to use the backup
            set backuperror true
            # Start /etc/init.d/S62HMServer start
            cgi_javascript {puts "MessageBox.close();"}
            put_message "\${dialogSettingsSecurityMessageSysBackupErrorTitle}" "\${dialogSettingsSecurityMessageSysBackupErrorContent} [getBackupErrorMessage $checkBackupState $migration_mode]"
            file delete -force /tmp/firmware_version /tmp/signature /tmp/usr_local.tar.gz /tmp/backup
            cgi_javascript {puts "homematic('User.restartHmIPServer');"}
            return
          } 
        }
      }  
      if { "false" == $backuperror } { 
        #if { [version_compare $system_version 3.0.0] < 0 } {
        # Erase user file system
        exec umount /usr/local
        exec /usr/sbin/ubidetach -p /dev/mtd6
        exec /usr/sbin/ubiformat /dev/mtd6 -y
        exec /usr/sbin/ubiattach -p /dev/mtd6
        exec /usr/sbin/ubimkvol /dev/ubi1 -N user -m
        exec mount /usr/local
        #} 
        #Apply backup
        cd /
        if { [catch {exec tar xzf /tmp/usr_local.tar.gz} errorMessage] } {
          # set msg "Beim Einspielen des Systembackups ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut. "
          # append msg "Falls dieser Fehler wiederholt Auftritt, wenden Sie sich bitte mit der folgenden Fehlermeldung an den Kundenservice:\n<br>"
          # append msg $errorMessage
          cgi_javascript {puts "MessageBox.close();"}
          put_message "\${dialogSettingsSecurityMessageSysBackupErrorTitle}" "\${dialogSettingsSecurityMessageSysBackupErrorContent} $errorMessage"
          file delete -force /tmp/firmware_version /tmp/signature /tmp/usr_local.tar.gz /tmp/backup
          return
        } else {
          set backuperror false
        }
        
      }
    } elseif { "CCU3_CCU3" == $migration_mode }  {
    # CCU3 ==> CCU3
    file delete -force /usr/local/eQ-3-Backup/restore
    file mkdir /usr/local/eQ-3-Backup/restore
    cd /usr/local/eQ-3-Backup/restore
      if { [catch {exec tar xzf /tmp/usr_local.tar.gz --strip 2} errorMessage] } {
          # show message "Beim Einspielen des Systembackups ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut. "
          cgi_javascript {puts "MessageBox.close();"}
          put_message "\${dialogSettingsSecurityMessageSysBackupErrorTitle}" "\${dialogSettingsSecurityMessageSysBackupErrorContent} $errorMessage"
          set backuperror true
        } else {
          set backuperror false
        }
    } elseif { "CCU2_CCU3" == $migration_mode } {
          # CCU2 ==> CCU3
        # be sure /tmp/backup is empty
        file delete -force /tmp/backup
        # be sure restore directory is empty
        file delete -force /usr/local/eQ-3-Backup/restore
        file mkdir /tmp/backup

        cd /tmp/backup
        if { [catch {exec tar xzf /tmp/usr_local.tar.gz} errorMessage] } {
          cgi_javascript {puts "MessageBox.close();"}
          put_message "\${dialogSettingsSecurityMessageSysBackupErrorTitle}" "\${dialogSettingsSecurityMessageSysBackupErrorContent} $errorMessage"
          set backuperror true
        } else {
          # only do this when the compatibility check says ok:
          #copy old files
          file mkdir /usr/local/eQ-3-Backup/restore/etc/config
          if { [file exists /tmp/backup/usr/local/etc/config] } {
            cd /tmp/backup/usr/local/etc/config
          }

          if { [file exists InterfacesList.xml] } { file copy InterfacesList.xml /usr/local/eQ-3-Backup/restore/etc/config/InterfacesList.xml }
          if { [file exists hs485d] } { file copy hs485d /usr/local/eQ-3-Backup/restore/etc/config/hs485d }
          if { [file exists hs485d.conf] } { file copy hs485d.conf /usr/local/eQ-3-Backup/restore/etc/config/hs485d.conf }
          if { [file exists hs485types] } { file copy hs485types /usr/local/eQ-3-Backup/restore/etc/config/hs485types }
          if { [file exists rfd] } { file copy rfd /usr/local/eQ-3-Backup/restore/etc/config/rfd }
          if { [file exists rfd.conf] } { file copy rfd.conf /usr/local/eQ-3-Backup/restore/etc/config/rfd.conf }
          if { [file exists crRFD] } { file copy crRFD /usr/local/eQ-3-Backup/restore/etc/config/crRFD }
          if { [file exists userprofiles] } { file copy userprofiles /usr/local/eQ-3-Backup/restore/etc/config/userprofiles }
          if { [file exists measurement] } { file copy measurement /usr/local/eQ-3-Backup/restore/etc/config/measurement }
          if { [file exists eshlight] } { file copy eshlight /usr/local/eQ-3-Backup/restore/etc/config/eshlight }
          if { [file exists firmware] } { file copy firmware /usr/local/eQ-3-Backup/restore/etc/config/firmware }
          if { [file exists homematic.regadom] } { file copy homematic.regadom /usr/local/eQ-3-Backup/restore/etc/config/homematic.regadom }
          if { [file exists homematic.regadom.bak] } { file copy homematic.regadom.bak /usr/local/eQ-3-Backup/restore/etc/config/homematic.regadom.bak }
          if { [file exists ids] } { file copy ids /usr/local/eQ-3-Backup/restore/etc/config/ids }
          if { [file exists ntpclient] } { file copy ntpclient /usr/local/eQ-3-Backup/restore/etc/config/ntpclient }
          if { [file exists rega.conf] } { file copy rega.conf /usr/local/eQ-3-Backup/restore/etc/config/rega.conf }
          if { [file exists syslog] } { file copy syslog /usr/local/eQ-3-Backup/restore/etc/config/syslog }
          if { [file exists groups.gson] } { file copy groups.gson /usr/local/eQ-3-Backup/restore/etc/config/groups.gson }
          if { [file exists energyPrice] } { file copy energyPrice /usr/local/eQ-3-Backup/restore/etc/config/energyPrice }
          if { [file exists hmip_address.conf] } { file copy hmip_address.conf /usr/local/eQ-3-Backup/restore/etc/config/hmip_address.conf }
          if { [file exists crypttool.cfg] } { file copy crypttool.cfg /usr/local/eQ-3-Backup/restore/etc/config/crypttool.cfg }
          if { [file exists keys] } { file copy keys /usr/local/eQ-3-Backup/restore/etc/config/keys }
          if { [file exists tweaks] } { file copy tweaks /usr/local/eQ-3-Backup/restore/etc/config/tweaks }
          if { [file exists time.conf] } { file copy time.conf /usr/local/eQ-3-Backup/restore/etc/config/time.conf }

          #patch changed port settings for interfaces processes (rfd/hs485d/...)
          catch { exec /bin/migrateSecuritySettings.sh /usr/local/eQ-3-Backup/restore/etc/config}

          set backuperror false
          cd /
        }
      }
    } else {  # backup for version < 2
      #delete existing files
      file delete -force /tmp/backup
      file delete -force /etc/config/hs485d /etc/config/hs485types /etc/config/rfd /etc/config/userprofiles
      file delete -force /etc/config/homematic.regadom /etc/config/homematic.regadom.bak
      file delete -force /etc/config/ids /etc/config/ntpclient /etc/config/rega.conf /etc/config/syslog
      file delete -force /etc/config/tweaks /etc/config/TZ /etc/config/server.pem /etc/config/keys
      file delete -force /etc/config/time.conf

      file mkdir /tmp/backup
      cd /tmp/backup
      if { [catch {exec tar xzf /tmp/usr_local.tar.gz} errorMessage] } {
        put_message "\${dialogSettingsSecurityMessageSysBackupErrorTitle}" "\${dialogSettingsSecurityMessageSysBackupErrorContent} $errorMessage"
        set backuperror true
      } else {
        #copy old files
        if { [file exists /tmp/backup/usr/local/etc/config] } {
          cd /tmp/backup/usr/local/etc/config
        }

        if { [file exists hs485d] } { file copy hs485d /etc/config/hs485d }
        if { [file exists hs485types] } { file copy hs485types /etc/config/hs485types }
        if { [file exists rfd] } { file copy rfd /etc/config/rfd }
        if { [file exists userprofiles] } { file copy userprofiles /etc/config/userprofiles }
        if { [file exists homematic.regadom] } { file copy homematic.regadom /etc/config/homematic.regadom }
        if { [file exists homematic.regadom.bak] } { file copy homematic.regadom.bak /etc/config/homematic.regadom.bak }
        if { [file exists ids] } { file copy ids /etc/config/ids }
        if { [file exists ntpclient] } { file copy ntpclient /etc/config/ntpclient }
        if { [file exists rega.conf] } { file copy rega.conf /etc/config/rega.conf }
        if { [file exists syslog] } { file copy syslog /etc/config/syslog }
        if { [file exists tweaks] } { file copy tweaks /etc/config/tweaks }
        if { [file exists TZ] } { file copy TZ /etc/config/TZ }
        if { [file exists server.pem] } { file copy server.pem /etc/config/server.pem }
        if { [file exists time.conf] } { file copy time.conf /etc/config/time.conf }
        if { [file exists keys] } then {
          file copy keys /etc/config/keys
        } else {
          if { $config_has_user_key } then {
            set fd [open "/etc/config/crypttool.cfg" r]
            set content [read $fd]
            close $fd

            array set keys {}
            foreach line [split $content "\n"] {
              if { [regexp {([0-9]+) (.*)} $line dummy key value] } then {
                set key [string trim $key]
                set value [string trim $value]
                set keys($key) $value
              }
            }

            if { [info exists keys($stored_index)] } then {
              set keyvalue $keys($stored_index)
              set fd -1

              catch {set fd [open "/etc/config/keys" w]}

              if { $fd > 0 } {
                puts $fd "Current Index = $stored_index"
                puts $fd "Key 0 ="
                puts $fd "Key $stored_index = $keyvalue"
                puts $fd "Last Index = 0"
                close $fd
              }
            }
          }
        }

        catch {exec eq3configcmd rfd-interface-copy rfd.conf /etc/config/rfd.conf}

        set backuperror false
      }
    cd /
  }

  set source_version [read_version "/tmp/firmware_version"]

  set source_version [split $source_version .]
  set source_major [lindex $source_version 0]
  set source_minor [lindex $source_version 1]
  set source_patch [lindex $source_version 2]

  # Check if a backup with HmIP support can be used without problems - A CCU with a version < 2.17.14 had no HmIP support. Therefore we don't check such backups
  # (For CCU2_CCU2 this check has been executed above)
  if { "CCU2_CCU2" != $migration_mode } {
    if {($source_major >= 3) || (($source_major == 2)  && ($source_minor > 17)) || (($source_major == 2) && ($source_minor == 17) && ($source_patch >= 14))} {
      set checkBackupState [checkUserBackupValidility $migration_mode]
      if {$checkBackupState != 10} {
        # It's not possible to use the backup
        set backuperror true
        # Start /etc/init.d/S62HMServer start
        cgi_javascript {puts "homematic('User.restartHmIPServer');"}
        put_message "\${dialogSettingsSecurityMessageSysBackupErrorTitle}" "\${dialogSettingsSecurityMessageSysBackupErrorContent} [getBackupErrorMessage $checkBackupState $migration_mode]"
      }
    }
  }
  cgi_javascript {puts "MessageBox.close();"}

  if { "false" == $backuperror } {
    exec mount -o remount,ro /usr/local
    exec mount -o remount,rw /usr/local
    division {class="popupTitle"} {
      puts "\${dialogSettingsSecurityMessageSysBackupRestartSystemTitle}"
    }
    division {class="CLASS20800"} {
      table {class="popupTable CLASS20801"} {border="1"} {
        table_row {class="CLASS20802"} {
          table_data {
            puts "\${dialogSettingsSecurityMessageSysBackupRestartSystemContent}"
          }
        }
      }
    }
    division {class="popupControls"} {
      table {
        table_row {
          table_data {class="CLASS20803"} {
            division {class="CLASS20804"} {onClick="window.location.href='/';"} {
              puts "\${dialogSettingsSecurityMessageSysBackupBtnRestartSystem}"
            }
          }
        }
      }
    }
    cgi_javascript {
      puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
      puts {
        var pb = "action=reboot";
        var opts = {
          postBody: pb,
          sendXML: false
        };
        new Ajax.Request(url, opts);
      }
    }
  }


  cgi_javascript {
    puts "translatePage('#messagebox');"
  }

  file delete -force /tmp/new_config.tar /tmp/firmware_version /tmp/signature /tmp/usr_local.tar.gz /tmp/backup
}

proc put_message {title msg args} {
  division {class="popupTitle"} {
    puts $title
  }
  division {class="CLASS20800"} {
    table {class="popupTable CLASS20801"} {border="1"} {
      table_row {class="CLASS20802"} {
        table_data {
          puts $msg
        }
      }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        if { [llength $args] < 1 } { set args {{\${dialogBack} "PopupClose();"}}}
        foreach b $args {
          table_data {class="CLASS20803"} {
            division {class="CLASS20804"} "onClick=\"[lindex $b 1]\"" {
              puts [lindex $b 0]
            }
          }
        }
      }
    }
  }
  cgi_javascript {
    puts "translatePage('#messagebox');"
  }
}

proc action_set_session_timeout {} {
  set REGA_CONF_FILE "/etc/config/rega.conf"

  http_head

  if { [catch {
    import timeout
    if { $timeout != [expr int($timeout)] || 180 > $timeout || 600 < $timeout } then { error "invalid timeout" }

    set    rega_conf "# rega.conf\n"
    append rega_conf "# This file is generated by cp_security.cgi\n"
    append rega_conf "SessionTimeout=$timeout\n"
    saveToFile $REGA_CONF_FILE rega_conf


    # Die neue Zeit bis zum Ablauf der Sitzung wurde erfolgreich &uuml;bernommen.
    # Die &Auml;nderung wird mit dem n&auml;chsten Start der HomeMatic Zentrale wirksam.
    put_message "\${dialogSettingsSecurityMessageSessionTimeOutSaveTitle}" {
      <p>
        ${dialogSettingsSecurityMessageSessionTimeOutSaveContent}
      </p>
    }

  }]} then {
    # Fehler: Session Timeout &uuml;bernehmen
    # Bitte w&auml;hlen Sie eine Zeit zwischen 180 und 600 Sekunden.
    put_message "\${dialogSettingsSecurityMessageSessionTimeOutErrorTitle}" "\${dialogSettingsSecurityMessageSessionTimeOutErrorContent}"
  }
}

proc action_put_page {} {
  global env sid

  cgi_debug -on

  http_head
  division {class="popupTitle j_translate"} {
    puts "\${dialogSettingsSecurityTitle}"
  }

  division {class="CLASS20815"} {
    table {class="popupTable j_translate"} {border="1"} {
      table_row {class="CLASS20806"} {
        table_data {class="CLASS20807"} {
          puts "\${dialogSettingsSecurityTDKey}"
        }
        table_data {class="CLASS20808"} {
          table {class="CLASS20810"} {
            table_row {
              table_data {colspan="3"} {style="text-align:left"} {
                puts "\${dialogSettingsSecurityLblEnterSecKey}"
              }
            }
            table_row {
              td {width="20"} {}
              table_data {align="left"} {
                puts "\${dialogSettingsSecurityLblSecKey}"
              }
              table_data {align="right"} {
                cgi_text key1= {size="16"} {id="text_key1"} {type="password"}
              }
            }
            table_row {
              td {width="20"} {}
              table_data {align="left"} {
                puts "\${dialogSettingsSecurityLblSecKeyRepeat}"
              }
              table_data {align="right"} {
                cgi_text key2= {size="16"} {id="text_key2"} {type="password"}
              }
            }
            table_row {
              table_data {align="right"} {class="CLASS20812"} {colspan="3"} {
                division {class="popupControls CLASS20811"} {
                  division {class="CLASS20813"} {onClick="OnChangeKey()"} {
                    puts "\${dialogSettingsSecurityBtnSaveKey}"
                  }
                }
              }
            }
          }
        }
        table_data {align="left"} {class="CLASS20816"} {
          puts "\${dialogSettingsSecurityHintSecKey1}"
          number_list {
            li {
              ${dialogSettingsSecurityHintSecKey2}
            }
            li {
              ${dialogSettingsSecurityHintSecKey3}
            }
            li {
              ${dialogSettingsSecurityHintSecKey4}
            }
          }
        }
      }
      table_row {class="CLASS20806"} {
        table_data {class="CLASS20807"} {
          puts "\${dialogSettingsSecurityTDBackup}"
        }
        table_data {class="CLASS20808"} {
          table {class="CLASS20810"} {
            table_row {
              table_data {align="left"} {colspan="2"} {
                puts "\${dialogSettingsSecurityLblCreateSysBackup}"
              }
              table_data {align="right"} {
                division {class="popupControls CLASS20811"} {
                  division {class="CLASS20818 colorGradient50px"} "onClick=\"MessageBox.show('\${dialogSettingsSecurityMessageCreateSysBackupTitle}','<p class=\\\'CLASS20819\\\'>\${dialogSettingsSecurityMessageCreateSysBackupContent}</p>');window.location.href='$env(SCRIPT_NAME)?sid=$sid&action=create_backup';\"" {
                    puts "\${dialogSettingsSecurityBtnBackupCreate}"
                  }
                }
              }
            }
            table_row {
              table_data {align="left"} {colspan="3"} {
                puts "\${dialogSettingsSecurityLblRestoreBackup}"
              }
            }
            table_row {
              td {width="20"} {}
              td {colspan="2"} {style="text-align:left"} "\${dialogSettingsSecurityLblChooseBackup}"
            }
            table_row {
              td {width="20"} {}
              table_data {align="left"} {colspan="2"} {
                form "$env(SCRIPT_NAME)?sid=$sid" name=backup_form {target=config_upload_iframe} enctype=multipart/form-data method=post {
                  export action=backup_upload
                  file_button backup_file size=20 maxlength=1000000
                }
                puts {<iframe name="config_upload_iframe" class="CLASS20820" style="display: none;"></iframe>}
              }
            }
            table_row {
              td {width="20"}  {}
              td {style="text-align:left"} "\${dialogSettingsSecurityLblPerformRestore}"
              table_data {align="right"} {
                division {class="popupControls CLASS20811"} {
                  division {class="CLASS20818 colorGradient50px"} {onClick="OnBackupSubmit()"} {
                    puts "\${dialogSettingsSecurityBtnBackupUpload}"
                  }
                }
              }
            }
          }
        }
        table_data {align="left"} {class="CLASS20808"} {
          puts "\${dialogSettingsSecurityHintBackup1}"
          br
          #puts "Zum Einspielen eines Systembackups wird der System-Sicherheitsschl&uuml;ssel ben&ouml;tigt."
          #puts "Bitte halten Sie diesen bereit."
          puts "\${dialogSettingsSecurityHintBackup2}"

          set bat_level [get_bat_level]
          if {$bat_level < 50} {
            br
            division {class="CLASS20809"} {
              puts "Achtung!"
              br
              puts "\${dialogSettingsSecurityHintBackup3a} $bat_level%. \${dialogSettingsSecurityHintBackup3b}"
              #puts "Ausfall der Stromversorgung vorzubeugen, empfehlen wir Ihnen, die Batterien vor dem Einspielen"
              #puts "des Backups zu erneuern."
            }
          }
        }
      }
      table_row {class="CLASS20806"} {
        table_data {class="CLASS20807"} {
          puts "\${dialogSettingsSecurityTDSysReset}"
        }
        table_data {class="CLASS20808"} {
          table {class="CLASS20810"} {width="100%"} {
            table_row {
              table_data {align="left"} {colspan="2"} {
                puts "\${dialogSettingsSecurityLblSysResetPerform}"
              }
              table_data {align="right"} {
                division {class="popupControls CLASS20811"} {
                  division {class="CLASS20818 colorGradient50px"} {onClick="OnFactoryReset()"} {
                    puts "\${dialogSettingsSecurityBtnSysReset}"
                  }
                }
              }
            }
          }
        }
        table_data {align="left"} {class="CLASS20816"} {
          puts "\${dialogSettingsSecurityHintSysReset1}"
          br
          #puts "Die Zentrale wird in den Werkszustand zur&uuml;ckgesetzt. Alle angelernten Ger&auml;te und"
          #puts "alle erstellten Programme werden gel&ouml;scht"
          puts "\${dialogSettingsSecurityHintSysReset2}"
          br
          #puts "Alle Ger&auml;tekonfigurationen und alle mit &quot;Direkte Verkn&uuml;pfungen&quot; angelegten"
          #puts "Ger&auml;teverkn&uuml;pfungen bleiben bestehen und sind funktionsf&auml;hig."
          puts "\${dialogSettingsSecurityHintSysReset3}"
        }
      }
      table_row {class="CLASS20806"} {
      table_data {class="CLASS20807"} {
        puts "\${dialogSettingsSecurityTDSessionTimeout}"
      }
      table_data {class="CLASS20808"} {
        table {class="CLASS20817"} {width="100%"} {
        table_row {
          table_data {align="left"} {colspan="3"} {
          puts "\${dialogSettingsSecurityLblSessionTimeout}"
          }
        }
        table_row {
          td {width="20"} {}
          table_data {align="left"} {
          puts "\${dialogSettingsSecurityLblSessionTimeoutTime}"
          }
          table_data {align="right"} {
          cgi_text key2= {size="16"} {id="text_session_timeout"} {type="text"}
          }
        }
        table_row {
          table_data {align="right"} {colspan="3"} {
          division {class="popupControls CLASS20811"} {
            division {class="CLASS20813"} {onClick="OnSetSessionTimeout()"} {
            puts "\${dialogSettingsSecurityBtnSessionTimeoutSave}"
            }
          }
          }
        }
        }
      }
      table_data {align="left"} {class="CLASS20808"} {
        puts "\${dialogSettingsSecurityHintSessionTimeout1}"
        br
        puts "\${dialogSettingsSecurityHintSessionTimeout2}"
      }
      }

      # activate ssh
      table_row {class="CLASS20806"} {
      table_data {class="CLASS20807"} {
        puts "\${dialogSettingsSecurityTDSSH}"
      }

      table_data {class="CLASS20808"} {
        table {class="CLASS20817"} {width="100%"} {
        table_row {
          table_data {align="left"}  {
          puts "\${dialogSettingsSecurityLblActivateSSH}"
          }
          set checked ""
          #set checked "checked=true"
          table_data {class="CLASS21112"} {align="left"}  {
            cgi_checkbox ssh=unknown {id="sshActive"} $checked
          }
        }

        table_row {
          table_data {align="left"} {
          puts "\${dialogSettingsSecurityLblPassword}"
          }

          table_data {align="left"} {
            cgi_text key1= {size="16"} {id="sshPasswd0"} {type="password"}
          }

        }
        table_row {
          table_data {align="left"} {
          puts "\${dialogSettingsSecurityLblPasswordRepeat}"
          }
          table_data {align="left"} {
            cgi_text key1= {size="16"} {id="sshPasswd1"} {type="password"}
          }
        }

        table_row {
          table_data {align="right"} {class="CLASS20812"} {colspan="3"} {
            division {class="popupControls CLASS20811"} {
              division {class="CLASS20813"} {onClick="saveSSHConfig()"} {
                puts "\${dialogSettingsSecuritySSHSaveConfig}"
              }
            }
          }
        }
        }
      }

      table_data {align="left"} {class="CLASS20808"} {
        puts "\${dialogSettingsSecuritySSHDescription}"
      }
      }
      # auth
      if { [getProduct]  >= 3 } {
        table_row {class="CLASS20806"} {
          table_data {class="CLASS20807"} {
            puts "\${dialogSettingsSecurityTDAuth}"
          }
          table_data {class="CLASS20808"} {
            division {} {
              table {
                table_row {
                  table_data {align="left"}  {
                    puts "\${dialogSettingsSecurityLblActivateAuthRemoteXML}"
                  }
                  set checked ""
                  #set checked "checked=true"
                  table_data {class="CLASS21112"} {align="left"}  {
                    cgi_checkbox authState=unknown {id="userAuthActive"} {onClick=setUserAuth();} $checked
                  }
                }
              }
            }
          }
          table_data {class="CLASS20808"} {
            puts "\${dialogSettingsSecurityTDExplanation}"
          }
        }
      }
      # automatic redirect to https
      if { [getProduct]  >= 3 } {
        table_row {class="CLASS20806"} {
          table_data {class="CLASS20807"} {
            puts "\${cpSecurityHttpsRedirectTitle}"
          }
          table_data {class="CLASS20808"} {
            division {} {
              table {
                table_row {
                  table_data {align="left"}  {
                    puts "\${cpSecurityHttpsRedirectLabel}"
                  }
                  set checked ""
                  #set checked "checked=true"
                  table_data {class="CLASS21112"} {align="left"}  {
                    cgi_checkbox httpsRedirectState=unknown {id="httpsRedirectActive"} {onClick=setHttpsRedirect();} $checked
                  }
                }
              }
            }
          }
          table_data {class="CLASS20808"} {
            puts "\${cpSecurityHttpsRedirectDescription}"
          }
        }
      }
      # SNMP <-- may if getProduct check if needed for ccu2 too
      if { [getProduct]  >= 3 } { 
        table_row {class="CLASS20806"} {
          table_data {class="CLASS20807"} {
            puts "\${dialogSettingsSecurityTDSNMP}"
          }
          table_data {class="CLASS20808"} {
            division {} {
              table {
                table_row {
                  table_data {align="left"}  {
                    puts "\${dialogSettingsSecurityLblActivateSNMP}"
                  }
                  set checked ""
                  #set checked "checked=true"
                  table_data {class="CLASS21112"} {align="left"}  {
                    cgi_checkbox snmpState=unknown {id="snmpEnabled"} $checked
                  }
                }
                table_row {
                  table_data {align="left"} {
                  puts "\${lblUserName}"
                  }

                  table_data {align="left"} {
                    cgi_text key1= {size="16"} {id="snmpUser"} {type="text"}
                  }
                }
                table_row {
                  table_data {align="left"} {
                  puts "\${dialogSettingsSecurityLblPassword}"
                  }

                  table_data {align="left"} {
                    cgi_text key1= {size="16"} {id="snmpPasswd0"} {type="password"}
                  }
                }
                table_row {
                  table_data {align="left"} {
                  puts "\${dialogSettingsSecurityLblPasswordRepeat}"
                  }
                  table_data {align="left"} {
                    cgi_text key1= {size="16"} {id="snmpPasswd1"} {type="password"}
                  }
                }
                table_row {
                  table_data {align="right"} {class="CLASS20812"} {colspan="3"} {
                    division {class="popupControls CLASS20811"} {
                      division {class="CLASS20813"} {onClick="onSNMPSaveBtn()"} {
                        puts "\${dialogSettingsSecuritySSHSaveConfig}"
                      }
                    }
                  }
                }
              }
            }
          }
          table_data {class="CLASS20808"} {
            puts "\${dialogSettingsSecurityTDSNMPExplanation}"
          }
        }
      }
    }
  }
  division {class="popupControls"} {
    table {
      table_row {
        table_data {class="CLASS20803 j_translate"} {
          division {class="CLASS20804"} {onClick="PopupClose();restartLighttpd()"} {
            puts "\${footerBtnOk}"
          }
        }
      }
    }
  }
  puts ""
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=\" + SessionId;"
    puts {

      OnFactoryReset = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=factory_reset_check");
      }
      OnChangeKey = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=change_key&key1="+document.getElementById("text_key1").value+"&key2="+document.getElementById("text_key2").value);
      }
      OnBackupSubmit = function() {
        //ProgressBar = new ProgressBarMsgBox("Systembackup wird �bertragen...", 1);
        //ProgressBar.show();
        //ProgressBar.StartKnightRiderLight();

        document.backup_form.submit();
      };
      OnSetSessionTimeout = function() {
        dlgPopup.hide();
        dlgPopup.setWidth(400);
        dlgPopup.LoadFromFile(url, "action=set_session_timeout&timeout="+document.getElementById("text_session_timeout").value);
      };

      // Set the checkbox for the ssh activation according to its state
      jQuery("#sshActive").prop("checked",homematic("CCU.getSSHState", {}));

      checkSNMPTextFields = function() {
        var pwd0 = jQuery("#snmpPasswd0").val(),
        pwd1 = jQuery("#snmpPasswd1").val(),
        usr = jQuery("#snmpUser");

        if ((pwd0.length == 0) && (pwd1.length == 0)) {
        return "noPwdChange"
        }

        if (pwd0 === pwd1) {
        return pwd0;
        }
        return false;
      }

      checkSSHPwd = function() {
        var pwd0 = jQuery("#sshPasswd0").val(),
        pwd1 = jQuery("#sshPasswd1").val();

        if ((pwd0.length == 0) && (pwd1.length == 0)) {
        return "noPwdChange"
        }

        if (pwd0 === pwd1) {
        return pwd0;
        }
        return false;
      }

      showMsgWorkInProgress = function() {
        MessageBox.show(
        translateKey('dialogSettingsSecuritySSHMsgBoxSavePasswdTitle'),
        translateKey('dialogSettingsSecuritySSHMsgBoxSavePasswdContent')+
        ' <br/><br/><img id="msgBoxBarGraph" src="/ise/img/anim_bargraph.gif"><br/>',
        '','320','60','workInProgress', 'msgBoxBarGraph');
      };

      hideMsgWorkInProgress = function() {
        var messageBox = jQuery("#workInProgress");
        messageBox.hide();
        messageBox.remove();
      };

      restartSSHDaemon = function() {
        homematic("CCU.restartSSHDaemon", {});
      };
      showMsgSSHReady = function(result) {
        if (result && result.msg == "noError") {
        restartSSHDaemon();
        MessageBox.show(translateKey("dialogSettingsSecuritySSHMsgBoxNoErrorTitle"), translateKey("dialogSettingsSecuritySSHMsgBoxNoErrorContent"));
        } else {
        // An error occurred
        MessageBox.show(translateKey("dialogSettingsSecuritySSHMsgBoxErrorTitle"), result.msg);
        }
      };
      clearPwdFields = function() {
        jQuery("#sshPasswd0, #sshPasswd1").val("");
      };
      clearSNMPPwdFields = function() {
        jQuery("#sshPasswd0, #sshPasswd1").val("");
      };

      saveSSHConfig = function() {
        var checkBoxElm = jQuery("#sshActive"),
        sshActive = checkBoxElm.prop("checked"),
        pwd = checkSSHPwd();
        if (!pwd) {
        conInfo("passwd not equal");
        alert(translateKey("dialogSettingsSecuritySSHAlert"));
        } else if (pwd == "noPwdChange") {
        homematic("CCU.setSSH", {"mode": sshActive});
        showMsgSSHReady({'msg':'noError'});
        } else {
        showMsgWorkInProgress();
        homematic("CCU.setSSHPassword", {"passwd": pwd}, function(result) {
          homematic("CCU.setSSH", {"mode": sshActive});
          hideMsgWorkInProgress();
          showMsgSSHReady(result);
          clearPwdFields();
          });
        }
      };

      onSNMPSaveBtn = function() {
        var checkBoxElm = jQuery("#snmpEnabled"),
        snmpEnabled = checkBoxElm.prop("checked"),
        usrTextBoxElm = jQuery("#snmpUser"),
        usr = usrTextBoxElm.val(),
        pwd = checkSNMPTextFields(),
        constraintsMet=true;
        
        if(snmpEnabled && usr.length == 0) {
          alert(translateKey("dialogSettingsSecurityUserHint"));
          constraintsMet = false; 
        }
        if(snmpEnabled && (pwd === "noPwdChange" || pwd.length < 8)) {
          alert(translateKey("dialogSettingsSecurityPasswordHint"));
          constraintsMet = false;
        }
        if(snmpEnabled && !pwd) {
          conInfo("passwd not equal");
          alert(translateKey("dialogSettingsSecuritySSHAlert"));
          constraintsMet = false;
        }
        if(constraintsMet) {
          showMsgWorkInProgress();
          homematic("CCU.setSNMPEnabled", {"enabled":snmpEnabled,"usr":usr, "pass":pwd}, function(result) {
            console.log(result);
            hideMsgWorkInProgress();
            clearSNMPPwdFields();
            MessageBox.show(translateKey("dialogSettingsSecuritySSHMsgBoxNoErrorTitle"), translateKey("dialogSettingsSecuritySSHMsgBoxNoErrorContent"));
          });
        }
      };

      // Set the checkbox for the user authentication according to its state
      var hasAuthStatusChanged = false;
      var initialAuthStatus = homematic("CCU.getAuthEnabled", {});
      jQuery("#userAuthActive").prop("checked", initialAuthStatus);

      setUserAuth = function(elm) {
        var newAuthState = jQuery("#userAuthActive").prop("checked");
        homematic("CCU.setAuthEnabled", {"enabled": newAuthState});
        hasAuthStatusChanged = (initialAuthStatus != newAuthState) ? true : false;
      };

      // Set the checkbox for the https redirect according to its state
      var hasHttpsRedirectStatusChanged = false;
      var initialHttpsRedirectStatus = homematic("CCU.getHttpsRedirectEnabled", {});
      jQuery("#httpsRedirectActive").prop("checked", initialHttpsRedirectStatus);

      setHttpsRedirect = function(elm) {
        var newHttpsRedirectState = jQuery("#httpsRedirectActive").prop("checked");
        homematic("CCU.setHttpsRedirectEnabled", {"enabled": newHttpsRedirectState});
        hasHttpsRedirectStatusChanged = (initialHttpsRedirectStatus != newHttpsRedirectState) ? true : false;
      };


      //Set the checkbox for SNMP according to its state
      var hasSNMPStatusChanged = false;
      var initialSNMPStatus = homematic("CCU.getSNMPEnabled", {});
      jQuery("#snmpEnabled").prop("checked", initialSNMPStatus);

      restartLighttpd = function() {
        if (hasAuthStatusChanged || hasHttpsRedirectStatusChanged) {
        homematic("User.restartLighttpd", {}, function () {
          conInfo("Lighttpd restarted");
        });
        }
      };
    }
    puts "translatePage();"
    puts "dlgPopup.readaptSize();"
  }
}

proc action_create_backup {} {
  set HOSTNAME [exec hostname]
  set iso8601_date [exec date -Iseconds]
  regexp {^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)([+-]\d+)$} $iso8601_date dummy year month day hour minute second zone
  #save DOM
  rega system.Save()

  # special HomeAssistant handling for creating sbk
  exec /opt/hm/bin/createBackup.sh /tmp/backup.sbk
  set fd [open "|cat /tmp/backup.sbk"]
  catch {fconfigure $fd -translation binary}
  catch {fconfigure $fd -encoding binary}
  puts "Content-Type:application/x-download"
  puts "Content-Disposition:attachment;filename=ccu-backup.sbk\n"
  catch {fconfigure stdout -translation binary}
  catch {fconfigure stdout -encoding binary}
  while { ! [eof $fd]} {
    puts -nonewline [read $fd 65536]
  }
  close $fd
}

proc action_backup_upload {} {
  global env sid
  cd /tmp/

  http_head
  import_file -client backup_file
  file rename -force -- [lindex $backup_file 0] "/tmp/new_config.tar"
  cgi_javascript {
    puts "var url = \"$env(SCRIPT_NAME)?sid=$sid\";"
    puts {
      //parent.top.ProgressBar.IncCounter("Backup wurde �bertragen.");
      parent.top.dlgPopup.hide();
      parent.top.dlgPopup.setWidth(400);
      parent.top.dlgPopup.LoadFromFile(url, "action=backup_restore_check");
    }
  }
}

proc read_var { filename varname} {
  set fd [open $filename r]
  set var ""
  if { $fd >=0 } {
    while { [gets $fd buf] >=0 } {
      if [regexp "^ *$varname *= *(.*)$" $buf dummy var] break
    }
    close $fd
  }
  return $var
}

proc read_version { filename } {
  return [read_var $filename VERSION]
}

proc action_reboot {} {
  exec /sbin/reboot
}

proc _version_compare { v1 v2 } {
  # Version-Format: <main><delim><build>
  # main: Floating point number, mandatory
  # delim: String like "pre", "rc", etc. optional
  # build: Integer build number. present iff delim is present.

  foreach v { v1 v2 } {
    regexp {^([0-9]+\.[0-9]+)(?:([a-z]+)([0-9]+))?$} [set ${v}] dummy ${v}_main ${v}_delim ${v}_build
    if { [string length [set ${v}_delim]] == 0 } {
      set ${v}_delim "zzz"
      set ${v}_build 999999
    }
  }
  if { double($v1_main) > double($v2_main) } {return 1}
  if { double($v1_main) < double($v2_main) } {return -1}
  if { "$v1_delim" > "$v2_delim" } {return 1}
  if { "$v1_delim" < "$v2_delim" } {return -1}
  if { int($v1_build) > int($v2_build) } {return 1}
  if { int($v1_build) < int($v2_build) } {return -1}
  return 0
}

proc version_compare {v1 v2} {
  # v1 = backup version
  # v2 = system version

  set v1 [split $v1 .]
  set v2 [split $v2 .]

  if { int([lindex $v1 0]) > int([lindex $v2 0]) } {return 1}
  if { int([lindex $v1 0]) < int([lindex $v2 0]) } {return -1}

  if { int([lindex $v1 1]) > int([lindex $v2 1]) } {return 1}
  if { int([lindex $v1 1]) < int([lindex $v2 1]) } {return -1}

  if { int([lindex $v1 2]) > int([lindex $v2 2]) } {return 1}
  if { int([lindex $v1 2]) < int([lindex $v2 2]) } {return -1}

  return 0
}

cgi_eval {
  #cgi_debug -on
  cgi_input
  catch {
    import debug
    cgi_debug -on
  }

  set action "put_page"

  catch { import action }

  if {[session_requestisvalid 8] > 0} then action_$action
}

