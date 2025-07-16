import UIKit

// MARK: - NetworkError

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

// MARK: - URLSession Extension

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                print("[URLSession] ❌ Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(NetworkError.urlRequestError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[URLSession] ❌ Нет HTTPURLResponse")
                completion(.failure(NetworkError.urlSessionError))
                return
            }

            print("[URLSession] 🛰 HTTP статус: \(httpResponse.statusCode)")

            guard let data = data, !data.isEmpty else {
                print("[URLSession] ❌ Пустой ответ от сервера")
                completion(.failure(AuthServiceError.invalidResponse))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                let responseBody = String(data: data, encoding: .utf8) ?? "nil"
                print("[URLSession] ⚠️ Ответ с ошибкой: \(responseBody)")
                completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                return
            }

            let rawJSON = String(data: data, encoding: .utf8) ?? "nil"
            print("[URLSession] 📦 JSON: \(rawJSON)")

            do {
                let decodedObject = try decoder.decode(T.self, from: data)
                print("[URLSession] ✅ Успешный декодинг")
                completion(.success(decodedObject))
            } catch {
                print("[URLSession] ❌ Ошибка декодирования: \(error.localizedDescription)")
                print("[URLSession] 📦 JSON: \(rawJSON)")
                completion(.failure(error))
            }
        }

        return task
    }
}
