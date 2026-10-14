; a list with a fixed number of slots which can hold whatever value is given

#Requires AutoHotkey v2.0

#Include LinkedList.ahk

class CacheEntry {
    ; --- VARIABLES ---

    data := unset
    item := unset

    ; --- CONSTRUCTOR ---

    __New(
        data,
        item
    ) {
        this.Data := data
        this.Item := item
    }
}

class RollingBuffer {
    ; --- VARIABLES ---

    _Cache := unset ; Map<key, CacheEntry<any, Item<key>>>
    _Order := unset ; LinkedList<Item<key>>
    _EndItem := unset ; Item<key>
    _IsFirstAlloc := true

    ; --- INDEXABLE ---

    __Item[key] {
        get => this.TouchGet(key)
        set => this.TouchSet(key, value)
    }

    __Enum(number_of_vars) => this._Order.__Enum(number_of_vars)

    Length => this._Cache.Length

    Has(key) {
        return this._Cache.Has(key)
    }

    ; --- CONSTRUCTOR ---

    __New(capacity) {
        ; validate capacity
        if (
            !(capacity is Integer)
            || (capacity <= 0)
        ) {
            throw TypeError("capacity must be a positive non-zero integer")
        }
        this._Capacity := capacity

        ; set slots
        this._Cache := Map()
        this._Order := LinkedList()
        loop capacity { ; O(capacity)
            this._Order._PushItemLast(Item(false))
        }
        this._EndItem := this._Order._ItemAt(1) ; end starts as the first item ╎ first item call O(1)
    }

    ; --- METHODS ---

    ; rolls the oldest entry to the front of the cache, emptying it
    _RollOver() {
        ; remove first from cache
        this._Cache.Delete(this._Order[1])

        ; move to end & remove from order & ret
        this._Order.MoveLast(1) ; first item call O(1)
        this._EndItem := this._Order._ItemAt(-1) ; last item call O(1)
        this._EndItem.Value := false 
    }

    ; get the next item, rolling over if needed
    _Alloc(value) {
        if this._EndItem.Next == false {
            this._RollOver() ; sets _EndItem
        } else if !this._IsFirstAlloc {
            this._EndItem := this._EndItem.Next ; move end item up
        } else {
            this._IsFirstAlloc := false
        }
        this._EndItem.Value := value
        return this._EndItem
    }

    ; bumps a value at the key to the front of the buffer
    _Bump(key) {
        ; move the item (ref from the cache) to the end (newest) order
        itm := this._Cache[key].Item
        this._Order._MoveItemAfter(itm, this._EndItem)
        this._EndItem := itm
    }

    ; update/create & bump
    TouchSet(key, value) {
        ; if key exists
        if this._Cache.Has(key) {
            this._Bump(key)
            this._Cache[key].Data := value
        } else {
            itm := this._Alloc(key)
            this._Cache[key] := CacheEntry(value, itm)
        }
    }

    ; get & bump
    TouchGet(key) {
        ; check if exists
        if !this._Cache.Has(key) {
            throw ValueError("key (" key ") does not exist to be touched")
        }
        this._Bump(key)
        return this._Cache[key].Data
    }
}