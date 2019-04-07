import XMonad
import XMonad.Config (def)
import XMonad.Actions.CopyWindow (copy)
import XMonad.Hooks.DynamicLog
  ( dynamicLogWithPP
  , ppOutput
  , ppTitle
  , shorten
  , xmobarColor
  , xmobarPP
  )
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks (avoidStruts, docks)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.EZConfig (additionalKeys)
import System.IO (hPutStrLn)

import qualified Data.Map as Map
import qualified XMonad.StackSet as StackSet

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

-- refuse the handleEventHook.
-- windows should not be able to steal focus.
myEwmh :: XConfig a -> XConfig a
myEwmh c = let c' = ewmh c in c { startupHook = startupHook c', logHook = logHook c' }

main = do
    xmproc <- spawnPipe "/usr/bin/xmobar $HOME/.xmonad/xmobar.hs"
    xmonad $ myEwmh $ docks def
        { modMask = mod4Mask
        , terminal = "urxvt"
        , keys = newKeys
        , layoutHook = avoidStruts $ layoutHook def
        , logHook = dynamicLogWithPP $ xmobarPP
            { ppOutput = hPutStrLn xmproc
            , ppTitle = xmobarColor "#00ff00" "" . shorten 100
            }
        }

myKeys x@XConfig{modMask = modm} = Map.fromList $
    [ ((modm .|. shiftMask, xK_Return), windows StackSet.swapMaster)
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
        , (f, m) <- [(StackSet.greedyView, 0), (StackSet.shift, shiftMask), (copy, controlMask)]
    ]

newKeys x = Map.union (myKeys x) (keys def x)
