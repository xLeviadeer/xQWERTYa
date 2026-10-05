; technically any VK can be used that wouldn't normally be pressed because the input will be eaten by my rebind anyway

#Requires AutoHotkey v2.0 
#SingleInstance Force

; --- HELPERS ---

; hex conversion helper
DecToHex(num) => Format("{:X}", num)
HexToDec(hex) => ("0x" hex) + 0

; parse int function
ParseInt(str) => Floor(str)

; usable vks
USABLE_VKS := [
    "0E",
    "0F",

    "3A",
    "3B",
    "3C",
    "3D",
    "3E",
    "3F",
    "40",
    
    "97",
    "98",
    "99",
    "9A",
    "9B",
    "9C",
    "9D",
    "9E",
    "9F",

    "E8"
]

; --- MAIN ---

; check arg length
if (A_Args.Length != 1) {
    throw ValueError("there must be 1 argument")
} 

; try to parse args
argNumber := ParseInt(A_Args[1])
if !(argNumber is Integer) {
    throw ValueError("argument must be an integer")
}

if (
    (argNumber < 0)
    || (argNumber > USABLE_VKS.Length)
) {
    throw ValueError("integer must be between 0 and " USABLE_VKS.Length " but was '" argNumber "'")
}

; send the respective VK
SendInput("{VK" USABLE_VKS[argNumber + 1] "}")
