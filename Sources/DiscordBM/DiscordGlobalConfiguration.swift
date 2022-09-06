import Foundation
import Logging

public enum DiscordGlobalConfiguration {
    public static var apiVersion = 10
    public static var decoder: DiscordDecoder = JSONDecoder()
    public static var encoder: DiscordEncoder = JSONEncoder()
    public static var makeLogger: (String) -> Logger = { Logger(label: $0) }
}

//MARK: - DiscordDecoder
public protocol DiscordDecoder {
    func decode<D: Decodable>(_ type: D.Type, from: Data) throws -> D
}

extension JSONDecoder: DiscordDecoder { }

//MARK: - DiscordEncoder
public protocol DiscordEncoder {
    func encode<E: Encodable>(_ value: E) throws -> Data
}

extension JSONEncoder: DiscordEncoder { }
