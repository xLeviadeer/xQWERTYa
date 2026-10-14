#Requires AutoHotkey v2.0

#Include Clipboard.ahk
#Include Utils.ahk

class Capitalization {

    ; capitalization levels
    class Level {
        static AllLower => 0
        static SomeCaps => 0 ; functionally the same as all lower
        static SentenceCaps => 1
        static WordCaps => 2
        static AllCaps => 3
        static Clamp(num) => Utils.Clamp(num, Capitalization.Level.AllLower, Capitalization.Level.AllCaps)
    }

    ; sentence and word delimiters
    static _WORD_DELIM => " "
    static _SENT_DELIM => [". ", "· ", "╎ ", "! ", "? "]
    static _SENT_DELIM_LEN => 2

    ; run a method for every split of a string
    ; method is expected to be a method which takes the substring as an input
    static _ForSplit(str, delimiterȿ, method) {
        for split_str in StrSplit(str, delimiterȿ) {
            method.Call(split_str)
        }
    }

    ; parse a capitalization level from a string
    static Parse(str) {
        ; get string excluding any non-letters
        str_letters := ""
        for char in StrSplit(str) {
            if (IsAlpha(char)) {
                str_letters .= char
            }
        }

        ; check if the whole string is capitals
        if (IsUpper(str_letters)) {
            return Capitalization.Level.AllCaps
        }

        ; check if whole string is lowercase
        if (IsLower(str_letters)) {
            return Capitalization.Level.AllLower
        }

        ; split by sentence
        any_upper_found_sent := false
        any_lower_found_sent := false
        by_sent(sentence) {
            first_letter := SubStr(sentence, 1, 1)

            ; check for upper/lower
            if (IsLower(first_letter)) {
                any_lower_found_sent := true
            } else {
                any_upper_found_sent := true
            }
        }
        Capitalization._ForSplit(str, Capitalization._SENT_DELIM, by_sent)   

        ; check capitalization of sentences
        if (any_upper_found_sent && !any_lower_found_sent) { ; if all sentences are capital
            ; split by word
            any_upper_found_word := false
            any_lower_found_word := false
            by_word(word) {
                first_letter := SubStr(word, 1, 1)

                ; check for upper/lower
                if (IsLower(first_letter)) {
                    any_lower_found_word := true
                } else {
                    any_upper_found_word := true
                }
            }
            Capitalization._ForSplit(str, Capitalization._WORD_DELIM, by_word)

            ; check capitalization of words
            if (
                any_upper_found_word 
                && !any_lower_found_word
            ) { ; if all words are capital
                return Capitalization.Level.WordCaps
            } else { ; some words are caps (could be sentence beginnings)
                return Capitalization.Level.SentenceCaps
            }
        } else { ; some or no sentences are capital
            return Capitalization.Level.SomeCaps
        }
    }

    ; check sentence has multiple words
    static IsSentence(str) {
        return InStr(str, Capitalization._WORD_DELIM)
    }

    ; adjust value for sentence status
    static AdjLevelForSentenceStatus(
        &level, ; the level
        str, ; the ⧼maybe⧽ sentence
        direction ; bool — adjust up or down
    ) {
        if !Capitalization.IsSentence(str) {
            if (
                direction
                && (level == Capitalization.Level.SentenceCaps)
            ) { 
                level := Capitalization.Level.WordCaps
            } else if (
                !direction
                && (level == Capitalization.Level.WordCaps)
            ) {
                level := Capitalization.Level.SentenceCaps
            }
        }
    }

    ; capitalize or lowercase
    static To(str, level, do_enforce_lower := false) {
        ; capitalize all lower
        if (level == Capitalization.Level.AllLower) { ; also includes SomeCaps
            return StrLower(str)
        }

        ; capitalize sentence
        if (level == Capitalization.Level.SentenceCaps) {
            final_sentence := ""
            curr_delim_pos := 0
            sent_caps(sentence) {
                ; capitalize and add
                first_letter := SubStr(sentence, 1, 1)
                remaining_sent := SubStr(sentence, 2)
                if (do_enforce_lower) {
                    remaining_sent := StrLower(remaining_sent)
                }
                capitalized_sent := StrUpper(first_letter) remaining_sent
                final_sentence .= capitalized_sent
                
                ; get delim position after this sentence
                if (curr_delim_pos == 0) {
                    curr_delim_pos += StrLen(capitalized_sent) + 1
                } else {
                    curr_delim_pos += Capitalization._SENT_DELIM_LEN + StrLen(capitalized_sent)
                }

                ; if delim is in range get char from original string and add
                if (curr_delim_pos < StrLen(str)) {
                    final_sentence .= SubStr(str, curr_delim_pos, Capitalization._SENT_DELIM_LEN)
                }
            }
            Capitalization._ForSplit(str, Capitalization._SENT_DELIM, sent_caps)
            return final_sentence
        }

        ; capitalize word
        if (level == Capitalization.Level.WordCaps) {
            words := []
            word_caps(word) {
                first_letter := SubStr(word, 1, 1)
                remaining_word := SubStr(word, 2)
                if (do_enforce_lower) {
                    remaining_word := StrLower(remaining_word)
                }
                words.Push(StrUpper(first_letter) remaining_word)
            }
            Capitalization._ForSplit(str, Capitalization._WORD_DELIM, word_caps)
            return Utils.StrJoin(words, Capitalization._WORD_DELIM)
        }

        ; capitalize all upper
        if (level == Capitalization.Level.AllCaps) {
            return StrUpper(str)
        }
    }

    static ToUpper(str) {
        ; parse current capitalization level
        caps_level := Capitalization.Parse(str)
        Capitalization.AdjLevelForSentenceStatus(&caps_level, str, true)

        ; change to next capitalization
        capsed := Capitalization.To(
            str, 
            Capitalization.Level.Clamp(caps_level + 1)
        )
        return capsed
    }

    static ToLower(str, do_enforce_lower := false) {
        ; parse current capitalization level
        caps_level := Capitalization.Parse(str)
        Capitalization.AdjLevelForSentenceStatus(&caps_level, str, false)

        ; change to next capitalization
        capsed := Capitalization.To(
            str, 
            Capitalization.Level.Clamp(caps_level - 1),
            do_enforce_lower
        )
        return capsed
    }
}