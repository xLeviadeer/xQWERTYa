#Include lib\JSONBase.ahk

class JSON {

    ; --- SUPPORT METHODS ---

    ; expects a class instance
    static IsSerializable(obj) => (
        IsObject(obj)
        && (obj.HasMethod("toJSON"))
    )

    ; expects a class (type)
    static IsDeserializable(cls) => (
        IsObject(cls)
        && (cls.HasProp("Prototype"))
        && (cls.HasMethod("fromJSON"))
    )

    ; --- WRAPPED METHODS ---

    ; passthrough
    static Dump(obj, pretty := false) {
        if !(JSON.IsSerializable(obj)) {
            throw ValueError("obj must be serializable")
        }
        return JSONBase.Dump(obj.toJSON(), pretty)
    }

    ; filters out 
    static DumpFile(obj, path, pretty, encoding?) {
        if !(JSON.IsSerializable(obj)) {
            throw ValueError("obj must be serializable")
        }
        JSONBase.DumpFile(obj.toJSON(), path, pretty, encoding?)
    }

    ; passthrough
    static Load(cls, json) {
        if !(JSON.IsDeserializable(cls)) {
            throw ValueError("cls must be deserializable")
        }
        return cls.fromJSON(JSONBase.Load(json))
    }

    ; passthrough
    static LoadFile(cls, path, options?) {
        if !(JSON.IsDeserializable(cls)) {
            throw ValueError("cls must be deserializable")
        }
        return cls.fromJSON(JSONBase.LoadFile(path, options?))
    }
}