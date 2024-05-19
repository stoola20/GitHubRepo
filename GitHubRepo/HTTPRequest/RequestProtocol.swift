////
//  RequestProtocol.swift
//  GitHubRepo
//
//  Created by Jesse Chen on 2024/5/17.
//
//

import Alamofire
import Foundation
import RxAlamofire
import RxSwift

/// Protocol for making network requests and handling responses.
protocol RequestProtocol {
    /// Sends a network request and returns the response as an observable sequence.
    ///
    /// - Parameters:
    ///   - url: The URL for the request.
    ///   - method: The HTTP method for the request.
    ///   - parameters: The parameters to be sent in the request, if any.
    ///   - header: The HTTP header fields for the request.
    ///   - type: The type of the expected response.
    /// - Returns: An observable sequence that emits the decoded response or an error.
    func request<T: Decodable>(
        url: URL?,
        method: Alamofire.HTTPMethod,
        parameters: [String: String]?,
        header: [String: String],
        type: T.Type
    ) -> Observable<T>
}

/// Default implementation for sending a network request.
extension RequestProtocol {
    func request<T: Decodable>(
        url: URL?,
        method: Alamofire.HTTPMethod,
        parameters: [String: String]?,
        header: [String: String],
        type: T.Type
    ) -> Observable<T> {
        guard let url else {
            return Observable.error(ServerError.unknownError)
        }

        return requestData(method,
                           url,
                           parameters: parameters,
                           encoding: URLEncoding.default,
                           headers: HTTPHeaders(header))
            .debug("⏳")
            .flatMap { response, responseData -> Observable<T> in
                if let errorStatusCode = ErrorStatusCode(rawValue: response.statusCode) {
                    return .error(ServerError.requestFailure(errorStatusCode.description))
                }

                if response.statusCode != 200 {
                    let msg = String(data: responseData, encoding: .utf8)
                    return .error(ServerError.requestFailure(msg ?? ""))
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    let resultModel = try decoder.decode(type, from: responseData)

                    return Observable.just(resultModel)
                } catch {
                    return Observable.error(ServerError.parsingFailure)
                }
            }
    }
}

/// Enum representing possible server errors.
enum ServerError: Error {
    /// Indicates a failure in the network request.
    case requestFailure(String)
    /// Indicates a failure in parsing the response.
    case parsingFailure
    /// Indicates an unknown error.
    case unknownError
    /// Indicates empty query error.
    case emptyQuery
}

extension ServerError {
    /// Provides a readable description for each server error case.
    var errorDescription: String {
        switch self {
        case .requestFailure(let description):
            return description
        case .parsingFailure:
            return "Failed to parse the response data."
        case .unknownError:
            return "An unknown error occurred."
        case .emptyQuery:
            return "The data couldn't be read because it is missing."
        }
    }
}

/// Enum representing HTTP error status
enum ErrorStatusCode: Int {
    case sc301 = 301
    case sc304 = 304
    case sc403 = 403
    case sc404 = 404
    case sc422 = 422
    case sc503 = 503

    /// Provides a human-readable description for each error status code.
    var description: String {
        switch self {
        case .sc301:
            "Moved permanently"
        case .sc304:
            "Not modified"
        case .sc403:
            "Forbidden"
        case .sc404:
            "Resource not found"
        case .sc422:
            "Validation failed, or the endpoint has been spammed."
        case .sc503:
            "Service unavailable"
        }
    }
}
