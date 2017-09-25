#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
Configurator for Home Assistant.
https://github.com/danielperna84/hass-configurator
"""
import os
import sys
import json
import ssl
import socketserver
import base64
import ipaddress
import signal
import cgi
import shlex
import subprocess
import logging
import fnmatch
from string import Template
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.request
from urllib.parse import urlparse, parse_qs, unquote


### Some options for you to change
LISTENIP = "0.0.0.0"
LISTENPORT = 3218
# Set BASEPATH to something like "/home/hass/.homeassistant/" if you're not running the
# configurator from that path
BASEPATH = None
# Set the paths to a certificate and the key if you're using SSL, e.g "/etc/ssl/certs/mycert.pem"
SSL_CERTIFICATE = None
SSL_KEY = None
# Set the destination where the HASS API is reachable
HASS_API = "http://127.0.0.1:8123/api/"
# If a password is required to access the API, set it in the form of "password"
# if you have HA ignoring SSL locally this is not needed if on same machine.
HASS_API_PASSWORD = None
# To enable authentication, set the credentials in the form of "username:password"
CREDENTIALS = None
# Limit access to the configurator by adding allowed IP addresses / networks to the list,
# e.g ALLOWED_NETWORKS = ["192.168.0.0/24", "172.16.47.23"]
ALLOWED_NETWORKS = []
# List of statically banned IP addresses, e.g. ["1.1.1.1", "2.2.2.2"]
BANNED_IPS = []
# Ban IPs after n failed login attempts. Restart service to reset banning. The default
# of `0` disables this feature.
BANLIMIT = 0
# Enable git integration. GitPython (https://gitpython.readthedocs.io/en/stable/) has
# to be installed.
GIT = True
# Files to ignore in the UI.  A good example list that cleans up the UI is
# [".*", "*.log", "deps", "icloud", "*.conf", "*.json", "certs", "__pycache__"]
IGNORE_PATTERN = []
### End of options

LOGLEVEL = logging.INFO
LOG = logging.getLogger(__name__)
LOG.setLevel(LOGLEVEL)
SO = logging.StreamHandler(sys.stdout)
SO.setLevel(LOGLEVEL)
SO.setFormatter(logging.Formatter('%(levelname)s:%(asctime)s:%(name)s:%(message)s'))
LOG.addHandler(SO)
RELEASEURL = "https://api.github.com/repos/danielperna84/hass-configurator/releases/latest"
VERSION = "0.2.0"
BASEDIR = "."
DEV = False
HTTPD = None
FAIL2BAN_IPS = {}
REPO = False
if GIT:
    try:
        from git import Repo as REPO
    except Exception:
        LOG.warning("Unable to import Git module")
INDEX = Template(r"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0" />
    <title>HASS Configurator</title>
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/MaterialDesign-Webfont/2.0.46/css/materialdesignicons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.100.1/css/materialize.min.css">
    <style type="text/css" media="screen">
        body {
            margin: 0;
            padding: 0;
            background-color: #fafafa;
            display: flex;
            min-height: 100vh;
            flex-direction: column;
        }

        main {
            flex: 1 0 auto;
        }

        #editor {
            position: fixed;
            top: 135px;
            right: 0;
            bottom: 0;
        }

        @media only screen and (max-width: 600px) {
          #editor {
              top: 125px;
          }
          .toolbar_mobile {
              margin-bottom: 0;
          }
        }

        .leftellipsis {
            overflow: hidden;
            direction: rtl;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .select-wrapper input.select-dropdown {
            width: 96%;
            overflow: hidden;
            direction: ltr;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        #edit_float {
              z-index: 10;
        }

        #filebrowser {
            background-color: #fff;
        }

        #fbheader {
            display: block;
            cursor: initial;
            pointer-events: none;
            color: #424242 !important;
            font-weight: 400;
            font-size: .9em;
            min-height: 64px;
            padding-top: 8px;
            margin-left: -5px;
            max-width: 250px;
        }

        #fbheaderbranch {
            padding: 5px 10px !important;
            display: none;
            color: #757575 !important;
        }

        #branchselector {
            font-weight: 400;
        }

        a.branch_select.active {
            color: white !important;
        }

        #fbelements {
            margin: 0;
            position: relative;
        }

        a.collection-item {
            color: #616161 !important;
        }

        .fbtoolbarbutton {
            color: #757575 !important;
            min-height: 64px !important;
        }

        .fbmenubutton {
            color: #616161 !important;
            display: inline-block;
            float: right;
            min-height: 64px;
            padding-top: 8px !important;
            padding-left: 20px !important;
        }

        .filename {
            color: #616161 !important;
            font-weight: 400;
            display: inline-block;
            width: 185px;
            white-space: nowrap;
            text-overflow: ellipsis;
            cursor: pointer;
        }

        .nowrap {
            white-space: nowrap;
        }

        .text_darkgreen {
            color: #1b5e20 !important;
        }

        .text_darkred {
            color: #b71c1c !important;
        }

        span.stats {
            margin: -10px 0 0 0;
            padding: 0;
            font-size: 0.5em;
            color: #616161 !important;
            line-height: 16px;
            display: inherit;
        }

        .collection-item #uplink {
            background-color: #f5f5f5;
            width: 323px !important;
            margin-left: -3px !important;
        }

        input.currentfile_input {
            margin-bottom: 0;
            margin-top: 0;
            padding-left: 5px;
            border-bottom: 0;
        }

        .side_tools {
            vertical-align: middle;
        }

        .fbtoolbarbutton_icon {
            margin-top: 20px;
        }

        .collection {
            margin: 0;
            background-color: #fff;
        }

        li.collection-item {
            border-bottom: 1px solid #eeeeee !important;
        }

        .fb_side-nav li {
            line-height: 36px;
        }

        .fb_side-nav a {
          padding: 0 0 0 16px;
          display: inline-block !important;
        }

        .fb_side-nav li>a>i {
            margin-right: 16px !important;
            cursor: pointer;
        }

        .green {
            color: #fff;
        }

        .red {
            color: #fff;
        }

        #dropdown_menu, #dropdown_menu_mobile {
            min-width: 235px;
        }

        #dropdown_gitmenu {
            min-width: 140px !important;
        }

        .dropdown-content li>a,
        .dropdown-content li>span {
            color: #616161 !important;
        }

        .fb_dd {
            margin-left: -15px !important;
        }

        .blue_check:checked+label:before {
            border-right: 2px solid #03a9f4;
            border-bottom: 2px solid #03a9f4;
        }

        .input-field input:focus+label {
            color: #03a9f4 !important;
        }

        .input-field input[type=text].valid {
            border-bottom: 1px solid #03a9f4;;
            box-shadow: 0 1px 0 0 #03a9f4;;
        }

        .row .input-field input:focus {
            border-bottom: 1px solid #03a9f4 !important;
            box-shadow: 0 1px 0 0 #03a9f4 !important
        }

        #modal_acekeyboard, #modal_components, #modal_icons {
            top: auto;
            width: 96%;
            min-height: 96%;
            border-radius: 0;
            margin: auto;
        }

        .modal .modal-content_nopad {
            padding: 0;
        }

        .waves-effect.waves-blue .waves-ripple {
            background-color: #03a9f4;
        }

        .preloader-background {
	          display: flex;
	          align-items: center;
	          justify-content: center;
	          background-color: #eee;
            position: fixed;
	          z-index: 10000;
	          top: 0;
	          left: 0;
	          right: 0;
	          bottom: 0;
        }

        .modal-content_nopad {
            position: relative;
        }

        .modal-content_nopad .modal_btn {
            position: absolute;
            top: 2px;
            right:0;
        }

        footer {
            z-index: 10;
        }

        .shadow {
            height: 25px;
            margin: -26px;
            min-width: 320px;
            background-color: transparent;
        }

        .ace_optionsMenuEntry input {
            position: relative !important;
            left: 0 !important;
            opacity: 1 !important;
        }

        .ace_optionsMenuEntry select {
            position: relative !important;
            left: 0 !important;
            opacity: 1 !important;
            display: block !important;
        }

        .ace_search {
            background-color: #eeeeee !important;
            border-radius: 0 !important;
            border: 0 !important;
            box-shadow: 0 6px 10px 0 rgba(0, 0, 0, 0.14), 0 1px 18px 0 rgba(0, 0, 0, 0.12), 0 3px 5px -1px rgba(0, 0, 0, 0.3);
        }

        .ace_search_form {
            background-color: #fafafa;
            width: 300px;
            border: 0 !important;
            border-radius: 0 !important;
            outline: none !important;
            box-shadow: 0 2px 2px 0 rgba(0, 0, 0, 0.14), 0 1px 5px 0 rgba(0, 0, 0, 0.12), 0 2px 1px -2px rgba(0, 0, 0, 0.2);
            margin-bottom: 15px !important;
            margin-left: 8px !important;
            color: #424242 !important;
        }

        .ace_search_field {
            padding-left: 4px !important;
            margin-left: 10px !important;
            max-width: 275px !important;
            font-family: 'Roboto', sans-serif !important;
            border-bottom: 1px solid #03a9f4 !important;
            color: #424242 !important;
        }

        .ace_replace_form {
            background-color: #fafafa;
            width: 300px;
            border: 0 !important;
            border-radius: 0 !important;
            outline: none !important;
            box-shadow: 0 2px 2px 0 rgba(0, 0, 0, 0.14), 0 1px 5px 0 rgba(0, 0, 0, 0.12), 0 2px 1px -2px rgba(0, 0, 0, 0.2);
            margin-bottom: 15px !important;
            margin-left: 8px !important;
        }

        .ace_search_options {
            background-color: #eeeeee;
            text-align: left !important;
            letter-spacing: .5px !important;
            transition: .2s ease-out;
            font-family: 'Roboto', sans-serif !important;
            font-size: 130%;
            top: 0 !important;
        }

        .ace_searchbtn {
            text-decoration: none !important;
            min-width: 40px !important;
            min-height: 30px !important;
            color: #424242 !important;
            text-align: center !important;
            letter-spacing: .5px !important;
            transition: .2s ease-out;
            cursor: pointer;
            font-family: 'Roboto', sans-serif !important;
        }

        .ace_searchbtn:hover {
            background-color: #03a9f4;
        }

        .ace_replacebtn {
            text-decoration: none !important;
            min-width: 40px !important;
            min-height: 30px !important;
            color: #424242 !important;
            text-align: center !important;
            letter-spacing: .5px !important;
            transition: .2s ease-out;
            cursor: pointer;
            font-family: 'Roboto', sans-serif !important;
        }

        .ace_replacebtn:hover {
            background-color: #03a9f4;
        }

        .ace_button {
            text-decoration: none !important;
            min-width: 40px !important;
            min-height: 30px !important;
            border-radius: 0 !important;
            outline: none !important;
            color: #424242 !important;
            background-color: #fafafa;
            text-align: center;
            letter-spacing: .5px;
            transition: .2s ease-out;
            cursor: pointer;
            font-family: 'Roboto', sans-serif !important;
        }

        .ace_button:hover {
            background-color: #03a9f4 !important;
        }

        .fbicon_pad {
            min-height: 64px !important;
        }

        .fbmenuicon_pad {
            min-height: 64px;
            margin-top: 6px !important;
            margin-right: 18px !important;
            color: #616161 !important;
        }

        .no-padding {
            padding: 0 !important;
        }

        .branch_select {
            min-width: 300px !important;
            font-size: 14px !important;
            font-weight: 400 !important;
        }

        a.branch_hover:hover {
            background-color: #e0e0e0 !important;
        }

        .hidesave {
            opacity: 0;
            -webkit-transition: all 0.5s ease-in-out;
            -moz-transition: all 0.5s ease-in-out;
            -ms-transition: all 0.5s ease-in-out;
            -o-transition: all 0.5s ease-in-out;
            transition: all 0.5s ease-in-out;
        }

        .pathtip_color {
            -webkit-animation: fadeinout 1.75s linear 1 forwards;
            animation: fadeinout 1.75s linear 1 forwards;
        }

        @-webkit-keyframes fadeinout {
            0% { background-color: #f5f5f5; }
            50% { background-color: #ff8a80; }
            100% { background-color: #f5f5f5; }
        }
        @keyframes fadeinout {
            0% { background-color: #f5f5f5; }
            50% { background-color: #ff8a80; }
            100% { background-color: #f5f5f5; }
        }

    </style>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.8/ace.js" type="text/javascript" charset="utf-8"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.8/ext-modelist.js" type="text/javascript" charset="utf-8"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.2.8/ext-language_tools.js" type="text/javascript" charset="utf-8"></script>
</head>
<body>
  <div class="preloader-background">
    <div class="preloader-wrapper big active">
      <div class="spinner-layer spinner-blue">
        <div class="circle-clipper left">
          <div class="circle"></div>
        </div>
        <div class="gap-patch">
          <div class="circle"></div>
        </div>
        <div class="circle-clipper right">
          <div class="circle"></div>
        </div>
      </div>
      <div class="spinner-layer spinner-red">
        <div class="circle-clipper left">
          <div class="circle"></div>
        </div>
        <div class="gap-patch">
          <div class="circle"></div>
        </div>
        <div class="circle-clipper right">
          <div class="circle"></div>
        </div>
      </div>
      <div class="spinner-layer spinner-yellow">
        <div class="circle-clipper left">
          <div class="circle"></div>
        </div>
        <div class="gap-patch">
          <div class="circle"></div>
        </div>
        <div class="circle-clipper right">
          <div class="circle"></div>
        </div>
      </div>
      <div class="spinner-layer spinner-green">
        <div class="circle-clipper left">
          <div class="circle"></div>
        </div>
        <div class="gap-patch">
          <div class="circle"></div>
        </div>
        <div class="circle-clipper right">
          <div class="circle"></div>
        </div>
      </div>
    </div>
  </div>
  <header>
    <div class="navbar-fixed">
        <nav class="light-blue">
            <div class="nav-wrapper">
                <ul class="left">
                    <li><a class="waves-effect waves-light tooltipped files-collapse hide-on-small-only" data-activates="slide-out" data-position="bottom" data-delay="500" data-tooltip="Browse Filesystem" style="padding-left: 25px; padding-right: 25px;"><i class="material-icons">folder</i></a></li>
                    <li><a class="waves-effect waves-light files-collapse hide-on-med-and-up" data-activates="slide-out" style="padding-left: 25px; padding-right: 25px;"><i class="material-icons">folder</i></a></li>
                </ul>
                <ul class="right">
                    <li><a class="waves-effect waves-light tooltipped hide-on-small-only markdirty hidesave" data-position="bottom" data-delay="500" data-tooltip="Save" onclick="save_check()"><i class="material-icons">save</i></a></li>
                    <li><a class="waves-effect waves-light tooltipped hide-on-small-only modal-trigger" data-position="bottom" data-delay="500" data-tooltip="Close" href="#modal_close"><i class="material-icons">close</i></a></li>
                    <li><a class="waves-effect waves-light tooltipped hide-on-small-only" data-position="bottom" data-delay="500" data-tooltip="Search" onclick="editor.execCommand('replace')"><i class="material-icons">search</i></a></li>
                    <li><a class="waves-effect waves-light dropdown-button hide-on-small-only" data-activates="dropdown_menu" data-beloworigin="true"><i class="material-icons right">more_vert</i></a></li>
                    <li><a class="waves-effect waves-light hide-on-med-and-up markdirty hidesave" onclick="save_check()"><i class="material-icons">save</i></a></li>
                    <li><a class="waves-effect waves-light hide-on-med-and-up modal-trigger" href="#modal_close"><i class="material-icons">close</i></a></li>
                    <li><a class="waves-effect waves-light hide-on-med-and-up" onclick="editor.execCommand('replace')"><i class="material-icons">search</i></a></li>
                    <li><a class="waves-effect waves-light dropdown-button hide-on-med-and-up" data-activates="dropdown_menu_mobile" data-beloworigin="true"><i class="material-icons right">more_vert</i></a></li>
                </ul>
            </div>
        </nav>
    </div>
  </header>
  <main>
    <ul id="dropdown_menu" class="dropdown-content z-depth-4">
        <li><a class="modal-trigger" target="_blank" href="#modal_components">HASS Components</a></li>
        <li><a class="modal-trigger" target="_blank" href="#modal_icons">Material Icons</a></li>
        <li><a href="#" data-activates="ace_settings" class="ace_settings-collapse">Editor Settings</a></li>
        <li><a class="modal-trigger" href="#modal_about">About HASS-Configurator</a></li>
        <li class="divider"></li>
        <!--<li><a href="#modal_check_config">Check HASS Configuration</a></li>-->
        <li><a class="modal-trigger" href="#modal_reload_automations">Reload automations</a></li>
        <li><a class="modal-trigger" href="#modal_reload_groups">Reload groups</a></li>
        <li><a class="modal-trigger" href="#modal_reload_core">Reload core</a></li>
        <li><a class="modal-trigger" href="#modal_restart">Restart HASS</a></li>
        <li class="divider"></li>
        <li><a class="modal-trigger" href="#modal_exec_command">Execute shell command</a></li>
    </ul>
    <ul id="dropdown_menu_mobile" class="dropdown-content z-depth-4">
        <li><a target="_blank" href="https://home-assistant.io/help/">Need HASS Help?</a></li>
        <li><a target="_blank" href="https://home-assistant.io/components/">HASS Components</a></li>
        <li><a target="_blank" href="https://materialdesignicons.com/">Material Icons</a></li>
        <li><a href="#" data-activates="ace_settings" class="ace_settings-collapse">Editor Settings</a></li>
        <li><a class="modal-trigger" href="#modal_about">About HASS-Configurator</a></li>
        <li class="divider"></li>
        <!--<li><a href="#modal_check_config">Check HASS Configuration</a></li>-->
        <li><a class="modal-trigger" href="#modal_reload_automations">Reload automations</a></li>
        <li><a class="modal-trigger" href="#modal_reload_groups">Reload groups</a></li>
        <li><a class="modal-trigger" href="#modal_reload_core">Reload core</a></li>
        <li><a class="modal-trigger" href="#modal_restart">Restart HASS</a></li>
        <li class="divider"></li>
        <li><a class="modal-trigger" href="#modal_exec_command">Execute shell command</a></li>
    </ul>
    <ul id="dropdown_gitmenu" class="dropdown-content z-depth-4">
        <li><a class="modal-trigger" href="#modal_init" class="nowrap waves-effect">git init</a></li>
        <li><a class="modal-trigger" href="#modal_commit" class="nowrap waves-effect">git commit</a></li>
        <li><a class="modal-trigger" href="#modal_push" class="nowrap waves-effect">git push</a></li>
    </ul>
    <ul id="dropdown_gitmenu_mobile" class="dropdown-content z-depth-4">
        <li><a class="modal-trigger" href="#modal_init" class="nowrap waves-effect">git init</a></li>
        <li><a class="modal-trigger" href="#modal_commit" class="nowrap waves-effect">git commit</a></li>
        <li><a class="modal-trigger" href="#modal_push" class="nowrap waves-effect">git push</a></li>
    </ul>
    <div id="modal_components" class="modal bottom-sheet modal-fixed-footer">
        <div class="modal-content_nopad">
            <iframe src="https://home-assistant.io/components/" style="height: 90vh; width: 100vw"> </iframe>
            <a target="_blank" href="https://home-assistant.io/components/" class="hide-on-med-and-down modal_btn waves-effect btn-large btn-flat left"><i class="material-icons">launch</i></a>
        </div>
        <div class="modal-footer">
            <a class="modal-action modal-close waves-effect btn-flat Right light-blue-text">Close</a>
        </div>
    </div>
    <div id="modal_icons" class="modal bottom-sheet modal-fixed-footer">
    <div class="modal-content_nopad">
            <iframe src="https://materialdesignicons.com/" style="height: 90vh; width: 100vw"> </iframe>
            <a target="_blank" href="https://materialdesignicons.com/" class="hide-on-med-and-down modal_btn waves-effect btn-large btn-flat left"><i class="material-icons">launch</i></a>
        </div>
        <div class="modal-footer">
            <a class="modal-action modal-close waves-effect btn-flat Right light-blue-text">Close</a>
        </div>
    </div>
    <div id="modal_acekeyboard" class="modal bottom-sheet modal-fixed-footer">
        <div class="modal-content centered">
        <h4 class="grey-text text-darken-3">Ace Keyboard Shortcuts<i class="mdi mdi-keyboard right grey-text text-darken-3" style="font-size: 2rem;"></i></h4>
        <br>
        <ul class="collapsible popout" data-collapsible="expandable">
          <li>
            <div class="collapsible-header"><i class="material-icons">view_headline</i>Line Operations</div>
            <div class="collapsible-body">
              <table class="bordered highlight centered">
                <thead>
                  <tr>
                    <th>Windows/Linux</th>
                    <th>Mac</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Ctrl-D</td>
                    <td>Command-D</td>
                    <td>Remove line</td>
                  </tr>
                  <tr>
                    <td>Alt-Shift-Down</td>
                    <td>Command-Option-Down</td>
                    <td>Copy lines down</td>
                  </tr>
                  <tr>
                    <td>Alt-Shift-Up</td>
                    <td>Command-Option-Up</td>
                    <td>Copy lines up</td>
                  </tr>
                  <tr>
                    <td>Alt-Down</td>
                    <td>Option-Down</td>
                    <td>Move lines down</td>
                  </tr>
                  <tr>
                    <td>Alt-Up</td>
                    <td>Option-Up</td>
                    <td>Move lines up</td>
                  </tr>
                  <tr>
                    <td>Alt-Delete</td>
                    <td>Ctrl-K</td>
                    <td>Remove to line end</td>
                  </tr>
                  <tr>
                    <td>Alt-Backspace</td>
                    <td>Command-Backspace</td>
                    <td>Remove to linestart</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Backspace</td>
                    <td>Option-Backspace, Ctrl-Option-Backspace</td>
                    <td>Remove word left</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Delete</td>
                    <td>Option-Delete</td>
                    <td>Remove word right</td>
                  </tr>
                  <tr>
                    <td>---</td>
                    <td>Ctrl-O</td>
                    <td>Split line</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </li>
          <li>
            <div class="collapsible-header"><i class="material-icons">photo_size_select_small</i>Selection</div>
            <div class="collapsible-body">
              <table class="bordered highlight centered">
                <thead>
                  <tr>
                    <th >Windows/Linux</th>
                    <th >Mac</th>
                    <th >Action</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td >Ctrl-A</td>
                    <td >Command-A</td>
                    <td >Select all</td>
                  </tr>
                  <tr>
                    <td >Shift-Left</td>
                    <td >Shift-Left</td>
                    <td >Select left</td>
                  </tr>
                  <tr>
                    <td >Shift-Right</td>
                    <td >Shift-Right</td>
                    <td >Select right</td>
                  </tr>
                  <tr>
                    <td >Ctrl-Shift-Left</td>
                    <td >Option-Shift-Left</td>
                    <td >Select word left</td>
                  </tr>
                  <tr>
                    <td >Ctrl-Shift-Right</td>
                    <td >Option-Shift-Right</td>
                    <td >Select word right</td>
                  </tr>
                  <tr>
                    <td >Shift-Home</td>
                    <td >Shift-Home</td>
                    <td >Select line start</td>
                  </tr>
                  <tr>
                    <td >Shift-End</td>
                    <td >Shift-End</td>
                    <td >Select line end</td>
                  </tr>
                  <tr>
                    <td >Alt-Shift-Right</td>
                    <td >Command-Shift-Right</td>
                    <td >Select to line end</td>
                  </tr>
                  <tr>
                    <td >Alt-Shift-Left</td>
                    <td >Command-Shift-Left</td>
                    <td >Select to line start</td>
                  </tr>
                  <tr>
                    <td >Shift-Up</td>
                    <td >Shift-Up</td>
                    <td >Select up</td>
                  </tr>
                  <tr>
                    <td >Shift-Down</td>
                    <td >Shift-Down</td>
                    <td >Select down</td>
                  </tr>
                  <tr>
                    <td >Shift-PageUp</td>
                    <td >Shift-PageUp</td>
                    <td >Select page up</td>
                  </tr>
                  <tr>
                    <td >Shift-PageDown</td>
                    <td >Shift-PageDown</td>
                    <td >Select page down</td>
                  </tr>
                  <tr>
                    <td >Ctrl-Shift-Home</td>
                    <td >Command-Shift-Up</td>
                    <td >Select to start</td>
                  </tr>
                  <tr>
                    <td >Ctrl-Shift-End</td>
                    <td >Command-Shift-Down</td>
                    <td >Select to end</td>
                  </tr>
                  <tr>
                    <td >Ctrl-Shift-D</td>
                    <td >Command-Shift-D</td>
                    <td >Duplicate selection</td>
                  </tr>
                  <tr>
                    <td >Ctrl-Shift-P</td>
                    <td >---</td>
                    <td >Select to matching bracket</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </li>
          <li>
            <div class="collapsible-header"><i class="material-icons">multiline_chart</i>Multicursor</div>
            <div class="collapsible-body">
              <table class="bordered highlight centered">
                <thead>
                  <tr>
                    <th>Windows/Linux</th>
                    <th>Mac</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Ctrl-Alt-Up</td>
                    <td>Ctrl-Option-Up</td>
                    <td>Add multi-cursor above</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Alt-Down</td>
                    <td>Ctrl-Option-Down</td>
                    <td>Add multi-cursor below</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Alt-Right</td>
                    <td>Ctrl-Option-Right</td>
                    <td>Add next occurrence to multi-selection</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Alt-Left</td>
                    <td>Ctrl-Option-Left</td>
                    <td>Add previous occurrence to multi-selection</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Alt-Shift-Up</td>
                    <td>Ctrl-Option-Shift-Up</td>
                    <td>Move multicursor from current line to the line above</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Alt-Shift-Down</td>
                    <td>Ctrl-Option-Shift-Down</td>
                    <td>Move multicursor from current line to the line below</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Alt-Shift-Right</td>
                    <td>Ctrl-Option-Shift-Right</td>
                    <td>Remove current occurrence from multi-selection and move to next</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Alt-Shift-Left</td>
                    <td>Ctrl-Option-Shift-Left</td>
                    <td>Remove current occurrence from multi-selection and move to previous</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Shift-L</td>
                    <td>Ctrl-Shift-L</td>
                    <td>Select all from multi-selection</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </li>
          <li>
            <div class="collapsible-header"><i class="material-icons">call_missed_outgoing</i>Go To</div>
            <div class="collapsible-body">
              <table class="bordered highlight centered">
                <thead>
                  <tr>
                    <th>Windows/Linux</th>
                    <th>Mac</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Left</td>
                    <td>Left, Ctrl-B</td>
                    <td>Go to left</td>
                  </tr>
                  <tr>
                    <td>Right</td>
                    <td>Right, Ctrl-F</td>
                    <td>Go to right</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Left</td>
                    <td>Option-Left</td>
                    <td>Go to word left</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Right</td>
                    <td>Option-Right</td>
                    <td>Go to word right</td>
                  </tr>
                  <tr>
                    <td>Up</td>
                    <td>Up, Ctrl-P</td>
                    <td>Go line up</td>
                  </tr>
                  <tr>
                    <td>Down</td>
                    <td>Down, Ctrl-N</td>
                    <td>Go line down</td>
                  </tr>
                  <tr>
                    <td>Alt-Left, Home</td>
                    <td>Command-Left, Home, Ctrl-A</td>
                    <td>Go to line start</td>
                  </tr>
                  <tr>
                    <td>Alt-Right, End</td>
                    <td>Command-Right, End, Ctrl-E</td>
                    <td>Go to line end</td>
                  </tr>
                  <tr>
                    <td>PageUp</td>
                    <td>Option-PageUp</td>
                    <td>Go to page up</td>
                  </tr>
                  <tr>
                    <td>PageDown</td>
                    <td>Option-PageDown, Ctrl-V</td>
                    <td>Go to page down</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Home</td>
                    <td>Command-Home, Command-Up</td>
                    <td>Go to start</td>
                  </tr>
                  <tr>
                    <td>Ctrl-End</td>
                    <td>Command-End, Command-Down</td>
                    <td>Go to end</td>
                  </tr>
                  <tr>
                    <td>Ctrl-L</td>
                    <td>Command-L</td>
                    <td>Go to line</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Down</td>
                    <td>Command-Down</td>
                    <td>Scroll line down</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Up</td>
                    <td>---</td>
                    <td>Scroll line up</td>
                  </tr>
                  <tr>
                    <td>Ctrl-P</td>
                    <td>---</td>
                    <td>Go to matching bracket</td>
                  </tr>
                  <tr>
                    <td>---</td>
                    <td>Option-PageDown</td>
                    <td>Scroll page down</td>
                  </tr>
                  <tr>
                    <td>---</td>
                    <td>Option-PageUp</td>
                    <td>Scroll page up</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </li>
          <li>
            <div class="collapsible-header"><i class="material-icons">find_replace</i>Find/Replace</div>
            <div class="collapsible-body">
              <table class="bordered highlight centered">
                <thead>
                  <tr>
                    <th>Windows/Linux</th>
                    <th>Mac</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Ctrl-F</td>
                    <td>Command-F</td>
                    <td>Find</td>
                  </tr>
                  <tr>
                    <td>Ctrl-H</td>
                    <td>Command-Option-F</td>
                    <td>Replace</td>
                  </tr>
                  <tr>
                    <td>Ctrl-K</td>
                    <td>Command-G</td>
                    <td>Find next</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Shift-K</td>
                    <td>Command-Shift-G</td>
                    <td>Find previous</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </li>
          <li>
            <div class="collapsible-header"><i class="material-icons">all_out</i>Folding</div>
            <div class="collapsible-body">
              <table class="bordered highlight centered">
                <thead>
                  <tr>
                    <th>Windows/Linux</th>
                    <th>Mac</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Alt-L, Ctrl-F1</td>
                    <td>Command-Option-L, Command-F1</td>
                    <td>Fold selection</td>
                  </tr>
                  <tr>
                    <td>Alt-Shift-L, Ctrl-Shift-F1</td>
                    <td>Command-Option-Shift-L, Command-Shift-F1</td>
                    <td>Unfold</td>
                  </tr>
                  <tr>
                    <td>Alt-0</td>
                    <td>Command-Option-0</td>
                    <td>Fold all</td>
                  </tr>
                  <tr>
                    <td>Alt-Shift-0</td>
                    <td>Command-Option-Shift-0</td>
                    <td>Unfold all</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </li>
          <li>
            <div class="collapsible-header"><i class="material-icons">devices_other</i>Other</div>
            <div class="collapsible-body">
              <table class="bordered highlight centered">
                <thead>
                  <tr>
                    <th>Windows/Linux</th>
                    <th>Mac</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>Tab</td>
                    <td>Tab</td>
                    <td>Indent</td>
                  </tr>
                  <tr>
                    <td>Shift-Tab</td>
                    <td>Shift-Tab</td>
                    <td>Outdent</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Z</td>
                    <td>Command-Z</td>
                    <td>Undo</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Shift-Z, Ctrl-Y</td>
                    <td>Command-Shift-Z, Command-Y</td>
                    <td>Redo</td>
                  </tr>
                  <tr>
                    <td>Ctrl-,</td>
                    <td>Command-,</td>
                    <td>Show the settings menu</td>
                  </tr>
                  <tr>
                    <td>Ctrl-/</td>
                    <td>Command-/</td>
                    <td>Toggle comment</td>
                  </tr>
                  <tr>
                    <td>Ctrl-T</td>
                    <td>Ctrl-T</td>
                    <td>Transpose letters</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Enter</td>
                    <td>Command-Enter</td>
                    <td>Enter full screen</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Shift-U</td>
                    <td>Ctrl-Shift-U</td>
                    <td>Change to lower case</td>
                  </tr>
                  <tr>
                    <td>Ctrl-U</td>
                    <td>Ctrl-U</td>
                    <td>Change to upper case</td>
                  </tr>
                  <tr>
                    <td>Insert</td>
                    <td>Insert</td>
                    <td>Overwrite</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Shift-E</td>
                    <td>Command-Shift-E</td>
                    <td>Macros replay</td>
                  </tr>
                  <tr>
                    <td>Ctrl-Alt-E</td>
                    <td>---</td>
                    <td>Macros recording</td>
                  </tr>
                  <tr>
                    <td>Delete</td>
                    <td>---</td>
                    <td>Delete</td>
                  </tr>
                  <tr>
                    <td>---</td>
                    <td>Ctrl-L</td>
                    <td>Center selection</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </li>
        </ul>
      </div>
      <div class="modal-footer">
        <a class="modal-action modal-close waves-effect btn-flat light-blue-text">Close</a>
      </div>
    </div>
    <div id="modal_save" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Save<i class="grey-text text-darken-3 material-icons right" style="font-size: 2rem;">save</i></h4>
            <p>Do you really want to save?</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">No</a>
          <a onclick="save()" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Yes</a>
        </div>
    </div>
    <div id="modal_upload" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Upload File<i class="grey-text text-darken-3 material-icons right" style="font-size: 2.28rem;">file_upload</i></h4>
            <p>Please choose a file to upload</p>
            <form action="#" id="uploadform">
              <div class="file-field input-field">
                <div class="btn light-blue waves-effect">
                  <span>File</span>
                  <input type="file" id="uploadfile" />
                </div>
                <div class="file-path-wrapper">
                  <input class="file-path validate" type="text">
                </div>
              </div>
            </form>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">Cancel</a>
          <a onclick="upload()" class="modal-action modal-close waves-effect waves-green btn-flat light-blue-text">OK</a>
        </div>
    </div>
    <div id="modal_init" class="modal">
        <div class="modal-content">
          <h4 class="grey-text text-darken-3">git init<i class="mdi mdi-git right grey-text text-darken-3" style="font-size: 2.48rem;"></i></h4>
          <p>Are you sure you want to initialize a repository at the current path?</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">Cancel</a>
          <a onclick="gitinit()" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">OK</a>
        </div>
    </div>
    <div id="modal_commit" class="modal">
        <div class="modal-content">
          <h4 class="grey-text text-darken-3">git commit<i class="mdi mdi-git right grey-text text-darken-3" style="font-size: 2.48rem;"></i></h4>
          <div class="row">
            <div class="input-field col s12">
              <input type="text" id="commitmessage">
              <label class="active" for="commitmessage">Commit message</label>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">Cancel</a>
          <a onclick="commit(document.getElementById('commitmessage').value)" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">OK</a>
        </div>
    </div>
    <div id="modal_push" class="modal">
        <div class="modal-content">
          <h4 class="grey-text text-darken-3">git push<i class="mdi mdi-git right grey-text text-darken-3" style="font-size: 2.48rem;"></i></h4>
          <p>Are you sure you want to push your commited changes to the configured remote / origin?</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">Cancel</a>
          <a onclick="gitpush()" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">OK</a>
        </div>
    </div>
    <div id="modal_close" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Close File<i class="grey-text text-darken-3 material-icons right" style="font-size: 2.28rem;">close</i></h4>
            <p>Are you sure you want to close the current file? Unsaved changes will be lost.</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">No</a>
          <a onclick="document.getElementById('currentfile').value='';editor.getSession().setValue('');$('.markdirty').each(function(i, o){o.classList.remove('red');});" class="modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Yes</a>
        </div>
    </div>
    <div id="modal_delete" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Delete</h4>
            <p>Are you sure you want to delete <span class="fb_currentfile"></span>?</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">No</a>
          <a onclick="delete_element()" class="modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Yes</a>
        </div>
    </div>
    <div id="modal_gitadd" class="modal">
        <div class="modal-content">
          <h4 class="grey-text text-darken-3">git add<i class="mdi mdi-git right grey-text text-darken-3" style="font-size: 2.48rem;"></i></h4>
          <p>Are you sure you want to add <span class="fb_currentfile"></span> to the index?</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">No</a>
          <a onclick="gitadd()" class="modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Yes</a>
        </div>
    </div>
    <div id="modal_check_config" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Check configuration<i class="mdi mdi-settings right grey-text text-darken-3" style="font-size: 2rem;"></i></h4>
            <p>Do you want to check the configuration?</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">No</a>
          <a onclick="check_config()" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Yes</a>
        </div>
    </div>
    <div id="modal_reload_automations" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Reload automations<i class="mdi mdi-settings right grey-text text-darken-3" style="font-size: 2rem;"></i></h4>
            <p>Do you want to reload the automations?</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">No</a>
          <a onclick="reload_automations()" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Yes</a>
        </div>
    </div>
    <div id="modal_reload_groups" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Reload groups<i class="mdi mdi-settings right grey-text text-darken-3" style="font-size: 2rem;"></i></h4>
            <p>Do you want to reload the groups?</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">No</a>
          <a onclick="reload_groups()" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Yes</a>
        </div>
    </div>
    <div id="modal_reload_core" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Reload core<i class="mdi mdi-settings right grey-text text-darken-3" style="font-size: 2rem;"></i></h4>
            <p>Do you want to reload the core?</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">No</a>
          <a onclick="reload_core()" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Yes</a>
        </div>
    </div>
    <div id="modal_restart" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Restart<i class="mdi mdi-restart right grey-text text-darken-3" style="font-size: 2rem;"></i></h4>
            <p>Do you really want to restart Home Assistant?</p>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">No</a>
          <a onclick="restart()" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Yes</a>
        </div>
    </div>
    <div id="modal_exec_command" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Execute shell command<i class="mdi mdi-laptop right grey-text text-darken-3" style="font-size: 2rem;"></i></h4>
            <pre class="col s6" id="command_history"></pre>
            <br>
            <div class="row">
                <div class="input-field col s12">
                  <input placeholder="/bin/ls -l /var/log" id="commandline" type="text">
                  <label for="commandline">Command</label>
                </div>
          </div>
        </div>
        <div class="modal-footer">
            <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">Close</a>
            <a onclick="document.getElementById('command_history').innerText='';" class=" modal-action waves-effect waves-green btn-flat light-blue-text">Clear</a>
            <a onclick="exec_command()" class=" modal-action waves-effect waves-green btn-flat light-blue-text">Execute</a>
        </div>
    </div>
    <div id="modal_markdirty" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">Unsaved Changes<i class="grey-text text-darken-3 material-icons right" style="font-size: 2rem;">save</i></h4>
            <p>You have unsaved changes in the current file. Please save the changes or close the file before opening a new one.</p>
        </div>
        <div class="modal-footer">
          <a class="modal-action modal-close waves-effect waves-red btn-flat light-blue-text">Abort</a>
          <a onclick="document.getElementById('currentfile').value='';editor.getSession().setValue('');$('.markdirty').each(function(i, o){o.classList.remove('red');});" class="modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Close file</a>
          <a onclick="save()" class="modal-action modal-close waves-effect waves-green btn-flat light-blue-text">Save changes</a>
        </div>
    </div>
    <div id="modal_newfolder" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">New Folder<i class="grey-text text-darken-3 material-icons right" style="font-size: 2rem;">create_new_folder</i></h4>
            <br>
            <div class="row">
                <div class="input-field col s12">
                    <input type="text" id="newfoldername">
                    <label class="active" for="newfoldername">New Folder Name</label>
                </div>
          </div>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">Cancel</a>
          <a onclick="newfolder(document.getElementById('newfoldername').value)" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">OK</a>
        </div>
    </div>
    <div id="modal_newfile" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">New File<i class="grey-text text-darken-3 material-icons right" style="font-size: 2rem;">note_add</i></h4>
            <br>
            <div class="row">
                <div class="input-field col s12">
                    <input type="text" id="newfilename">
                    <label class="active" for="newfilename">New File Name</label>
                </div>
          </div>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">Cancel</a>
          <a onclick="newfile(document.getElementById('newfilename').value)" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">OK</a>
        </div>
    </div>
    <div id="modal_newbranch" class="modal">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3">New Branch<i class="mdi mdi-git right grey-text text-darken-3" style="font-size: 2.48rem;"></i></h4>
            <div class="row">
                <div class="input-field col s12">
                    <input type="text" id="newbranch">
                    <label class="active" for="newbranch">New Branch Name</label>
                </div>
          </div>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect waves-red btn-flat light-blue-text">Cancel</a>
          <a onclick="newbranch(document.getElementById('newbranch').value)" class=" modal-action modal-close waves-effect waves-green btn-flat light-blue-text">OK</a>
        </div>
    </div>
    <div id="modal_about" class="modal modal-fixed-footer">
        <div class="modal-content">
            <h4 class="grey-text text-darken-3"><a class="black-text" href="https://github.com/danielperna84/hass-configurator/" target="_blank">HASS Configurator</a></h4>
            <p>Version: <a class="$versionclass" href="https://github.com/danielperna84/hass-configurator/releases/" target="_blank">$current</a></p>
            <p>Web-based file editor designed to modify configuration files of <a class="light-blue-text" href="https://home-assistant.io/" target="_blank">Home Assistant</a> or other textual files. Use at your own risk.</p>
            <p>Published under the MIT license</p>
            <p>Developed by:</p>
            <ul>
                <li>
                    <div class="chip"> <img src="https://avatars3.githubusercontent.com/u/7396998?v=3&s=400" alt="Contact Person"> <a class="black-text" href="https://github.com/danielperna84" target="_blank">Daniel Perna</a> </div>
                </li>
                <li>
                    <div class="chip"> <img src="https://avatars2.githubusercontent.com/u/1509640?v=3&s=460" alt="Contact Person"> <a class="black-text" href="https://github.com/jmart518" target="_blank">JT Martinez</a> </div>
                </li>
            </ul>
            <p>Libraries used:</p>
            <div class="row">
              <div class="col s6 m3 l3">
                <a href="https://ace.c9.io/" target="_blank">
                  <div class="card grey lighten-3 hoverable waves-effect">
                    <div class="card-image">
                      <img src="https://drive.google.com/uc?export=view&id=0B6wTGzSOtvNBeld4U09LQkV0c2M">
                    </div>
                    <div class="card-content">
                      <p class="grey-text text-darken-2">Ace Editor</p>
                    </div>
                  </div>
                </a>
              </div>
              <div class="col s6 m3 l3">
                <a class="light-blue-text" href="http://materializecss.com/" target="_blank">
                  <div class="card grey lighten-3 hoverable">
                    <div class="card-image">
                      <img src="https://evwilkin.github.io/images/materializecss.png">
                    </div>
                    <div class="card-content">
                      <p class="grey-text text-darken-2">Materialize</p>
                    </div>
                  </div>
                </a>
              </div>
              <div class="col s6 m3 l3">
                <a class="light-blue-text" href="https://jquery.com/" target="_blank">
                  <div class="card grey lighten-3 hoverable">
                    <div class="card-image">
                      <img src="https://drive.google.com/uc?export=view&id=0B6wTGzSOtvNBdFI0ZXRGb01xNzQ">
                    </div>
                    <div class="card-content">
                      <p class="grey-text text-darken-2">JQuery</p>
                    </div>
                  </div>
                </a>
              </div>
              <div class="col s6 m3 l3">
                <a class="light-blue-text" href="https://gitpython.readthedocs.io" target="_blank">
                  <div class="card grey lighten-3 hoverable">
                    <div class="card-image">
                      <img src="https://drive.google.com/uc?export=view&id=0B6wTGzSOtvNBakk4ek1uRGxqYVE">
                    </div>
                    <div class="card-content">
                      <p class="grey-text text-darken-2">GitPython</p>
                    </div>
                  </div>
                </a>
              </div>
            </div>
        </div>
        <div class="modal-footer">
          <a class=" modal-action modal-close waves-effect btn-flat light-blue-text">OK</a>
        </div>
    </div>
    <!-- Main Editor Area -->
    <div class="row">
        <div class="col m4 l3 hide-on-small-only">
            <br>
            <div class="input-field col s12">
                <select onchange="insert(this.value)">
                    <option value="" disabled selected>Select trigger platform</option>
                    <option value="event">Event</option>
                    <option value="mqtt">MQTT</option>
                    <option value="numeric_state">Numeric State</option>
                    <option value="state">State</option>
                    <option value="sun">Sun</option>
                    <option value="template">Template</option>
                    <option value="time">Time</option>
                    <option value="zone">Zone</option>
                </select>
                <label>Trigger platforms</label>
            </div>
            <div class="input-field col s12">
                <select id="events" onchange="insert(this.value)"></select>
                <label>Events</label>
            </div>
            <div class="input-field col s12">
                <select id="entities" onchange="insert(this.value)"></select>
                <label>Entities</label>
            </div>
            <div class="input-field col s12">
                <select onchange="insert(this.value)">
                    <option value="" disabled selected>Select condition</option>
                    <option value="numeric_state">Numeric state</option>
                    <option value="state">State</option>
                    <option value="sun">Sun</option>
                    <option value="template">Template</option>
                    <option value="time">Time</option>
                    <option value="zone">Zone</option>
                </select>
                <label>Conditions</label>
            </div>
            <div class="input-field col s12">
                <select id="services" onchange="insert(this.value)"> </select>
                <label>Services</label>
            </div>
        </div>
        <div class="col s12 m8 l9">
          <div class="card input-field col s12 grey lighten-4 hoverable pathtip">
              <input class="currentfile_input" value="" id="currentfile" type="text">
          </div>
        </div>
        <div class="col s12 m8 l9 z-depth-2" id="editor"></div>
        <div id="edit_float" class="fixed-action-btn vertical click-to-toggle">
          <a class="btn-floating btn-large red accent-2 hoverable">
            <i class="material-icons">edit</i>
          </a>
          <ul>
            <li><a class="btn-floating yellow tooltipped" data-position="left" data-delay="50" data-tooltip="Undo" onclick="editor.execCommand('undo')"><i class="material-icons">undo</i></a></li>
            <li><a class="btn-floating green tooltipped" data-position="left" data-delay="50" data-tooltip="Redo" onclick="editor.execCommand('redo')"><i class="material-icons">redo</i></a></li>
            <li><a class="btn-floating blue tooltipped" data-position="left" data-delay="50" data-tooltip="Indent" onclick="editor.execCommand('indent')"><i class="material-icons">format_indent_increase</i></a></li>
            <li><a class="btn-floating orange tooltipped" data-position="left" data-delay="50" data-tooltip="Outdent" onclick="editor.execCommand('outdent')"><i class="material-icons">format_indent_decrease</i></a></li>
            <li><a class="btn-floating brown tooltipped" data-position="left" data-delay="50" data-tooltip="Fold" onclick="toggle_fold()"><i class="material-icons">all_out</i></a></li>
          </ul>
        </div>
      </div>
      <!-- Left filebrowser sidenav -->
      <div class="row">
        <ul id="slide-out" class="side-nav grey lighten-4">
          <li class="no-padding">
            <ul class="row no-padding center hide-on-small-only grey lighten-4" style="margin-bottom: 0;">
              <a class="col s3 waves-effect fbtoolbarbutton tooltipped modal-trigger" href="#modal_newfile" data-position="bottom" data-delay="500" data-tooltip="New File"><i class="grey-text text-darken-2 material-icons fbtoolbarbutton_icon">note_add</i></a>
              <a class="col s3 waves-effect fbtoolbarbutton tooltipped modal-trigger" href="#modal_newfolder" data-position="bottom" data-delay="500" data-tooltip="New Folder"><i class="grey-text text-darken-2 material-icons fbtoolbarbutton_icon">create_new_folder</i></a>
              <a class="col s3 waves-effect fbtoolbarbutton tooltipped modal-trigger" href="#modal_upload" data-position="bottom" data-delay="500" data-tooltip="Upload File"><i class="grey-text text-darken-2 material-icons fbtoolbarbutton_icon">file_upload</i></a>
              <a class="col s3 waves-effect fbtoolbarbutton tooltipped dropdown-button" data-activates="dropdown_gitmenu" data-alignment='right' data-beloworigin='true' data-delay='500' data-position="bottom" data-tooltip="Git"><i class="mdi mdi-git grey-text text-darken-2 material-icons" style="padding-top: 17px;"></i></a>
            </ul>
            <ul class="row center toolbar_mobile hide-on-med-and-up grey lighten-4" style="margin-bottom: 0;">
              <a class="col s3 waves-effect fbtoolbarbutton modal-trigger" href="#modal_newfile"><i class="grey-text text-darken-2 material-icons fbtoolbarbutton_icon">note_add</i></a>
              <a class="col s3 waves-effect fbtoolbarbutton modal-trigger" href="#modal_newfolder"><i class="grey-text text-darken-2 material-icons fbtoolbarbutton_icon">create_new_folder</i></a>
              <a class="col s3 waves-effect fbtoolbarbutton modal-trigger" href="#modal_upload"><i class="grey-text text-darken-2 material-icons fbtoolbarbutton_icon">file_upload</i></a>
              <a class="col s3 waves-effect fbtoolbarbutton dropdown-button" data-activates="dropdown_gitmenu_mobile" data-alignment='right' data-beloworigin='true'><i class="mdi mdi-git grey-text text-darken-2 material-icons" style="padding-top: 17px;"></i></a>
            </ul>
          </li>
          <li>
            <div class="col s2 no-padding" style="min-height: 64px">
              <a id="uplink" class="col s12 waves-effect" style="min-height: 64px; padding-top: 15px; cursor: pointer;"><i class="arrow grey-text text-darken-2 material-icons">arrow_back</i></a>
            </div>
            <div class="col s10 " style="white-space: nowrap; overflow: auto; min-height: 64px">
              <div id="fbheader" class="leftellipsis"></div>
            </div>
          </li>
          <ul id='branches' class="dropdown-content branch_select z-depth-2 grey lighten-4">
            <ul id="branchlist"></ul>
          </ul>
          <li>
            <ul class="row no-padding" style="margin-bottom: 0;">
              <a id="branchselector" class="col s10 dropdown-button waves-effect truncate grey-text text-darken-2" data-beloworigin="true" data-activates='branches'><i class="grey-text text-darken-2 left material-icons" style="margin-left: 0; margin-right: 0; padding-top: 12px; padding-right: 8px;">arrow_drop_down</i>Branch:<span id="fbheaderbranch"></span></a>
              <a id="newbranchbutton" class="waves-effect col s2 center modal-trigger" href="#modal_newbranch"><i class="grey-text text-darken-2 center material-icons" style="padding-top: 12px;">add</i></a>
            </ul>
            <div class="divider" style="margin-top: 0;"></div>
          </li>
          <li>
            <ul id="fbelements"></ul>
          </li>
          <div class="row col s12 shadow"></div>
          <div class="z-depth-3 hide-on-med-and-up">
            <div class="input-field col s12" style="margin-top: 30px;">
              <select onchange="insert(this.value)">
                <option value="" disabled selected>Select trigger platform</option>
                <option value="event">Event</option>
                <option value="mqtt">MQTT</option>
                <option value="numeric_state">Numeric State</option>
                <option value="state">State</option>
                <option value="sun">Sun</option>
                <option value="template">Template</option>
                <option value="time">Time</option>
                <option value="zone">Zone</option>
              </select>
              <label>Trigger Platforms</label>
            </div>
            <div class="input-field col s12">
              <select id="events_side" onchange="insert(this.value)"></select>
              <label>Events</label>
            </div>
            <div class="input-field col s12">
              <select id="entities_side" onchange="insert(this.value)"></select>
              <label>Entities</label>
            </div>
            <div class="input-field col s12">
              <select onchange="insert(this.value)">
                <option value="" disabled selected>Select condition</option>
                <option value="numeric_state">Numeric state</option>
                <option value="state">State</option>
                <option value="sun">Sun</option>
                <option value="template">Template</option>
                <option value="time">Time</option>
                <option value="zone">Zone</option>
              </select>
              <label>Conditions</label>
            </div>
            <div class="input-field col s12">
              <select id="services_side" onchange="insert(this.value)"></select>
              <label>Services</label>
            </div>
          </div>
        </ul>
      </div>
      <!-- Ace Editor SideNav -->
      <div class="row">
        <ul id="ace_settings" class="side-nav">
          <li class="center s12 grey lighten-3 z-depth-1 subheader">Editor Settings</li>
          <div class="row col s12">
              <p class="col s12"> <a class="waves-effect waves-light btn light-blue modal-trigger" href="#modal_acekeyboard">Keyboard Shortcuts</a> </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('animatedScroll', !editor.getOptions().animatedScroll)" id="animatedScroll" />
                  <Label for="animatedScroll">Animated Scroll</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('behavioursEnabled', !editor.getOptions().behavioursEnabled)" id="behavioursEnabled" />
                  <Label for="behavioursEnabled">Behaviour Enabled</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('displayIndentGuides', !editor.getOptions().displayIndentGuides)" id="displayIndentGuides" />
                  <Label for="displayIndentGuides">Display Indent Guides</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('fadeFoldWidgets', !editor.getOptions().fadeFoldWidgets)" id="fadeFoldWidgets" />
                  <Label for="fadeFoldWidgets">Fade Fold Widgets</label>
              </p>
              <div class="input-field col s12">
                  <input type="number" onchange="editor.setOption('fontSize', parseInt(this.value))" min="6" id="fontSize">
                  <label class="active" for="fontSize">Font Size</label>
              </div>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('highlightActiveLine', !editor.getOptions().highlightActiveLine)" id="highlightActiveLine" />
                  <Label for="highlightActiveLine">Hightlight Active Line</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('highlightGutterLine', !editor.getOptions().highlightGutterLine)" id="highlightGutterLine" />
                  <Label for="highlightGutterLine">Hightlight Gutter Line</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('highlightSelectedWord', !editor.getOptions().highlightSelectedWord)" id="highlightSelectedWord" />
                  <Label for="highlightSelectedWord">Hightlight Selected Word</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('hScrollBarAlwaysVisible', !editor.getOptions().hScrollBarAlwaysVisible)" id="hScrollBarAlwaysVisible" />
                  <Label for="hScrollBarAlwaysVisible">H Scroll Bar Always Visible</label>
              </p>
              <div class="input-field col s12">
                  <select onchange="editor.setKeyboardHandler(this.value)" id="setKeyboardHandler">
                      <option value="">ace</option>
                      <option value="ace/keyboard/vim">vim</option>
                      <option value="ace/keyboard/emacs">emacs</option>
                  </select>
                  <label for="setKeyboardHandler">Keyboard Handler</label>
              </div>
              <div class="input-field col s12">
                  <select onchange="editor.setOption('mode', this.value)" id="mode">
                      <option value="ace/mode/abap">abap</option>
                      <option value="ace/mode/abc">abc</option>
                      <option value="ace/mode/actionscript">actionscript</option>
                      <option value="ace/mode/ada">ada</option>
                      <option value="ace/mode/apache_conf">apache_conf</option>
                      <option value="ace/mode/asciidoc">asciidoc</option>
                      <option value="ace/mode/assembly_x86">assembly_x86</option>
                      <option value="ace/mode/autohotkey">autohotkey</option>
                      <option value="ace/mode/batchfile">batchfile</option>
                      <option value="ace/mode/bro">bro</option>
                      <option value="ace/mode/c_cpp">c_cpp</option>
                      <option value="ace/mode/c9search">c9search</option>
                      <option value="ace/mode/cirru">cirru</option>
                      <option value="ace/mode/clojure">clojure</option>
                      <option value="ace/mode/cobol">cobol</option>
                      <option value="ace/mode/coffee">coffee</option>
                      <option value="ace/mode/coldfusion">coldfusion</option>
                      <option value="ace/mode/csharp">csharp</option>
                      <option value="ace/mode/css">css</option>
                      <option value="ace/mode/curly">curly</option>
                      <option value="ace/mode/d">d</option>
                      <option value="ace/mode/dart">dart</option>
                      <option value="ace/mode/diff">diff</option>
                      <option value="ace/mode/django">django</option>
                      <option value="ace/mode/dockerfile">dockerfile</option>
                      <option value="ace/mode/dot">dot</option>
                      <option value="ace/mode/drools">drools</option>
                      <option value="ace/mode/dummy">dummy</option>
                      <option value="ace/mode/dummysyntax">dummysyntax</option>
                      <option value="ace/mode/eiffel">eiffel</option>
                      <option value="ace/mode/ejs">ejs</option>
                      <option value="ace/mode/elixir">elixir</option>
                      <option value="ace/mode/elm">elm</option>
                      <option value="ace/mode/erlang">erlang</option>
                      <option value="ace/mode/forth">forth</option>
                      <option value="ace/mode/fortran">fortran</option>
                      <option value="ace/mode/ftl">ftl</option>
                      <option value="ace/mode/gcode">gcode</option>
                      <option value="ace/mode/gherkin">gherkin</option>
                      <option value="ace/mode/gitignore">gitignore</option>
                      <option value="ace/mode/glsl">glsl</option>
                      <option value="ace/mode/gobstones">gobstones</option>
                      <option value="ace/mode/golang">golang</option>
                      <option value="ace/mode/groovy">groovy</option>
                      <option value="ace/mode/haml">haml</option>
                      <option value="ace/mode/handlebars">handlebars</option>
                      <option value="ace/mode/haskell">haskell</option>
                      <option value="ace/mode/haskell_cabal">haskell_cabal</option>
                      <option value="ace/mode/haxe">haxe</option>
                      <option value="ace/mode/hjson">hjson</option>
                      <option value="ace/mode/html">html</option>
                      <option value="ace/mode/html_elixir">html_elixir</option>
                      <option value="ace/mode/html_ruby">html_ruby</option>
                      <option value="ace/mode/ini">ini</option>
                      <option value="ace/mode/io">io</option>
                      <option value="ace/mode/jack">jack</option>
                      <option value="ace/mode/jade">jade</option>
                      <option value="ace/mode/java">java</option>
                      <option value="ace/mode/javascript">javascript</option>
                      <option value="ace/mode/json">json</option>
                      <option value="ace/mode/jsoniq">jsoniq</option>
                      <option value="ace/mode/jsp">jsp</option>
                      <option value="ace/mode/jsx">jsx</option>
                      <option value="ace/mode/julia">julia</option>
                      <option value="ace/mode/kotlin">kotlin</option>
                      <option value="ace/mode/latex">latex</option>
                      <option value="ace/mode/less">less</option>
                      <option value="ace/mode/liquid">liquid</option>
                      <option value="ace/mode/lisp">lisp</option>
                      <option value="ace/mode/livescript">livescript</option>
                      <option value="ace/mode/logiql">logiql</option>
                      <option value="ace/mode/lsl">lsl</option>
                      <option value="ace/mode/lua">lua</option>
                      <option value="ace/mode/luapage">luapage</option>
                      <option value="ace/mode/lucene">lucene</option>
                      <option value="ace/mode/makefile">makefile</option>
                      <option value="ace/mode/markdown">markdown</option>
                      <option value="ace/mode/mask">mask</option>
                      <option value="ace/mode/matlab">matlab</option>
                      <option value="ace/mode/maze">maze</option>
                      <option value="ace/mode/mel">mel</option>
                      <option value="ace/mode/mushcode">mushcode</option>
                      <option value="ace/mode/mysql">mysql</option>
                      <option value="ace/mode/nix">nix</option>
                      <option value="ace/mode/nsis">nsis</option>
                      <option value="ace/mode/objectivec">objectivec</option>
                      <option value="ace/mode/ocaml">ocaml</option>
                      <option value="ace/mode/pascal">pascal</option>
                      <option value="ace/mode/perl">perl</option>
                      <option value="ace/mode/pgsql">pgsql</option>
                      <option value="ace/mode/php">php</option>
                      <option value="ace/mode/powershell">powershell</option>
                      <option value="ace/mode/praat">praat</option>
                      <option value="ace/mode/prolog">prolog</option>
                      <option value="ace/mode/properties">properties</option>
                      <option value="ace/mode/protobuf">protobuf</option>
                      <option value="ace/mode/python">python</option>
                      <option value="ace/mode/r">r</option>
                      <option value="ace/mode/razor">razor</option>
                      <option value="ace/mode/rdoc">rdoc</option>
                      <option value="ace/mode/rhtml">rhtml</option>
                      <option value="ace/mode/rst">rst</option>
                      <option value="ace/mode/ruby">ruby</option>
                      <option value="ace/mode/rust">rust</option>
                      <option value="ace/mode/sass">sass</option>
                      <option value="ace/mode/scad">scad</option>
                      <option value="ace/mode/scala">scala</option>
                      <option value="ace/mode/scheme">scheme</option>
                      <option value="ace/mode/scss">scss</option>
                      <option value="ace/mode/sh">sh</option>
                      <option value="ace/mode/sjs">sjs</option>
                      <option value="ace/mode/smarty">smarty</option>
                      <option value="ace/mode/snippets">snippets</option>
                      <option value="ace/mode/soy_template">soy_template</option>
                      <option value="ace/mode/space">space</option>
                      <option value="ace/mode/sql">sql</option>
                      <option value="ace/mode/sqlserver">sqlserver</option>
                      <option value="ace/mode/stylus">stylus</option>
                      <option value="ace/mode/svg">svg</option>
                      <option value="ace/mode/swift">swift</option>
                      <option value="ace/mode/tcl">tcl</option>
                      <option value="ace/mode/tex">tex</option>
                      <option value="ace/mode/text">text</option>
                      <option value="ace/mode/textile">textile</option>
                      <option value="ace/mode/toml">toml</option>
                      <option value="ace/mode/tsx">tsx</option>
                      <option value="ace/mode/twig">twig</option>
                      <option value="ace/mode/typescript">typescript</option>
                      <option value="ace/mode/vala">vala</option>
                      <option value="ace/mode/vbscript">vbscript</option>
                      <option value="ace/mode/velocity">velocity</option>
                      <option value="ace/mode/verilog">verilog</option>
                      <option value="ace/mode/vhdl">vhdl</option>
                      <option value="ace/mode/wollok">wollok</option>
                      <option value="ace/mode/xml">xml</option>
                      <option value="ace/mode/xquery">xquery</option>
                      <option value="ace/mode/yaml">yaml</option>
                  </select>
                  <label for="mode">Mode</label>
              </div>
              <div class="input-field col s12">
                  <select onchange="editor.setOption('newLineMode', this.value)" id="newLineMode">
                      <option value="auto">Auto</option>
                      <option value="windows">Windows</option>
                      <option value="unix">Unix</option>
                  </select>
                  <label for="newLineMode">New Line Mode</label>
              </div>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('overwrite', !editor.getOptions().overwrite)" id="overwrite" />
                  <Label for="overwrite">Overwrite</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('readOnly', !editor.getOptions().readOnly)" id="readOnly" />
                  <Label for="readOnly">Read Only</label>
              </p>
              <div class="input-field col s12">
                  <input value="2" type="number" onchange="editor.setOption('scrollSpeed', parseInt(this.value))" id="scrollSpeed">
                  <label class="active" for="scrollSpeed">Scroll Speed</label>
              </div>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('showFoldWidgets', !editor.getOptions().showFoldWidgets)" id="showFoldWidgets" />
                  <Label for="showFoldWidgets">Show Fold Widgets</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('showGutter', !editor.getOptions().showGutter)" id="showGutter" />
                  <Label for="showGutter">Show Gutter</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('showInvisibles', !editor.getOptions().showInvisibles)" id="showInvisibles" />
                  <Label for="showInvisibles">Show Invisibles</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('showPrintMargin', !editor.getOptions().showPrintMargin)" id="showPrintMargin" />
                  <Label for="showPrintMargin">Show Print Margin</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('showLineNumbers', !editor.getOptions().showLineNumbers)" id="showLineNumbers" />
                  <Label for="showLineNumbers">Show Line Numbers</label>
              </p>
              <div class="input-field col s12">
                  <input type="number" onchange="editor.setOption('tabSize', parseInt(this.value))" min="1" id="tabSize">
                  <label class="active" for="tabSize">Tab Size</label>
              </div>
              <div class="input-field col s12">
                  <select onchange="editor.setTheme(this.value)" id="theme">
                      <optgroup label="Light Themes">
                          <option value="ace/theme/chrome">Chrome</option>
                          <option value="ace/theme/clouds">Clouds</option>
                          <option value="ace/theme/crimson_editor">Crimson Editor</option>
                          <option value="ace/theme/dawn">Dawn</option>
                          <option value="ace/theme/dreamweaver">Dreamweaver</option>
                          <option value="ace/theme/eclipse">Eclipse</option>
                          <option value="ace/theme/github">GitHub</option>
                          <option value="ace/theme/iplastic">IPlastic</option>
                          <option value="ace/theme/solarized_light">Solarized Light</option>
                          <option value="ace/theme/textmate">TextMate</option>
                          <option value="ace/theme/tomorrow">Tomorrow</option>
                          <option value="ace/theme/xcode">XCode</option>
                          <option value="ace/theme/kuroir">Kuroir</option>
                          <option value="ace/theme/katzenmilch">KatzenMilch</option>
                          <option value="ace/theme/sqlserver">SQL Server</option>
                      </optgroup>
                      <optgroup label="Dark Themes">
                          <option value="ace/theme/ambiance">Ambiance</option>
                          <option value="ace/theme/chaos">Chaos</option>
                          <option value="ace/theme/clouds_midnight">Clouds Midnight</option>
                          <option value="ace/theme/cobalt">Cobalt</option>
                          <option value="ace/theme/gruvbox">Gruvbox</option>
                          <option value="ace/theme/idle_fingers">idle Fingers</option>
                          <option value="ace/theme/kr_theme">krTheme</option>
                          <option value="ace/theme/merbivore">Merbivore</option>
                          <option value="ace/theme/merbivore_soft">Merbivore Soft</option>
                          <option value="ace/theme/mono_industrial">Mono Industrial</option>
                          <option value="ace/theme/monokai">Monokai</option>
                          <option value="ace/theme/pastel_on_dark">Pastel on dark</option>
                          <option value="ace/theme/solarized_dark">Solarized Dark</option>
                          <option value="ace/theme/terminal">Terminal</option>
                          <option value="ace/theme/tomorrow_night">Tomorrow Night</option>
                          <option value="ace/theme/tomorrow_night_blue">Tomorrow Night Blue</option>
                          <option value="ace/theme/tomorrow_night_bright">Tomorrow Night Bright</option>
                          <option value="ace/theme/tomorrow_night_eighties">Tomorrow Night 80s</option>
                          <option value="ace/theme/twilight">Twilight</option>
                          <option value="ace/theme/vibrant_ink">Vibrant Ink</option>
                      </optgroup>
                  </select>
                  <label for="theme">Theme</label>
              </div>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('useSoftTabs', !editor.getOptions().useSoftTabs)" id="useSoftTabs" />
                  <Label for="useSoftTabs">Use Soft Tabs</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('useWorker', !editor.getOptions().useWorker)" id="useWorker" />
                  <Label for="useWorker">Use Worker</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('vScrollBarAlwaysVisible', !editor.getOptions().vScrollBarAlwaysVisible)" id="vScrollBarAlwaysVisible" />
                  <Label for="vScrollBarAlwaysVisible">V Scroll Bar Always Visible</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.setOption('wrapBehavioursEnabled', !editor.getOptions().wrapBehavioursEnabled)" id="wrapBehavioursEnabled" />
                  <Label for="wrapBehavioursEnabled">Wrap Behaviours Enabled</label>
              </p>
              <p class="col s12">
                  <input type="checkbox" class="blue_check" onclick="editor.getSession().setUseWrapMode(!editor.getSession().getUseWrapMode());if(editor.getSession().getUseWrapMode()){document.getElementById('wrap_limit').focus();document.getElementById('wrap_limit').onchange();}" id="wrap" />
                  <Label for="wrap">Wrap Mode</label>
              </p>
              <div class="input-field col s12">
                  <input id="wrap_limit" type="number" onchange="editor.setOption('wrap', parseInt(this.value))" min="1" value="80">
                  <label class="active" for="wrap_limit">Wrap Limit</label>
              </div> <a class="waves-effect waves-light btn light-blue" onclick="save_ace_settings()">Save Settings Locally</a>
              <p class="center col s12"> Ace Editor 1.2.8 </p>
          </div>
        </ul>
      </div>
</main>
<input type="hidden" id="fb_currentfile" value="" />
<!-- Scripts -->
<script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.100.1/js/materialize.min.js"></script>
<script type="text/javascript">
    $(document).ready(function () {
        $('select').material_select();
        $('.modal').modal();
        $('ul.tabs').tabs();
        $('.collapsible').collapsible({
          onOpen: function(el) {
            $('#branch_tab').click();
          },
        });
        $('.dropdown-button').dropdown({
            inDuration: 300,
            outDuration: 225,
            constrainWidth: false,
            hover: false,
            gutter: 0,
            belowOrigin: true,
            alignment: 'right',
            stopPropagation: false
        });
        $('.files-collapse').sideNav({
            menuWidth: 320,
            edge: 'left',
            closeOnClick: false,
            draggable: true
        });
        $('.ace_settings-collapse').sideNav({
            menuWidth: 300,
            edge: 'right',
            closeOnClick: true,
            draggable: true
        });
        listdir('.');
    });
</script>
<script type="text/javascript">
    document.addEventListener("DOMContentLoaded", function(){
	     $('.preloader-background').delay(800).fadeOut('slow');

	      $('.preloader-wrapper')
		      .delay(800)
		      .fadeOut('slow');
    });
</script>
<script>
    var modemapping = new Object();
    modemapping['c'] = 'ace/mode/c_cpp';
    modemapping['cpp'] = 'ace/mode/c_cpp';
    modemapping['css'] = 'ace/mode/css';
    modemapping['gitignore'] = 'ace/mode/gitignore';
    modemapping['htm'] = 'ace/mode/html';
    modemapping['html'] = 'ace/mode/html';
    modemapping['js'] = 'ace/mode/javascript';
    modemapping['json'] = 'ace/mode/json';
    modemapping['php'] = 'ace/mode/php';
    modemapping['py'] = 'ace/mode/python';
    modemapping['sh'] = 'ace/mode/sh';
    modemapping['sql'] = 'ace/mode/sql';
    modemapping['txt'] = 'ace/mode/text';
    modemapping['xml'] = 'ace/mode/xml';
    modemapping['yaml'] = 'ace/mode/yaml';
    var separator = '$separator';
    var bootstrap = $bootstrap;
    if (bootstrap.hasOwnProperty("events")) {
        var events = document.getElementById("events");
        for (var i = 0; i < bootstrap.events.length; i++) {
            var option = document.createElement("option");
            option.value = bootstrap.events[i].event;
            option.text = bootstrap.events[i].event;
            events.add(option);
        }
        var events = document.getElementById("events_side");
        for (var i = 0; i < bootstrap.events.length; i++) {
            var option = document.createElement("option");
            option.value = bootstrap.events[i].event;
            option.text = bootstrap.events[i].event;
            events.add(option);
        }
        var entities = document.getElementById("entities");
        for (var i = 0; i < bootstrap.states.length; i++) {
            var option = document.createElement("option");
            option.value = bootstrap.states[i].entity_id;
            option.text = bootstrap.states[i].attributes.friendly_name + ' (' + bootstrap.states[i].entity_id + ')';
            entities.add(option);
        }
        var entities = document.getElementById("entities_side");
        for (var i = 0; i < bootstrap.states.length; i++) {
            var option = document.createElement("option");
            option.value = bootstrap.states[i].entity_id;
            option.text = bootstrap.states[i].attributes.friendly_name + ' (' + bootstrap.states[i].entity_id + ')';
            entities.add(option);
        }
        var services = document.getElementById("services");
        for (var i = 0; i < bootstrap.services.length; i++) {
            for (var k in bootstrap.services[i].services) {
                var option = document.createElement("option");
                option.value = bootstrap.services[i].domain + '.' + k;
                option.text = bootstrap.services[i].domain + '.' + k;
                services.add(option);
            }
        }
        var services = document.getElementById("services_side");
        for (var i = 0; i < bootstrap.services.length; i++) {
            for (var k in bootstrap.services[i].services) {
                var option = document.createElement("option");
                option.value = bootstrap.services[i].domain + '.' + k;
                option.text = bootstrap.services[i].domain + '.' + k;
                services.add(option);
            }
        }

        function sort_select(id) {
            var options = $('#' + id + ' option');
            var arr = options.map(function (_, o) {
                return {
                    t: $(o).text(), v: o.value
                };
            }).get();
            arr.sort(function (o1, o2) {
                var t1 = o1.t.toLowerCase(), t2 = o2.t.toLowerCase();
                return t1 > t2 ? 1 : t1 < t2 ? -1 : 0;
            });
            options.each(function (i, o) {
                o.value = arr[i].v;
                $(o).text(arr[i].t);
            });
        }

        sort_select('events');
        sort_select('events_side');
        sort_select('entities');
        sort_select('entities_side');
        sort_select('services');
        sort_select('services_side');
    }

    function listdir(path) {
        $.get(encodeURI("api/listdir?path=" + path), function(data) {
            renderpath(data);
        });
        document.getElementById("slide-out").scrollTop = 0;
    }

    function renderitem(itemdata, index) {
        var li = document.createElement('li');
        li.classList.add("collection-item", "fbicon_pad", "col", "s12", "no-padding", "white");
        var item = document.createElement('a');
        item.classList.add("waves-effect", "col", "s10", "fbicon_pad");
        var iicon = document.createElement('i');
        iicon.classList.add("material-icons", "fbmenuicon_pad");
        var stats = document.createElement('span');
        date = new Date(itemdata.modified*1000);
        stats.classList.add('stats');
        if (itemdata.type == 'dir') {
            iicon.innerHTML = 'folder';
            item.setAttribute("onclick", "listdir('" + encodeURI(itemdata.fullpath) + "')");
            stats.innerHTML = "Mod.: " + date.toUTCString();
        }
        else {
            nameparts = itemdata.name.split('.');
            extension = nameparts[nameparts.length -1];
            if (['c', 'cpp', 'css', 'htm', 'html', 'js', 'json', 'php', 'py', 'sh', 'sql', 'xml', 'yaml'].indexOf(extension.toLocaleLowerCase()) > +1 ) {
                iicon.classList.add('mdi', 'mdi-file-xml');
            }
            else if (['txt', 'doc', 'docx'].indexOf(extension.toLocaleLowerCase()) > -1 ) {
                iicon.classList.add('mdi', 'mdi-file-document');
            }
            else if (['bmp', 'gif', 'jpg', 'jpeg', 'png', 'tif', 'webp'].indexOf(extension.toLocaleLowerCase()) > -1 ) {
                iicon.classList.add('mdi', 'mdi-file-image');
            }
            else if (['mp3', 'ogg', 'wav'].indexOf(extension) > -1 ) {
                iicon.classList.add('mdi', 'mdi-file-music');
            }
            else if (['avi', 'flv', 'mkv', 'mp4', 'mpg', 'mpeg', 'webm'].indexOf(extension.toLocaleLowerCase()) > -1 ) {
                iicon.classList.add('mdi', 'mdi-file-video');
            }
            else if (['pdf'].indexOf(extension.toLocaleLowerCase()) > -1 ) {
                iicon.classList.add('mdi', 'mdi-file-pdf');
            }
            else {
                iicon.classList.add('mdi', 'mdi-file');
            }
            item.setAttribute("onclick", "loadfile('" + encodeURI(itemdata.fullpath) + "')");
            stats.innerHTML = "Mod.: " + date.toUTCString() + "&nbsp;&nbsp;Size: " + (itemdata.size/1024).toFixed(1) + " KiB";
        }
        item.appendChild(iicon);
        var itext = document.createElement('div');
        itext.innerHTML = itemdata.name;
        itext.classList.add("filename");

        var hasgitadd = false;
        if (itemdata.gitstatus) {
            if (itemdata.gittracked == 'untracked') {
                itext.classList.add('text_darkred');
                hasgitadd = true;
            }
            else {
                if(itemdata.gitstatus == 'unstaged') {
                    itext.classList.add('text_darkred');
                    hasgitadd = true;
                }
                else if (itemdata.gitstatus == 'staged') {
                    itext.classList.add('text_darkgreen');
                }
            }
        }

        item.appendChild(itext);
        item.appendChild(stats);

        var dropdown = document.createElement('ul');
        dropdown.id = 'fb_dropdown_' + index;
        dropdown.classList.add('dropdown-content');
        dropdown.classList.add("z-depth-4");

        // Download button
        var dd_download = document.createElement('li');
        var dd_download_a = document.createElement('a');
        dd_download_a.classList.add("waves-effect", "fb_dd");
        dd_download_a.setAttribute('onclick', "download_file('" + encodeURI(itemdata.fullpath) + "')");
        dd_download_a.innerHTML = "Download";
        dd_download.appendChild(dd_download_a);
        dropdown.appendChild(dd_download);

        // Delete button
        var dd_delete = document.createElement('li');
        dd_delete.classList.add("waves-effect", "fb_dd");
        var dd_delete_a = document.createElement('a');
        dd_delete_a.setAttribute('href', "#modal_delete");
        dd_delete_a.classList.add("modal-trigger");
        dd_delete_a.innerHTML = "Delete";
        dd_delete.appendChild(dd_delete_a);
        dropdown.appendChild(dd_delete);

        if (itemdata.gitstatus) {
            if (hasgitadd) {
                var divider = document.createElement('li');
                divider.classList.add('divider');
                dropdown.appendChild(divider);
                // git add button
                var dd_gitadd = document.createElement('li');
                var dd_gitadd_a = document.createElement('a');
                dd_gitadd_a.classList.add('waves-effect', 'fb_dd', 'modal-trigger');
                dd_gitadd_a.setAttribute('href', "#modal_gitadd");
                dd_gitadd_a.innerHTML = "git add";
                dd_gitadd.appendChild(dd_gitadd_a);
                dropdown.appendChild(dd_gitadd);
            }
        }

        var menubutton = document.createElement('a');
        menubutton.classList.add("fbmenubutton", "waves-effect", "dropdown-button", "col", "s2", "fbicon_pad");
        menubutton.classList.add('waves-effect');
        menubutton.classList.add('dropdown-button');
        menubutton.setAttribute('data-activates', dropdown.id);
        menubutton.setAttribute('data-alignment', 'right');

        var menubuttonicon = document.createElement('i');
        menubutton.classList.add('material-icons');
        menubutton.classList.add("right");
        menubutton.innerHTML = 'more_vert';
        menubutton.setAttribute('onclick', "document.getElementById('fb_currentfile').value='" + encodeURI(itemdata.fullpath) + "';$('span.fb_currentfile').html('" + itemdata.name + "')");
        li.appendChild(item);
        li.appendChild(menubutton);
        li.setAttribute("title", itemdata.name)
        li.appendChild(dropdown);
        return li;
    }

    function renderpath(dirdata) {
        var newbranchbutton = document.getElementById('newbranchbutton');
        newbranchbutton.style.cssText = "display: none !important"
        var fbelements = document.getElementById("fbelements");
        while (fbelements.firstChild) {
            fbelements.removeChild(fbelements.firstChild);
        }
        var fbheader = document.getElementById('fbheader');
        fbheader.innerHTML = dirdata.abspath;
        var branchselector = document.getElementById('branchselector');
        var fbheaderbranch = document.getElementById('fbheaderbranch');
        var branchlist = document.getElementById('branchlist');
        while (branchlist.firstChild) {
            branchlist.removeChild(branchlist.firstChild);
        }
        if (dirdata.activebranch) {
            newbranchbutton.style.display = "inline-block";
            fbheaderbranch.innerHTML = dirdata.activebranch;
            fbheaderbranch.style.display = "inline";
            branchselector.style.display = "block";
            for (var i = 0; i < dirdata.branches.length; i++) {
                var branch = document.createElement('li');
                var link = document.createElement('a');
                link.classList.add("branch_select", "truncate");
                link.innerHTML = dirdata.branches[i];
                link.href = '#';
                link.setAttribute('onclick', 'checkout("' + dirdata.branches[i] + '");collapseAll()')
                branch.appendChild(link);
                if (dirdata.branches[i] == dirdata.activebranch) {
                    link.classList.add("active", "grey", "darken-1");
                }
                else {
                    link.classList.add("grey-text", "text-darken-3", "branch_hover", "waves-effect", "grey", "lighten-4");
                }
                branchlist.appendChild(branch);
            }
        }
        else {
            fbheaderbranch.innerHTML = "";
            fbheaderbranch.style.display = "";
            branchselector.style.display = "none";
        }

        var uplink = document.getElementById('uplink');
        uplink.setAttribute("onclick", "listdir('" + encodeURI(dirdata.parent) + "')")

        for (var i = 0; i < dirdata.content.length; i++) {
            fbelements.appendChild(renderitem(dirdata.content[i], i));
        }
        $(".dropdown-button").dropdown();
    }

    function collapseAll() {
        $(".collapsible-header").removeClass(function() { return "active"; });
        $(".collapsible").collapsible({accordion: true});
        $(".collapsible").collapsible({accordion: false});
    }

    function checkout(){
      $(".collapsible-header").removeClass(function(){
        return "active";
      });
      $(".collapsible").collapsible({accordion: true});
      $(".collapsible").collapsible({accordion: false});
    }

    function loadfile(filepath) {
        if ($('.markdirty.red').length) {
            $('#modal_markdirty').modal('open');
        }
        else {
            $.get("api/file?filename=" + filepath, function(data) {
                fileparts = filepath.split('.');
                extension = fileparts[fileparts.length -1];
                if (modemapping.hasOwnProperty(extension)) {
                    editor.setOption('mode', modemapping[extension]);
                }
                else {
                    editor.setOption('mode', "ace/mode/text");
                }
                editor.getSession().setValue(data, -1);
                document.getElementById('currentfile').value = decodeURI(filepath);
                editor.session.getUndoManager().markClean();
                $('.markdirty').each(function(i, o){o.classList.remove('red');});
                $('.hidesave').css('opacity', 0);
            });
        }
    }

    function check_config() {
        $.get("api/check_config", function (resp) {
            if (resp.length == 0) {
                var $toastContent = $("<div><pre>Configuration seems valid.</pre></div>");
                Materialize.toast($toastContent, 2000);
            }
            else {
                var $toastContent = $("<div><pre>" + resp[0].state + "</pre></div>");
                Materialize.toast($toastContent, 2000);
            }
        });
    }

    function reload_automations() {
        $.get("api/reload_automations", function (resp) {
            var $toastContent = $("<div>Automations reloaded</div>");
            Materialize.toast($toastContent, 2000);
        });
    }

    function reload_groups() {
        $.get("api/reload_groups", function (resp) {
            var $toastContent = $("<div><pre>Groups reloaded</pre></div>");
            Materialize.toast($toastContent, 2000);
        });
    }

    function reload_core() {
        $.get("api/reload_core", function (resp) {
            var $toastContent = $("<div><pre>Core reloaded</pre></div>");
            Materialize.toast($toastContent, 2000);
        });
    }

    function restart() {
        $.get("api/restart", function (resp) {
            if (resp.length == 0) {
                var $toastContent = $("<div><pre>Restarting HASS</pre></div>");
                Materialize.toast($toastContent, 2000);
            }
            else {
                var $toastContent = $("<div><pre>" + resp + "</pre></div>");
                Materialize.toast($toastContent, 2000);
            }
        });
    }

    function save() {
        var filepath = document.getElementById('currentfile').value;
        if (filepath.length > 0) {
            data = new Object();
            data.filename = filepath;
            data.text = editor.getValue()
            $.post("api/save", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                    listdir(document.getElementById('fbheader').innerHTML);
                    $('.markdirty').each(function(i, o){o.classList.remove('red');});
                    $('.hidesave').css('opacity', 0);
                    editor.session.getUndoManager().markClean();
                }
            });
        }
        else {
          Materialize.toast('Error:  Please provide a filename', 5000);
        }
    }

    function save_check() {
        var filepath = document.getElementById('currentfile').value;
        if (filepath.length > 0) {
          $('#modal_save').modal('open');
        }
        else {
            Materialize.toast('Error:  Please provide a filename', 5000);
            $(".pathtip").bind("animationend webkitAnimationEnd oAnimationEnd MSAnimationEnd", function(){
              $(this).removeClass("pathtip_color");
            }).addClass("pathtip_color");
       }
    }

    function download_file(filepath) {
        window.open("/api/download?filename="+encodeURI(filepath));
    }

    function delete_file() {
        var path = document.getElementById('currentfile').value;
        if (path.length > 0) {
            data = new Object();
            data.path= path;
            $.post("api/delete", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                    listdir(document.getElementById('fbheader').innerHTML)
                    document.getElementById('currentfile').value='';
                    editor.setValue('');
                }
            });
        }
    }

    function exec_command() {
        var command = document.getElementById('commandline').value;
        if (command.length > 0) {
            data = new Object();
            data.command = command;
            data.timeout = 15;
            $.post("api/exec_command", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var history = document.getElementById('command_history');
                    history.innerText += resp.message + ': ' + resp.returncode + "\n";
                    if (resp.stdout) {
                        history.innerText += resp.stdout;
                    }
                    if (resp.stderr) {
                        history.innerText += resp.stderr;
                    }
                }
            });
        }
    }

    function delete_element() {
        var path = document.getElementById('fb_currentfile').value;
        if (path.length > 0) {
            data = new Object();
            data.path= path;
            $.post("api/delete", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                    listdir(document.getElementById('fbheader').innerHTML);
                    if (document.getElementById('currentfile').value == path) {
                        document.getElementById('currentfile').value='';
                        editor.setValue('');
                    }
                }
            });
        }
    }

    function gitadd() {
        var path = document.getElementById('fb_currentfile').value;
        if (path.length > 0) {
            data = new Object();
            data.path = path;
            $.post("api/gitadd", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                    listdir(document.getElementById('fbheader').innerHTML);
                }
            });
        }
    }

    function gitinit() {
        var path = document.getElementById("fbheader").innerHTML;
        if (path.length > 0) {
            data = new Object();
            data.path = path;
            $.post("api/init", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                    listdir(document.getElementById('fbheader').innerHTML);
                }
            });
        }
    }

    function commit(message) {
        var path = document.getElementById("fbheader").innerHTML;
        if (path.length > 0) {
            data = new Object();
            data.path = path;
            data.message = message;
            $.post("api/commit", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                    listdir(document.getElementById('fbheader').innerHTML);
                    document.getElementById('commitmessage').value = "";
                }
            });
        }
    }

    function gitpush() {
        var path = document.getElementById("fbheader").innerHTML;
        if (path.length > 0) {
            data = new Object();
            data.path = path;
            $.post("api/push", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                    listdir(document.getElementById('fbheader').innerHTML);
                }
            });
        }
    }

    function checkout(branch) {
        var path = document.getElementById("fbheader").innerHTML;
        if (path.length > 0) {
            data = new Object();
            data.path = path;
            data.branch = branch;
            $.post("api/checkout", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                    listdir(document.getElementById('fbheader').innerHTML);
                }
            });
        }
    }

    function newbranch(branch) {
        var path = document.getElementById("fbheader").innerHTML;
        if (path.length > 0) {
            data = new Object();
            data.path = path;
            data.branch = branch;
            $.post("api/newbranch", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                    listdir(document.getElementById('fbheader').innerHTML);
                }
            });
        }
    }

    function newfolder(foldername) {
        var path = document.getElementById('fbheader').innerHTML;
        if (path.length > 0 && foldername.length > 0) {
            data = new Object();
            data.path = path;
            data.name = foldername;
            $.post("api/newfolder", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                }
                listdir(document.getElementById('fbheader').innerHTML);
                document.getElementById('newfoldername').value = '';
            });
        }
    }

    function newfile(filename) {
        var path = document.getElementById('fbheader').innerHTML;
        if (path.length > 0 && filename.length > 0) {
            data = new Object();
            data.path = path;
            data.name = filename;
            $.post("api/newfile", data).done(function(resp) {
                if (resp.error) {
                    var $toastContent = $("<div><pre>" + resp.message + "\n" + resp.path + "</pre></div>");
                    Materialize.toast($toastContent, 5000);
                }
                else {
                    var $toastContent = $("<div><pre>" + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                }
                listdir(document.getElementById('fbheader').innerHTML);
                document.getElementById('newfilename').value = '';
            });
        }
    }

    function upload() {
        var file_data = $('#uploadfile').prop('files')[0];
        var form_data = new FormData();
        form_data.append('file', file_data);
        form_data.append('path', document.getElementById('fbheader').innerHTML);
        $.ajax({
            url: 'api/upload',
            dataType: 'json',
            cache: false,
            contentType: false,
            processData: false,
            data: form_data,
            type: 'post',
            success: function(resp){
                if (resp.error) {
                    var $toastContent = $("<div><pre>Error: " + resp.message + "</pre></div>");
                    Materialize.toast($toastContent, 2000);
                }
                else {
                    var $toastContent = $("<div><pre>Upload succesful</pre></div>");
                    Materialize.toast($toastContent, 2000);
                    listdir(document.getElementById('fbheader').innerHTML);
                    document.getElementById('uploadform').reset();
                }
            }
        });
    }

</script>
<script>
    ace.require("ace/ext/language_tools");
    var editor = ace.edit("editor");
    editor.on("input", function() {
        if (editor.session.getUndoManager().isClean()) {
            $('.markdirty').each(function(i, o){o.classList.remove('red');});
            $('.hidesave').css('opacity', 0);
        }
        else {
            $('.markdirty').each(function(i, o){o.classList.add('red');});
            $('.hidesave').css('opacity', 1);
        }
    });

    if (localStorage.hasOwnProperty("pochass")) {
        editor.setOptions(JSON.parse(localStorage.pochass));
        editor.setOptions({
            enableBasicAutocompletion: true,
            enableSnippets: true
        })
        editor.$blockScrolling = Infinity;
    }
    else {
        editor.getSession().setMode("ace/mode/yaml");
        editor.setOptions({
            showInvisibles: true,
            useSoftTabs: true,
            displayIndentGuides: true,
            highlightSelectedWord: true,
            enableBasicAutocompletion: true,
            enableSnippets: true
        })
        editor.$blockScrolling = Infinity;
    }

    function apply_settings() {
        var options = editor.getOptions();
        for (var key in options) {
            if (options.hasOwnProperty(key)) {
                var target = document.getElementById(key);
                if (target) {
                    if (typeof(options[key]) == "boolean" && target.type === 'checkbox') {
                        target.checked = options[key];
                        target.setAttribute("checked", options[key]);
                    }
                    else if (typeof(options[key]) == "number" && target.type === 'number') {
                        target.value = options[key];
                    }
                    else if (typeof(options[key]) == "string" && target.tagName == 'SELECT') {
                        target.value = options[key];
                    }
                }
            }
        }
    }

    apply_settings();

    function save_ace_settings() {
        localStorage.pochass = JSON.stringify(editor.getOptions())
        Materialize.toast("Ace Settings Saved", 2000);
    }

    function insert(text) {
        var pos = editor.selection.getCursor();
        var end = editor.session.insert(pos, text);
        editor.selection.setRange({
            start: pos,
            end: end
        });
        editor.focus();
    }

    var foldstatus = true;

    function toggle_fold() {
        if (foldstatus) {
            editor.getSession().foldAll();
        }
        else {
            editor.getSession().unfold();
        }
        foldstatus = !foldstatus;
    }

</script>
</body>
</html>""")

def signal_handler(sig, frame):
    global HTTPD
    LOG.info("Got signal: %s. Shutting down server", str(sig))
    HTTPD.server_close()
    sys.exit(0)

def load_settings(settingsfile):
    global LISTENIP, LISTENPORT, BASEPATH, SSL_CERTIFICATE, SSL_KEY, HASS_API, \
    HASS_API_PASSWORD, CREDENTIALS, ALLOWED_NETWORKS, BANNED_IPS, BANLIMIT, DEV, \
    IGNORE_PATTERN
    try:
        if os.path.isfile(settingsfile):
            with open(settingsfile) as fptr:
                settings = json.loads(fptr.read())
                LISTENIP = settings.get("LISTENIP", LISTENIP)
                LISTENPORT = settings.get("LISTENPORT", LISTENPORT)
                BASEPATH = settings.get("BASEPATH", BASEPATH)
                SSL_CERTIFICATE = settings.get("SSL_CERTIFICATE", SSL_CERTIFICATE)
                SSL_KEY = settings.get("SSL_KEY", SSL_KEY)
                HASS_API = settings.get("HASS_API", HASS_API)
                HASS_API_PASSWORD = settings.get("HASS_API_PASSWORD", HASS_API_PASSWORD)
                CREDENTIALS = settings.get("CREDENTIALS", CREDENTIALS)
                ALLOWED_NETWORKS = settings.get("ALLOWED_NETWORKS", ALLOWED_NETWORKS)
                BANNED_IPS = settings.get("BANNED_IPS", BANNED_IPS)
                BANLIMIT = settings.get("BANLIMIT", BANLIMIT)
                DEV = settings.get("DEV", DEV)
                IGNORE_PATTERN = settings.get("IGNORE_PATTERN", IGNORE_PATTERN)
    except Exception as err:
        LOG.warning(err)
        LOG.warning("Not loading static settings")
    return False

def get_dircontent(path, repo=None):
    dircontent = []
    if repo:
        untracked = [
            "%s%s%s"%(repo.working_dir, os.sep, e) for e in \
            ["%s"%os.sep.join(f.split('/')) for f in repo.untracked_files]
        ]
        staged = {}
        unstaged = {}
        try:
            for element in repo.index.diff("HEAD"):
                staged["%s%s%s" % (repo.working_dir, os.sep, "%s"%os.sep.join(element.b_path.split('/')))] = element.change_type
        except Exception as err:
            LOG.warning("Exception: %s", str(err))
        for element in repo.index.diff(None):
            unstaged["%s%s%s" % (repo.working_dir, os.sep, "%s"%os.sep.join(element.b_path.split('/')))] = element.change_type
    else:
        untracked = []
        staged = {}
        unstaged = {}

    for elem in sorted(os.listdir(path), key=lambda x: x.lower()):
        edata = {}
        edata['name'] = elem
        edata['dir'] = path
        edata['fullpath'] = os.path.abspath(os.path.join(path, elem))
        edata['type'] = 'dir' if os.path.isdir(edata['fullpath']) else 'file'
        try:
            stats = os.stat(os.path.join(path, elem))
            edata['size'] = stats.st_size
            edata['modified'] = stats.st_mtime
            edata['created'] = stats.st_ctime
        except Exception:
            edata['size'] = 0
            edata['modified'] = 0
            edata['created'] = 0
        edata['changetype'] = None
        edata['gitstatus'] = bool(repo)
        edata['gittracked'] = 'untracked' if edata['fullpath'] in untracked else 'tracked'
        if edata['fullpath'] in unstaged:
            edata['gitstatus'] = 'unstaged'
            edata['changetype'] = unstaged.get(edata['name'], None)
        elif edata['fullpath'] in staged:
            edata['gitstatus'] = 'staged'
            edata['changetype'] = staged.get(edata['name'], None)

        hidden = False
        if IGNORE_PATTERN is not None:
            for file_pattern in IGNORE_PATTERN:
                if fnmatch.fnmatch(edata['name'], file_pattern):
                    hidden = True

        if not hidden:
            dircontent.append(edata)

    return dircontent

def get_html():
    if DEV:
        try:
            with open("dev.html") as fptr:
                html = Template(fptr.read())
                return html
        except Exception as err:
            LOG.warning(err)
            LOG.warning("Delivering embedded HTML")
    return INDEX

def check_access(clientip):
    global BANNED_IPS
    if clientip in BANNED_IPS:
        return False
    if not ALLOWED_NETWORKS:
        return True
    for net in ALLOWED_NETWORKS:
        ipobject = ipaddress.ip_address(clientip)
        if ipobject in ipaddress.ip_network(net):
            return True
    BANNED_IPS.append(clientip)
    return False

class RequestHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        LOG.info("%s - %s" % (self.client_address[0], format % args))
        return

    def do_BLOCK(self):
        self.send_response(420)
        self.end_headers()
        self.wfile.write(bytes("Policy not fulfilled", "utf8"))

    def do_GET(self):
        if not check_access(self.client_address[0]):
            self.do_BLOCK()
            return
        req = urlparse(self.path)
        query = parse_qs(req.query)
        self.send_response(200)
        if req.path == '/api/file':
            content = ""
            self.send_header('Content-type', 'text/text')
            self.end_headers()
            filename = query.get('filename', None)
            try:
                if filename:
                    filename = unquote(filename[0]).encode('utf-8')
                    if os.path.isfile(os.path.join(BASEDIR.encode('utf-8'), filename)):
                        with open(os.path.join(BASEDIR.encode('utf-8'), filename)) as fptr:
                            content += fptr.read()
                    else:
                        content = "File not found"
            except Exception as err:
                LOG.warning(err)
                content = str(err)
            self.wfile.write(bytes(content, "utf8"))
            return
        elif req.path == '/api/download':
            content = ""
            filename = query.get('filename', None)
            try:
                if filename:
                    filename = unquote(filename[0]).encode('utf-8')
                    LOG.info(filename)
                    if os.path.isfile(os.path.join(BASEDIR.encode('utf-8'), filename)):
                        with open(os.path.join(BASEDIR.encode('utf-8'), filename), 'rb') as fptr:
                            filecontent = fptr.read()
                        self.send_header('Content-Disposition', 'attachment; filename=%s' % filename.decode('utf-8').split(os.sep)[-1])
                        self.end_headers()
                        self.wfile.write(filecontent)
                        return
                    else:
                        content = "File not found"
            except Exception as err:
                LOG.warning(err)
                content = str(err)
            self.send_header('Content-type', 'text/text')
            self.wfile.write(bytes(content, "utf8"))
            return
        elif req.path == '/api/listdir':
            content = ""
            self.send_header('Content-type', 'text/json')
            self.end_headers()
            dirpath = query.get('path', None)
            try:
                if dirpath:
                    dirpath = unquote(dirpath[0]).encode('utf-8')
                    if os.path.isdir(dirpath):
                        repo = None
                        activebranch = None
                        dirty = False
                        branches = []
                        if REPO:
                            try:
                                repo = REPO(dirpath.decode('utf-8'), search_parent_directories=True)
                                activebranch = repo.active_branch.name
                                dirty = repo.is_dirty()
                                for branch in repo.branches:
                                    branches.append(branch.name)
                            except Exception as err:
                                LOG.debug("Exception (no repo): %s" % str(err))
                        dircontent = get_dircontent(dirpath.decode('utf-8'), repo)
                        filedata = {'content': dircontent,
                                    'abspath': os.path.abspath(dirpath).decode('utf-8'),
                                    'parent': os.path.dirname(os.path.abspath(dirpath)).decode('utf-8'),
                                    'branches': branches,
                                    'activebranch': activebranch,
                                    'dirty': dirty
                                   }
                        self.wfile.write(bytes(json.dumps(filedata), "utf8"))
            except Exception as err:
                LOG.warning(err)
                content = str(err)
                self.wfile.write(bytes(content, "utf8"))
            return
        elif req.path == '/api/abspath':
            content = ""
            self.send_header('Content-type', 'text/text')
            self.end_headers()
            dirpath = query.get('path', None)
            if dirpath:
                dirpath = unquote(dirpath[0]).encode('utf-8')
                LOG.debug(dirpath)
                absp = os.path.abspath(dirpath)
                LOG.debug(absp)
                if os.path.isdir(dirpath):
                    self.wfile.write(os.path.abspath(dirpath))
            return
        elif req.path == '/api/parent':
            content = ""
            self.send_header('Content-type', 'text/text')
            self.end_headers()
            dirpath = query.get('path', None)
            if dirpath:
                dirpath = unquote(dirpath[0]).encode('utf-8')
                LOG.debug(dirpath)
                absp = os.path.abspath(dirpath)
                LOG.debug(absp)
                if os.path.isdir(dirpath):
                    self.wfile.write(os.path.abspath(os.path.dirname(dirpath)))
            return
        elif req.path == '/api/restart':
            LOG.info("/api/restart")
            self.send_header('Content-type', 'text/json')
            self.end_headers()
            res = {"restart": False}
            try:
                headers = {
                    "Content-Type": "application/json"
                }
                if HASS_API_PASSWORD:
                    headers["x-ha-access"] = HASS_API_PASSWORD
                req = urllib.request.Request("%sservices/homeassistant/restart" % HASS_API, headers=headers, method='POST')
                with urllib.request.urlopen(req) as response:
                    res = json.loads(response.read().decode('utf-8'))
                    LOG.debug(res)
            except Exception as err:
                LOG.warning(err)
                res['restart'] = str(err)
            self.wfile.write(bytes(json.dumps(res), "utf8"))
            return
        elif req.path == '/api/check_config':
            LOG.info("/api/check_config")
            self.send_header('Content-type', 'text/json')
            self.end_headers()
            res = {"check_config": False}
            try:
                headers = {
                    "Content-Type": "application/json"
                }
                if HASS_API_PASSWORD:
                    headers["x-ha-access"] = HASS_API_PASSWORD
                req = urllib.request.Request("%sservices/homeassistant/check_config" % HASS_API, headers=headers, method='POST')
                # with urllib.request.urlopen(req) as response:
                #     print(json.loads(response.read().decode('utf-8')))
                #     res['service'] = "called successfully"
            except Exception as err:
                LOG.warning(err)
                res['restart'] = str(err)
            self.wfile.write(bytes(json.dumps(res), "utf8"))
            return
        elif req.path == '/api/reload_automations':
            LOG.info("/api/reload_automations")
            self.send_header('Content-type', 'text/json')
            self.end_headers()
            res = {"reload_automations": False}
            try:
                headers = {
                    "Content-Type": "application/json"
                }
                if HASS_API_PASSWORD:
                    headers["x-ha-access"] = HASS_API_PASSWORD
                req = urllib.request.Request("%sservices/automation/reload" % HASS_API, headers=headers, method='POST')
                with urllib.request.urlopen(req) as response:
                    LOG.debug(json.loads(response.read().decode('utf-8')))
                    res['service'] = "called successfully"
            except Exception as err:
                LOG.warning(err)
                res['restart'] = str(err)
            self.wfile.write(bytes(json.dumps(res), "utf8"))
            return
        elif req.path == '/api/reload_groups':
            LOG.info("/api/reload_groups")
            self.send_header('Content-type', 'text/json')
            self.end_headers()
            res = {"reload_groups": False}
            try:
                headers = {
                    "Content-Type": "application/json"
                }
                if HASS_API_PASSWORD:
                    headers["x-ha-access"] = HASS_API_PASSWORD
                req = urllib.request.Request("%sservices/group/reload" % HASS_API, headers=headers, method='POST')
                with urllib.request.urlopen(req) as response:
                    LOG.debug(json.loads(response.read().decode('utf-8')))
                    res['service'] = "called successfully"
            except Exception as err:
                LOG.warning(err)
                res['restart'] = str(err)
            self.wfile.write(bytes(json.dumps(res), "utf8"))
            return
        elif req.path == '/api/reload_core':
            LOG.info("/api/reload_core")
            self.send_header('Content-type', 'text/json')
            self.end_headers()
            res = {"reload_core": False}
            try:
                headers = {
                    "Content-Type": "application/json"
                }
                if HASS_API_PASSWORD:
                    headers["x-ha-access"] = HASS_API_PASSWORD
                req = urllib.request.Request("%sservices/homeassistant/reload_core_config" % HASS_API, headers=headers, method='POST')
                with urllib.request.urlopen(req) as response:
                    LOG.debug(json.loads(response.read().decode('utf-8')))
                    res['service'] = "called successfully"
            except Exception as err:
                LOG.warning(err)
                res['restart'] = str(err)
            self.wfile.write(bytes(json.dumps(res), "utf8"))
            return
        elif req.path == '/':
            self.send_header('Content-type', 'text/html')
            self.end_headers()

            boot = "{}"
            try:
                headers = {
                    "Content-Type": "application/json"
                }
                if HASS_API_PASSWORD:
                    headers["x-ha-access"] = HASS_API_PASSWORD
                req = urllib.request.Request("%sbootstrap" % HASS_API, headers=headers, method='GET')
                with urllib.request.urlopen(req) as response:
                    boot = response.read().decode('utf-8')

            except Exception as err:
                LOG.warning("Exception getting bootstrap")
                LOG.warning(err)

            color = "green"
            try:
                response = urllib.request.urlopen(RELEASEURL)
                latest = json.loads(response.read().decode('utf-8'))['tag_name']
                if VERSION != latest:
                    color = "red"
            except Exception as err:
                LOG.warning("Exception getting release")
                LOG.warning(err)
            html = get_html().safe_substitute(bootstrap=boot,
                                              current=VERSION,
                                              versionclass=color,
                                              separator="\%s" % os.sep if os.sep == "\\" else os.sep)
            self.wfile.write(bytes(html, "utf8"))
            return
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(bytes("File not found", "utf8"))

    def do_POST(self):
        if not check_access(self.client_address[0]):
            self.do_BLOCK()
            return
        req = urlparse(self.path)

        response = {
            "error": True,
            "message": "Generic failure"
        }

        length = int(self.headers['content-length'])
        if req.path == '/api/save':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'filename' in postvars.keys() and 'text' in postvars.keys():
                if postvars['filename'] and postvars['text']:
                    try:
                        filename = unquote(postvars['filename'][0])
                        response['file'] = filename
                        with open(filename, 'wb') as fptr:
                            fptr.write(bytes(postvars['text'][0], "utf-8"))
                        self.send_response(200)
                        self.send_header('Content-type', 'text/json')
                        self.end_headers()
                        response['error'] = False
                        response['message'] = "File saved successfully"
                        self.wfile.write(bytes(json.dumps(response), "utf8"))
                        return
                    except Exception as err:
                        response['message'] = "%s" % (str(err))
                        LOG.warning(err)
            else:
                response['message'] = "Missing filename or text"
        elif req.path == '/api/upload':
            if length > 104857600: #100 MB for now
                read = 0
                while read < length:
                    read += len(self.rfile.read(min(66556, length - read)))
                self.send_response(200)
                self.send_header('Content-type', 'text/json')
                self.end_headers()
                response['error'] = True
                response['message'] = "File too big: %i" % read
                self.wfile.write(bytes(json.dumps(response), "utf8"))
                return
            else:
                form = cgi.FieldStorage(
                    fp=self.rfile,
                    headers=self.headers,
                    environ={'REQUEST_METHOD': 'POST',
                             'CONTENT_TYPE': self.headers['Content-Type'],
                            })
                filename = form['file'].filename
                filepath = form['path'].file.read()
                data = form['file'].file.read()
                open("%s%s%s" % (filepath, os.sep, filename), "wb").write(data)
                self.send_response(200)
                self.send_header('Content-type', 'text/json')
                self.end_headers()
                response['error'] = False
                response['message'] = "Upload successful"
                self.wfile.write(bytes(json.dumps(response), "utf8"))
                return
        elif req.path == '/api/delete':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'path' in postvars.keys():
                if postvars['path']:
                    try:
                        delpath = unquote(postvars['path'][0])
                        response['path'] = delpath
                        try:
                            if os.path.isdir(delpath):
                                os.rmdir(delpath)
                            else:
                                os.unlink(delpath)
                            self.send_response(200)
                            self.send_header('Content-type', 'text/json')
                            self.end_headers()
                            response['error'] = False
                            response['message'] = "Deletetion successful"
                            self.wfile.write(bytes(json.dumps(response), "utf8"))
                            return
                        except Exception as err:
                            LOG.warning(err)
                            response['error'] = True
                            response['message'] = str(err)

                    except Exception as err:
                        response['message'] = "%s" % (str(err))
                        LOG.warning(err)
            else:
                response['message'] = "Missing filename or text"
        elif req.path == '/api/exec_command':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'command' in postvars.keys():
                if postvars['command']:
                    try:
                        command = shlex.split(postvars['command'][0])
                        timeout = 15
                        if 'timeout' in postvars.keys():
                            if postvars['timeout']:
                                timeout = int(postvars['timeout'][0])
                        try:
                            proc = subprocess.Popen(
                                command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                            stdout, stderr = proc.communicate(timeout=timeout)
                            self.send_response(200)
                            self.send_header('Content-type', 'text/json')
                            self.end_headers()
                            response['error'] = False
                            response['message'] = "Command executed: %s" % postvars['command'][0]
                            response['returncode'] = proc.returncode
                            try:
                                response['stdout'] = stdout.decode(sys.getdefaultencoding())
                            except Exception as err:
                                LOG.warning(err)
                                response['stdout'] = stdout.decode("utf-8", errors="replace")
                            try:
                                response['stderr'] = stderr.decode(sys.getdefaultencoding())
                            except Exception as err:
                                LOG.warning(err)
                                response['stderr'] = stderr.decode("utf-8", errors="replace")
                            self.wfile.write(bytes(json.dumps(response), "utf8"))
                            return
                        except Exception as err:
                            LOG.warning(err)
                            response['error'] = True
                            response['message'] = str(err)

                    except Exception as err:
                        response['message'] = "%s" % (str(err))
                        LOG.warning(err)
            else:
                response['message'] = "Missing command"
        elif req.path == '/api/gitadd':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'path' in postvars.keys():
                if postvars['path']:
                    try:
                        addpath = unquote(postvars['path'][0])
                        repo = REPO(addpath, search_parent_directories=True)
                        filepath = "/".join(addpath.split(os.sep)[len(repo.working_dir.split(os.sep)):])
                        response['path'] = filepath
                        try:
                            repo.index.add([filepath])
                            response['error'] = False
                            response['message'] = "Added file to index"
                            self.send_response(200)
                            self.send_header('Content-type', 'text/json')
                            self.end_headers()
                            self.wfile.write(bytes(json.dumps(response), "utf8"))
                            return
                        except Exception as err:
                            LOG.warning(err)
                            response['error'] = True
                            response['message'] = str(err)

                    except Exception as err:
                        response['message'] = "%s" % (str(err))
                        LOG.warning(err)
            else:
                response['message'] = "Missing filename"
        elif req.path == '/api/commit':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'path' in postvars.keys() and 'message' in postvars.keys():
                if postvars['path'] and postvars['message']:
                    try:
                        commitpath = unquote(postvars['path'][0])
                        response['path'] = commitpath
                        message = unquote(postvars['message'][0])
                        repo = REPO(commitpath, search_parent_directories=True)
                        try:
                            repo.index.commit(message)
                            response['error'] = False
                            response['message'] = "Changes commited"
                            self.send_response(200)
                            self.send_header('Content-type', 'text/json')
                            self.end_headers()
                            self.wfile.write(bytes(json.dumps(response), "utf8"))
                            return
                        except Exception as err:
                            response['error'] = True
                            response['message'] = str(err)
                            LOG.debug(response)

                    except Exception as err:
                        response['message'] = "Not a git repository: %s" % (str(err))
                        LOG.warning("Exception (no repo): %s" % str(err))
            else:
                response['message'] = "Missing path"
        elif req.path == '/api/checkout':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'path' in postvars.keys() and 'branch' in postvars.keys():
                if postvars['path'] and postvars['branch']:
                    try:
                        branchpath = unquote(postvars['path'][0])
                        response['path'] = branchpath
                        branch = unquote(postvars['branch'][0])
                        repo = REPO(branchpath, search_parent_directories=True)
                        try:
                            head = [h for h in repo.heads if h.name == branch][0]
                            head.checkout()
                            response['error'] = False
                            response['message'] = "Checked out %s" % branch
                            self.send_response(200)
                            self.send_header('Content-type', 'text/json')
                            self.end_headers()
                            self.wfile.write(bytes(json.dumps(response), "utf8"))
                            return
                        except Exception as err:
                            response['error'] = True
                            response['message'] = str(err)
                            LOG.warning(response)

                    except Exception as err:
                        response['message'] = "Not a git repository: %s" % (str(err))
                        LOG.warning("Exception (no repo): %s" % str(err))
            else:
                response['message'] = "Missing path or branch"
        elif req.path == '/api/newbranch':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'path' in postvars.keys() and 'branch' in postvars.keys():
                if postvars['path'] and postvars['branch']:
                    try:
                        branchpath = unquote(postvars['path'][0])
                        response['path'] = branchpath
                        branch = unquote(postvars['branch'][0])
                        repo = REPO(branchpath, search_parent_directories=True)
                        try:
                            repo.git.checkout("HEAD", b=branch)
                            response['error'] = False
                            response['message'] = "Created and checked out %s" % branch
                            self.send_response(200)
                            self.send_header('Content-type', 'text/json')
                            self.end_headers()
                            self.wfile.write(bytes(json.dumps(response), "utf8"))
                            return
                        except Exception as err:
                            response['error'] = True
                            response['message'] = str(err)
                            LOG.warning(response)

                    except Exception as err:
                        response['message'] = "Not a git repository: %s" % (str(err))
                        LOG.warning("Exception (no repo): %s" % str(err))
            else:
                response['message'] = "Missing path or branch"
        elif req.path == '/api/init':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'path' in postvars.keys():
                if postvars['path']:
                    try:
                        repopath = unquote(postvars['path'][0])
                        response['path'] = repopath
                        try:
                            repo = REPO.init(repopath)
                            response['error'] = False
                            response['message'] = "Initialized repository in %s" % repopath
                            self.send_response(200)
                            self.send_header('Content-type', 'text/json')
                            self.end_headers()
                            self.wfile.write(bytes(json.dumps(response), "utf8"))
                            return
                        except Exception as err:
                            response['error'] = True
                            response['message'] = str(err)
                            LOG.warning(response)

                    except Exception as err:
                        response['message'] = "Not a git repository: %s" % (str(err))
                        LOG.warning("Exception (no repo): %s" % str(err))
            else:
                response['message'] = "Missing path or branch"
        elif req.path == '/api/push':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'path' in postvars.keys():
                if postvars['path']:
                    try:
                        repopath = unquote(postvars['path'][0])
                        response['path'] = repopath
                        try:
                            repo = REPO(repopath)
                            urls = []
                            if repo.remotes:
                                for url in repo.remotes.origin.urls:
                                    urls.append(url)
                            if not urls:
                                response['error'] = True
                                response['message'] = "No remotes configured for %s" % repopath
                            else:
                                repo.remotes.origin.push()
                                response['error'] = False
                                response['message'] = "Pushed to %s" % urls[0]
                            self.send_response(200)
                            self.send_header('Content-type', 'text/json')
                            self.end_headers()
                            self.wfile.write(bytes(json.dumps(response), "utf8"))
                            return
                        except Exception as err:
                            response['error'] = True
                            response['message'] = str(err)
                            LOG.warning(response)

                    except Exception as err:
                        response['message'] = "Not a git repository: %s" % (str(err))
                        LOG.warning("Exception (no repo): %s" % str(err))
            else:
                response['message'] = "Missing path or branch"
        elif req.path == '/api/newfolder':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'path' in postvars.keys() and 'name' in postvars.keys():
                if postvars['path'] and postvars['name']:
                    try:
                        basepath = unquote(postvars['path'][0])
                        name = unquote(postvars['name'][0])
                        response['path'] = os.path.join(basepath, name)
                        try:
                            os.makedirs(response['path'])
                            self.send_response(200)
                            self.send_header('Content-type', 'text/json')
                            self.end_headers()
                            response['error'] = False
                            response['message'] = "Folder created"
                            self.wfile.write(bytes(json.dumps(response), "utf8"))
                            return
                        except Exception as err:
                            LOG.warning(err)
                            response['error'] = True
                            response['message'] = str(err)
                    except Exception as err:
                        response['message'] = "%s" % (str(err))
                        LOG.warning(err)
        elif req.path == '/api/newfile':
            try:
                postvars = parse_qs(self.rfile.read(length).decode('utf-8'), keep_blank_values=1)
            except Exception as err:
                LOG.warning(err)
                response['message'] = "%s" % (str(err))
                postvars = {}
            if 'path' in postvars.keys() and 'name' in postvars.keys():
                if postvars['path'] and postvars['name']:
                    try:
                        basepath = unquote(postvars['path'][0])
                        name = unquote(postvars['name'][0])
                        response['path'] = os.path.join(basepath, name)
                        try:
                            with open(response['path'], 'w') as fptr:
                                fptr.write("")
                            self.send_response(200)
                            self.send_header('Content-type', 'text/json')
                            self.end_headers()
                            response['error'] = False
                            response['message'] = "File created"
                            self.wfile.write(bytes(json.dumps(response), "utf8"))
                            return
                        except Exception as err:
                            LOG.warning(err)
                            response['error'] = True
                            response['message'] = str(err)
                    except Exception as err:
                        response['message'] = "%s" % (str(err))
                        LOG.warning(err)
            else:
                response['message'] = "Missing filename or text"
        else:
            response['message'] = "Invalid method"
        self.send_response(200)
        self.send_header('Content-type', 'text/json')
        self.end_headers()
        self.wfile.write(bytes(json.dumps(response), "utf8"))
        return

class AuthHandler(RequestHandler):
    def do_AUTHHEAD(self):
        LOG.info("Requesting authorization")
        self.send_response(401)
        self.send_header('WWW-Authenticate', 'Basic realm=\"HASS-Configurator\"')
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        global CREDENTIALS
        authorization = self.headers.get('Authorization', None)
        if authorization is None:
            self.do_AUTHHEAD()
            self.wfile.write(bytes('no auth header received', 'utf-8'))
            pass
        elif authorization == 'Basic %s' % CREDENTIALS.decode('utf-8'):
            if BANLIMIT:
                FAIL2BAN_IPS.pop(self.client_address[0], None)
            super().do_GET()
            pass
        else:
            if BANLIMIT:
                bancounter = FAIL2BAN_IPS.get(self.client_address[0], 1)
                if bancounter >= BANLIMIT:
                    LOG.warning("Blocking access from %s" % self.client_address[0])
                    self.do_BLOCK()
                    return
                else:
                    FAIL2BAN_IPS[self.client_address[0]] = bancounter + 1
            self.do_AUTHHEAD()
            self.wfile.write(bytes('Authentication required', 'utf-8'))
            pass

    def do_POST(self):
        global CREDENTIALS
        authorization = self.headers.get('Authorization', None)
        if authorization is None:
            self.do_AUTHHEAD()
            self.wfile.write(bytes('no auth header received', 'utf-8'))
            pass
        elif authorization == 'Basic %s' % CREDENTIALS.decode('utf-8'):
            if BANLIMIT:
                FAIL2BAN_IPS.pop(self.client_address[0], None)
            super().do_POST()
            pass
        else:
            if BANLIMIT:
                bancounter = FAIL2BAN_IPS.get(self.client_address[0], 1)
                if bancounter >= BANLIMIT:
                    LOG.warning("Blocking access from %s" % self.client_address[0])
                    self.do_BLOCK()
                    return
                else:
                    FAIL2BAN_IPS[self.client_address[0]] = bancounter + 1
            self.do_AUTHHEAD()
            self.wfile.write(bytes('Authentication required', 'utf-8'))
            pass

def main(args):
    global HTTPD, CREDENTIALS
    if args:
        load_settings(args[0])
    LOG.info("Starting server")
    server_address = (LISTENIP, LISTENPORT)
    if CREDENTIALS:
        CREDENTIALS = base64.b64encode(bytes(CREDENTIALS, "utf-8"))
        Handler = AuthHandler
    else:
        Handler = RequestHandler
    if not SSL_CERTIFICATE:
        HTTPD = HTTPServer(server_address, Handler)
    else:
        HTTPD = socketserver.TCPServer(server_address, Handler)
        HTTPD.socket = ssl.wrap_socket(HTTPD.socket,
                                       certfile=SSL_CERTIFICATE,
                                       keyfile=SSL_KEY,
                                       server_side=True)
    LOG.info('Listening on: %s://%s:%i' % ('https' if SSL_CERTIFICATE else 'http',
                                           LISTENIP,
                                           LISTENPORT))
    if BASEPATH:
        os.chdir(BASEPATH)
    HTTPD.serve_forever()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal_handler)
    main(sys.argv[1:])
