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

}
