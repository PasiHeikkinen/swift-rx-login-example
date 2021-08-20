import Foundation

func using<Value>(_ value: Value, o: (inout Value) -> ()) -> Value {
    var result: Value = value
    o(&result)
    return result
}
