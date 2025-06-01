//
// NetworkClientTests.swift
// ShipShape
// https://www.github.com/twostraws/ShipShape
// See LICENSE for license information.
//

@testable import ShipShape

import Foundation
import Testing

// swiftlint:disable non_optional_string_data_conversion

@MainActor
struct NetworkClientTests {

    private struct MockModel: Codable, Equatable {
        let id: Int
        let name: String
    }

    struct GetResponse {
        @Test("getResponse handles valid response")
        func getResponse_returnsResponseData_forValidResponse() async throws {
            let mockData = try #require(
            """
            {
                [
                    "ignoreThis": "data",
                    "weOnlyCare": "aboutTheResponse"
                ]
            }
            """.data(using: .utf8)
            )

            let mockURL = try #require(URL(string: "https://example.com"))
            let mockValidURLResponse = try #require(
                HTTPURLResponse(
                    url: mockURL,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )
            )

            let systemUnderTest = await NetworkClient { _ in
                (mockData, mockValidURLResponse)
            }

            let mockRequest = URLRequest(url: mockURL)
            try await #expect(systemUnderTest.getResponse(for: mockRequest).statusCode == 200)
        }

        @Test("getResponse throws error for invalid response")
        func getResponse_throwsError_forInvalidResponse() async throws {
            let mockData = try #require(
            """
            {
                [
                    "ignoreThis": "data",
                    "weOnlyCare": "aboutTheResponse"
                ]
            }
            """.data(using: .utf8)
            )

            let mockURL = try #require(URL(string: "https://example.com"))
            let mockInvalidURLResponse = URLResponse()

            let systemUnderTest = await NetworkClient { _ in
                (mockData, mockInvalidURLResponse)
            }

            let mockRequest = URLRequest(url: mockURL)
            await #expect(throws: URLError(.badServerResponse)) {
                try await systemUnderTest.getResponse(for: mockRequest)
            }
        }
    }

    struct GetData {
        @Test("getData returns valid data for valid response")
        func getData_returnsValidModel_forValidResponse() async throws {
            let mockValidData = try #require(
                """
                {
                    "id": 1,
                    "name": "Mock Model"
                }
                """.data(using: .utf8)
            )

            let mockURL = try #require(URL(string: "https://example.com"))
            let mockValidURLResponse = try #require(
                HTTPURLResponse(
                    url: mockURL,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )
            )
            let mockRequest = URLRequest(url: mockURL)
            let serviceUnderTest = await NetworkClient { _ in
                (mockValidData, mockValidURLResponse)
            }
            let result = try await serviceUnderTest.getData(for: mockRequest, ofType: MockModel.self)
            #expect(result == MockModel(id: 1, name: "Mock Model"))
        }

        @Test("getData throws error for valid data with invalid response")
        func getData_throwsError_forValidModel_withInvalidResponse() async throws {
            let mockValidData = try #require(
                """
                {
                    "id": 1,
                    "name": "Mock Model"
                }
                """.data(using: .utf8)
            )

            let mockURL = try #require(URL(string: "https://example.com"))
            let mockInvalidURLResponse = URLResponse()
            let mockRequest = URLRequest(url: mockURL)
            let serviceUnderTest = await NetworkClient { _ in
                (mockValidData, mockInvalidURLResponse)
            }

            await #expect(throws: URLError(.badServerResponse)) {
                try await serviceUnderTest.getData(for: mockRequest, ofType: MockModel.self)
            }
        }

        @Test("getData throws error for invalid data with valid response")
        func getData_throwsError_forInvalidData_withValidResponse() async throws {
            let mockInvalidData = try #require(
                """
                {
                    "invalid": "data"
                }
                """.data(using: .utf8)
            )

            let mockURL = try #require(URL(string: "https://example.com"))
            let mockValidResponse = try #require(
                HTTPURLResponse(
                    url: mockURL,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )
            )

            let mockRequest = URLRequest(url: mockURL)
            let serviceUnderTest = await NetworkClient { _ in
                (mockInvalidData, mockValidResponse)
            }

            await #expect(throws: (any Error).self) {
                try await serviceUnderTest.getData(for: mockRequest, ofType: MockModel.self)
            }
        }
    }

}

// swiftlint:enable non_optional_string_data_conversion
