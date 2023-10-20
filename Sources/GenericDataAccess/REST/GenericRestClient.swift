import Foundation

enum APIError: Error{
    case requestFailed
    case jsonEncodingFailure
    case jsonDecodingFailure
    case invalidData
    case responseUnsuccessful
}

struct RestClient<T: Codable>{
    let baseURL: URL
    var headers: [String: String] = ["Content-Type": "application/json"]
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func get(endpoint: String) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        var data: Data?
        var response: URLResponse?
        if #available(macOS 12.0, *) {
            (data, response) = try await URLSession.shared.data(for: request)
        } else {
       
        }
       
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
           throw APIError.responseUnsuccessful
        }
        
        return try JSONDecoder().decode(T.self, from: data!)
    }
    
    func post(endpoint: String, body: T) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        do{
            let encodedBody = try JSONEncoder().encode(body)
            request.httpBody = encodedBody
        } catch {
            throw APIError.jsonEncodingFailure
        }
        var data: Data?
        var response: URLResponse?
        if #available(macOS 12.0, *) {
            (data, response) = try await URLSession.shared.data(for: request)
        } else {
            fatalError("Unsupported OS version")
        }
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw APIError.responseUnsuccessful
        }

        return try JSONDecoder().decode(T.self, from: data!)
    }
    
    func put(endpoint: String, body: T) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers
        do{
            let encodedBody = try JSONEncoder().encode(body)
            request.httpBody = encodedBody
        } catch {
            throw APIError.jsonEncodingFailure
        }
        var data: Data?
        var response: URLResponse?
        if #available(macOS 12.0, *) {
            (data, response) = try await URLSession.shared.data(for: request)
        } else {
            fatalError("Unsupported OS version")
        }
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw APIError.responseUnsuccessful
        }

        return try JSONDecoder().decode(T.self, from: data!)
    }
    
    func delete(endpoint: String) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        var data: Data?
        var response: URLResponse?
        if #available(macOS 12.0, *) {
            (data, response) = try await URLSession.shared.data(for: request)
        } else {
            fatalError("Unsupported OS version")
        }
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw APIError.responseUnsuccessful
        }

        return try JSONDecoder().decode(T.self, from: data!)
        
    }
    
}
