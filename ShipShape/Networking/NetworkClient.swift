//
// NetworkService.swift
// ShipShape
// https://www.github.com/twostraws/ShipShape
// See LICENSE for license information.
//

import Foundation

@MainActor
struct NetworkClient {
    typealias DataRequest = (URLRequest) async throws -> (Data, URLResponse)
    var data: DataRequest

    func getResponse(
        for request: URLRequest
    ) async throws -> HTTPURLResponse {
        let (_, response) = try await self.data(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        return httpResponse
    }

    func getData<T: Decodable>(
        for request: URLRequest,
        ofType: T.Type
    ) async throws -> T {
        let (data, response) = try await self.data(request)

        guard response is HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode due to missing key '\(key)' - \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode due to type mismatch - \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode due to missing \(type) value - \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(let context) {
            fatalError("Failed to decode: it appears to be invalid JSON: \(context)")
        } catch {
            fatalError("Failed to decode: \(error.localizedDescription)")
        }
    }
}
