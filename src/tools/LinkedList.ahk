#Requires AutoHotkey v2.0

class Item {
    ; --- VARIABLES ---

    Value := unset
    
    Prev := false
    Next := false

    ; --- CONSTRUCTOR ---

    __New(
        value := unset
    ) {
        this.Value := value
    }
}

class LinkedList {
    ; --- VARIABLES ---

    _FirstItem := false
    _LastItem := false
    Length := 0

    ; --- INDEXABLE ---

    ; index must be positive and non-zero
    __ItemAtPos(index) {
        ; validate index bounding
        if (
            (index <= 0)
            || (index > this.Length)
        ) {
            throw IndexError("index (" index ") out of range: " this.Length)
        }

        ; start from last
        if index > (this.Length / 2) {
            item := this._LastItem
            run_count := ((this.Length - index) + 1)
            loop run_count {
                if A_Index == run_count {
                    return item
                }
                item := item.Prev
            }
        }
        
        ; start from first
        else {
            item := this._FirstItem
            loop index {
                if A_Index == index {
                    return item
                }
                item := item.Next
            }
        }
    }

    _ItemAt(index) {
        if index == 0 {
            throw IndexError("cannot index a list at position 0")
        }
        if index < 0 { ; negative indexing
            return this.__ItemAtPos((this.Length + index) + 1)
        }
        return this.__ItemAtPos(index) ; positive indexing
    } 

    __Item[index] {
        get => this._ItemAt(index).Value
        set => this.InsertAt(index, value)
    }

    __Enum(number_of_vars) {
        ; check number is 1
        if number_of_vars != 1 {
            throw ValueError("LinkedList does not support enumerating more than 1 variable")
        }

        ; enumerator & ret
        is_first := true
        curr_item := this._FirstItem
        next(&value) {
            ; early return for first item
            if is_first {
                ; skip if first item is false
                if curr_item == false {
                    return false
                }

                is_first := false
                value := curr_item.Value
                return true
            }

            ; stop if no more items
            if curr_item.Next == false {
                return false
            }
            
            ; select next and return
            curr_item := curr_item.Next
            value := curr_item.Value
            return true
        }
        return next
    }

    ; --- CONSTRUCTOR ---

    __New(values*) {
        for value in values {
            this.PushLast(value)
        }
    }

    ; --- METHODS ---

    ; -- Adding --

    _InsertItemBefore(
        source, ; item to insert
        dest ; what item to put the source before
    ) {
        ; inserting into at least 1 existing item
        source.Prev := dest.Prev ; set new source's previous as the dest's previous
        if dest.Prev != false {
            dest.Prev.Next := source ; set the previous's next to source
        }
        dest.Prev := source ; set dest's previous to source
        source.Next := dest ; set the new dest's next to source

        ; check for _FirstItem
        if source.Prev == false {
            this._FirstItem := source
        }

        ; update length
        this.Length += 1
    }

    _InsertItemAfter(
        source, ; item to insert
        dest ; what item to put the source after
    ) {
        ; inserting into at least 1 existing item
        source.Next := dest.Next 
        if dest.Next != false {
            dest.Next.Prev := source ; set the previous's next to source
        }
        dest.Next := source ; set dest's previous to source
        source.Prev := dest ; set the new dest's next to source

        ; check for _FirstItem
        if source.next == false {
            this._LastItem := source
        }

        ; update length
        this.Length += 1
    }

    _InsertItemAt(index, item) {
        ; validate index bounding
        if (
            (index <= 0)
            || (index > (this.Length + 1))
        ) {
            throw IndexError("index (" index ") out of range: " (this.Length + 1))
        }

        ; check if any items exist
        if index == (this.Length + 1) { ; adding an item
            if this.Length == 0 { ; creating the first item
                ; set first and last as item
                item.Prev := false
                item.Next := false
                this._FirstItem := item
                this._LastItem := item
            } else { ; adding an item
                item.Prev := this._LastItem ; set the new item's previous as the last item
                this._LastItem.Next := item ; set last item's next to the new item
                this._LastItem := item ; set the last item to the new item
            }
        } else { ; inserting an item
            ; inserting into at least 1 existing item
            dest := this._ItemAt(index)
            item.Prev := dest.Prev ; set new item's previous as the dest's previous
            if dest.Prev != false {
                dest.Prev.Next := item ; set the previous's next to new item
            }
            dest.Prev := item ; set dest's previous to new item
            item.Next := dest ; set the new item's next to dest

            ; check for _FirstItem
            if index == 1 {
                this._FirstItem := item
            }
        }

        ; update length
        this.Length += 1
    }

    InsertAt(index, value) {
        this._InsertItemAt(index, Item(value))
    }

    _PushItemFirst(item) {
        this._InsertItemAt(1, item)
    }

    PushFirst(value) {
        this._PushItemFirst(Item(value))
    }

    _PushItemLast(item) {
        this._InsertItemAt(this.Length + 1, item)
    }
    
    PushLast(value) {   
        this._PushItemLast(Item(value))
    }

    ; -- Removing --

    _RemoveItem(&item) {
        if item.Prev != false {
            item.Prev.Next := item.Next ; set the previous's next to the item next
        }
        if item.Next != false {
            item.Next.Prev := item.Prev ; set the next's previous to the item prev
        }

        ; check first item
        if item == this._FirstItem {
            if item.Next == false { ; check if a next item exists
                this._FirstItem := false 
            }
            this._FirstItem := item.Next ; set _FirstItem to next
        }

        ; check last item
        if item == this._LastItem {
            if item.Prev == false { ; check if a last item exists
                this._LastItem := false
            }
            this._LastItem := item.Prev
        }

        ; update length & ret
        this.Length -= 1
        item.Prev := false
        item.Next := false
    }

    _PopItemAt(index) {
        ; get item and remove from sequence
        item := this._ItemAt(index)
        this._RemoveItem(&item)
        return item
    }

    PopAt(index) {
        return this._PopItemAt(index).Value
    }

    _PopItemFirst() {
        return this._PopItemAt(1)
    }

    PopFirst() {
        return this._PopItemFirst().value
    }

    _PopItemLast() {
        return this._PopItemAt(-1)
    }

    PopLast() {
        return this._PopItemLast().Value
    }

    ; -- Moving --

    _MoveItemBefore(
        source, ; the source item
        dest ; the destination item (to move ¡before¡)
    ) {
        this._RemoveItem(&source)
        this._InsertItemBefore(source, dest)
    }

    _MoveItemAfter(
        source, ; the source item
        dest ; the destination item (to move ¡after¡)
    ) {
        this._RemoveItem(&source)
        this._InsertItemAfter(source, dest)
    }

    _MoveItem(
        source, ; the source item
        dest_index ; the destination index
    ) {
        this._RemoveItem(&source) ; remove source
        this._InsertItemAt(dest_index, source) ; place source at destination 
    }

    Move(source_index, dest_index) {
        source := this._ItemAt(source_index)
        this._MoveItem(source, dest_index)
    }

    _MoveItemFirst(source) {
        this._MoveItem(source, 1)
    } 

    MoveFirst(source_index) {
        source := this._ItemAt(source_index)
        this._MoveItemFirst(source)
    }

    _MoveItemLast(source) {
        this._MoveItem(source, this.Length)
    }

    MoveLast(source_index) {
        source := this._ItemAt(source_index)
        this._MoveItemLast(source)
    }
}