import Foundation

struct LibResult<T: Decodable>: Decodable {
    let status: Int
    let data: T?
    let errorMessage: String?

    func isSuccess() -> Bool {
        (200 ... 299).contains(status)
    }
}

// TODO: better way to decode LibResult when it doesn't have data. Maybe don't use Decodable.
typealias ArbitraryType = String

extension LibResult {
    func toResult() -> Result<T, CoreError> {
        if isSuccess() {
            if let data = data {
                return .success(data)
            } else {
                return .failure(.error(
                    message: "Unexpected: Library result success but no data: \(self)"))
            }
        } else {
            return .failure(.error(message: "Lib error result: \(self)"))
        }
    }

    func toVoidResult() -> Result<Void, CoreError> {
        if isSuccess() {
            return .success(())
        } else {
            return .failure(.error(message: "Lib error result: \(self)"))
        }
    }
}

extension Unmanaged where Instance == CFString {
    func toLibResult<T>() -> LibResult<T> {
        let resultValue: CFString = takeRetainedValue()
        let resultString = resultValue as String

        log.d("Deserializing native core result: \(resultString)")

        // TODO: review safety of utf-8 force unwrap
        let data = resultString.data(using: .utf8)!
        let decoder = JSONDecoder()

        do {
            return try decoder.decode(LibResult<T>.self, from: data)
        } catch let e {
            // Bad gateway (502): "The server, while acting as a gateway or proxy, received an invalid response from the upstream server"
            // Using HTTP status codes for library communication probably temporary. For now it seems suitable.
            return LibResult(status: 502, data: nil, errorMessage: "Invalid library result: \(e)")
        }
    }
}

public enum CoreError: Error {
    case error(message: String)
}
