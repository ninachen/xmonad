import XMonad
import XMonad.Actions.PhysicalScreens (viewScreen, sendToScreen, onNextNeighbour)
import XMonad.Actions.SpawnOn (manageSpawn, spawnHere, spawnOn)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks (avoidStruts)
import XMonad.Hooks.ManageHelpers (doCenterFloat)
import XMonad.Layout.PerWorkspace (onWorkspaces)
import XMonad.Layout.Reflect (reflectHoriz)
import XMonad.Layout.Tabbed
import XMonad.Util.EZConfig (additionalKeys, additionalKeysP, removeKeysP)
import XMonad.Util.Run (spawnPipe)

-- multimedia keys
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioRaiseVolume)

-- UTF8 strings
import System.IO

import qualified XMonad.StackSet as W

------------------
-- Applications --
------------------
myTerminal = "urxvt"
myScreenLock = "gnome-screensaver-command -l"
myPrintScreen = "scrot -e 'mv $f ~/screenshots/ && kolourpaint ~/screenshots/$f'"
dartEditor = "env UBUNTU_MENUPROXY= ~/dart/DartEditor"
dartium = "~/dart/chromium/chrome"

webMail = "google-chrome --new-window https://mail.google.com/mail/ca/u/0/ https://www.google.com/calendar/"
webMusic = "google-chrome --new-window https://play.google.com/music/listen/"

------------------
--    Colors    --
------------------
colorBlack = "#000000"
colorLightBlue = "#1E90FF"

cActiveBackground = "#444444"
cSecondaryBackground = "#333333"
cInactiveBackground = "#222222"
cActiveText = "#bfbfbf"
cSecondaryText = "#999999"
cInactiveText = "#666666"

------------------
--  Workspaces  --
------------------
wsWeb = "★"
wsDev = "⌨"
wsMail = "✉"
wsMusic = "♫"
ws1 = "‽"
ws2 = "♚"
ws3 = "☯"
ws4 = "❇"

myWorkspaces = [wsWeb, wsDev, wsMail, wsMusic, ws1, ws2, ws3, ws4]

------------------
--     Keys     --
------------------
-- Set mod to windows key
myModMask = mod4Mask
altMask = mod1Mask

-- Non-numeric num pad keys, sorted by number
numPadKeys = [ xK_KP_Insert, xK_KP_Delete                 -- 0, <.>
             , xK_KP_End,    xK_KP_Down,  xK_KP_Page_Down -- 1, 2, 3
             , xK_KP_Left,   xK_KP_Begin, xK_KP_Right]    -- 4, 5, 6

myKeys =
    -- use numpad to switch workspaces
    [((mask, key), windows $ fn i)
      | (i, key) <- zip myWorkspaces numPadKeys
      , (fn, mask) <- [(W.view, 0), (W.shift, shiftMask)]
    ]
    ++
    -- use numpad "/" and "*" to switch physical screens
    [((mask, key), fn screens)
      | (screens, key) <- zip [0..] [xK_KP_Divide, xK_KP_Multiply]
      , (fn, mask) <- [(viewScreen, 0), (sendToScreen, shiftMask)]
    ]
    ++
    [ -- multimedia keys
      ((0, xF86XK_AudioLowerVolume), spawn "amixer set Master 2-")
    , ((0, xF86XK_AudioRaiseVolume), spawn "amixer set Master 2+")

    -- lock screen (numpad -)
    , ((0, xK_KP_Subtract), spawn myScreenLock)

    -- create terminal (numpad +)
    , ((0, xK_KP_Add), spawn myTerminal)

    -- print screen
    , ((0, xK_Print), spawn myPrintScreen)
    , ((altMask, xK_Print), spawn (myPrintScreen ++ " --focused"))
    ]

myKeysP =
    -- create terminal (default ubuntu)
    [ ("M1-C-t", spawn myTerminal)

    -- alt-tab
    , ("M1-<Tab>", windows W.focusDown)
    , ("M1-S-<Tab>", windows W.focusUp)

    -- cycle between monitors
    , ("M1-`", onNextNeighbour W.view)

    -- lock screen (default gnome)
    , ("M1-C-l", spawn myScreenLock)

    -- open programs
    , ("M-x d 1", spawnOn wsDev (dartEditor ++ " -data ~/dart/workspaces/dart1"))
    , ("M-x d 2", spawnOn wsDev (dartEditor ++ " -data ~/dart/workspaces/dart2"))
    , ("M-x d 3", spawnOn wsDev (dartEditor ++ " -data ~/dart/workspaces/dart3"))
    , ("M-x e", spawnOn wsDev "eclipse44")
    , ("M-x f", spawnHere "firefox")
    , ("M-x k", spawnHere "kolourpaint")

    --  open custom chrome windows
    , ("M-x c", spawnHere dartium)
    , ("M-x g", spawnHere "google-chrome")
    , ("M-x m", spawnOn wsMail webMail)
    , ("M-x u", spawnOn wsMusic webMusic)

    -- shutdown
    , ("M-x p", spawnHere "/usr/lib/indicator-session/gtk-logout-helper --shutdown")
    ]

myRemoveKeysP =
    -- default logout
    [ ("M-S-q") ]

------------------
-- Startup Hook --
------------------
myStartupHook = do
    spawn "sh ~/.xmonad/.fehbg &"
    spawn "/usr/bin/xcompmgr"
    spawnOn wsWeb "google-chrome --new-window --restore-last-session"
    spawnOn wsMail webMail
    spawnOn wsMail myTerminal
    spawnOn wsMusic webMusic
    spawnOn wsWeb myTerminal
    spawnOn wsWeb myTerminal
    spawnOn ws1 myTerminal
    spawnOn ws1 myTerminal
    spawnOn ws1 myTerminal
    spawnOn ws2 myTerminal

------------------
-- Layout Hook  --
------------------
-- Default tiling algorithm partitions the screen into two panes.
-- Tall [defaultNumMaster] [delta] [defaultMasterProportion]
equalTiled = Tall 1 0.03 0.5  -- split the screen evenly
tiled = Tall 1 0.03 0.7       -- let the master take up most of the screen

-- custom tab layout theme
myTabConfig = defaultTheme {
      fontName = "xft:Dejavu Sans:pixelsize=12:bold"
    , activeColor = cActiveBackground
    , activeBorderColor = cActiveBackground
    , activeTextColor = cActiveText
    , inactiveColor = cInactiveBackground
    , inactiveBorderColor = cInactiveBackground
    , inactiveTextColor = cInactiveText
}

myLayoutHook = onWorkspaces [wsWeb, ws2] (rightMasterLayout tiled) $
               onWorkspaces [wsDev] tabbedLayout $
               onWorkspaces [wsMail] (leftMasterLayout tiled) $
               onWorkspaces [ws1] (rightMasterLayout equalTiled) $
               leftMasterLayout equalTiled -- layout for other workspaces
    where
        leftMasterLayout myLayout = myLayout ||| (reflectHoriz $ myLayout) ||| Full
        rightMasterLayout myLayout = (reflectHoriz $ myLayout) ||| myLayout ||| Full
        tabbedLayout = tabbed shrinkText myTabConfig ||| equalTiled

------------------
-- Manage Hook  --
------------------
myManageHook = composeAll
    [ className =? "Chrome" --> doShift ws2  -- Dartium
    , className =? "DartEditor" --> doCenterFloat
    , className =? "Dart Editor" --> doShift wsDev
    , className =? "eclipse" --> doCenterFloat
    , className =? "Eclipse" --> doShift wsDev
    , className =? "Gimp" --> doFloat
    , className =? "Java" --> doCenterFloat
    , className =? "Keepass" --> doCenterFloat
    , className =? "Kolourpaint" --> doShift ws3
    , className =? "Meld" --> doCenterFloat
    , className =? "Tkdiff.tcl" --> doCenterFloat
    , manageSpawn
    ]

------------------
--   Log Hook   --
------------------
myLogHook h = dynamicLogWithPP xmobarPP
    { ppCurrent = xmobarColor cActiveText cActiveBackground . pad -- current workspace
    , ppVisible = xmobarColor cSecondaryText cSecondaryBackground . pad -- workspace on 2nd monitor
    , ppHidden = xmobarColor cInactiveText "" . pad -- other workspaces
    , ppSep = "   " -- separator (between workspaces and active window)
    , ppOutput = hPutStrLn h -- active workspaces
    , ppTitle = xmobarColor colorLightBlue "" . shorten 100 -- active window title
    , ppLayout = const "" -- disable the layout info on xmobar
    }

------------------
--     Main     --
------------------
main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ ewmh defaultConfig
        { modMask = myModMask
        , terminal = myTerminal
        , workspaces = myWorkspaces
        , startupHook = myStartupHook
        , layoutHook =  avoidStruts $ myLayoutHook
        , manageHook = myManageHook <+> manageHook defaultConfig
        , logHook = myLogHook xmproc
        , handleEventHook = handleEventHook defaultConfig <+> fullscreenEventHook

        -- custom window colors
        , borderWidth = 1
        , normalBorderColor = colorBlack
        , focusedBorderColor = colorLightBlue
        }

        -- custom keys
        `additionalKeys` myKeys
        `additionalKeysP` myKeysP
        `removeKeysP` myRemoveKeysP
