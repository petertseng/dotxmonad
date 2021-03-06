Config { font = "xft:Droid Sans Fallback-9:Bold"
       , bgColor = "black"
       , fgColor = "grey"
       , position = TopW L 95
       , lowerOnStart = True
       , commands = [ Run Cpu ["-L", "3", "-H", "50", "--normal", "green", "--high", "red"] 10
                    , Run Memory ["-t","Mem: <usedratio>%"] 10
                    , Run Swap [] 10
                    , Run Uptime [] 10
                    , Run Date "%a %Y-%m-%d %H:%M:%S %z" "date" 10
                    , Run Com "date" ["-u", "+%m-%d %H:%M:%S %z"] "utc" 10
                    , Run Com "env" ["TZ=Asia/Seoul", "date", "+%m-%d %H:%M:%S %z"] "kor" 10
                    , Run StdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% }{ %cpu% %memory% %swap% | %uptime% | <fc=#ee9a00>%date% | %utc% | %kor%</fc>"
       }
