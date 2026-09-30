#Requires AutoHotkey v2.0 
#SingleInstance Force

; expects argument 1 (first) to be an SC string to send
; adds a 2s delay to give time to use the sc

DELAY := 2000

send_sc() {
    global done
    SendInput("{SC" A_Args[1] "}")
    done := true
}

SetTimer(
    send_sc,
    -DELAY
)

done := false
while (!done) {
    sleep(10)
}