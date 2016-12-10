import XMonad
import XMonad.Actions.CopyWindow (copy)
import XMonad.Hooks.DynamicLog
  ( dynamicLogWithPP
  , ppOutput
  , ppTitle
  , shorten
  , xmobarColor
  , xmobarPP
  )
import XMonad.Hooks.ManageDocks (avoidStruts, manageDocks)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig (additionalKeys)
import System.Environment (getEnv)
import System.IO (hPutStrLn)

import qualified Data.Map as M
import qualified XMonad.StackSet as W

-- DMenu settings...
selected   = "'#0000cc'"
background = "'#cccccc'"
foreground = "'#000000'"

myDmenuTitleBar =
    "exec `dmenu_run \
        \ -p 'Run:' -i \
        \ -nb " ++ background ++ "\
        \ -nf " ++ foreground ++ "\
        \ -sb " ++ selected   ++ "\
    \`"

main = do
    home <- getEnv "HOME"
    xmproc <- spawnPipe $ "/usr/bin/xmobar " ++ home ++"/.xmonad/xmobar.hs"
    xmonad $ defaultConfig
        { manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , logHook = dynamicLogWithPP $ xmobarPP
            { ppOutput = hPutStrLn xmproc
            , ppTitle = xmobarColor "green" "" . shorten 100
            }
        , modMask = mod4Mask
        , terminal = "urxvt"
        , keys = newKeys
        }

myKeys x@XConfig{modMask = modm} = M.fromList $
    [ ((modm .|. shiftMask, xK_Return), windows W.swapMaster)
    , ((modm,               xK_Return), spawn $ terminal x)
    , ((modm,               xK_e     ), spawn "urxvt -e ranger")
    , ((modm,               xK_p     ), spawn myDmenuTitleBar)
    ]
    ++
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    -- mod-control-[1..9], Copy client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (workspaces x) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask), (copy, controlMask)]
    ]

newKeys x = M.union (myKeys x) (keys defaultConfig x)
