//: [Previous](@previous)
import XCPlayground
import UIKit
import RxSwift
import RxCocoa
import Moya
import SnapKit
import SwiftyJSON

let vc = NetSampleViewController()
vc.view.backgroundColor = .red

XCPlaygroundPage.currentPage.liveView = vc

//: [Next](@next)

class NetSampleViewController: UIViewController {
    
    private let resultLabel = UILabel()
    private let endRequestButton = UIButton()
    
    override func viewDidLoad() {
        resultLabel.text = "结果"
        endRequestButton.setTitle("发起请求", for: .normal)
        view.addSubview(resultLabel)
        view.addSubview(endRequestButton)


        resultLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        endRequestButton.snp.makeConstraints { make in
            make.top.equalTo(resultLabel).offset(40)
            make.centerX.equalToSuperview()
        }
        
        endRequestButton.addTarget(self, action: #selector(request), for: .touchUpInside)
    }
    
    @objc func request() {
        APIManager.requestData(
            url: "dcd86ebedb5e519fd7b09b79dd4e4558/raw/b7505a54339f965413f5d9feb05b67fb7d0e464e/MvvmExampleApi.json",
            method: .get,
            parameters: nil) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let returnJson) :
                print("请求成功")
                DispatchQueue.main.async {
                    self.resultLabel.text = "\(returnJson)"
                }
            case .failure(let failure) :
                switch failure {
                case .connectionError:
                    self.resultLabel.text = "无网络"
                case .authorizationError(let errorJson):
                    self.resultLabel.text = "无权限"
                default:
                    self.resultLabel.text = "错误"
                }
            }        }
    }
}

class APIManager {
    
    
    static let baseUrl = "https://gist.githubusercontent.com/mohammadZ74/"
    
    typealias parameters = [String:Any]
    
    enum ApiResult {
        case success(JSON)
        case failure(RequestError)
    }
    enum HTTPMethod: String {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
    }
    enum RequestError: Error {
        case unknownError
        case connectionError
        case authorizationError(JSON)
        case invalidRequest
        case notFound
        case invalidResponse
        case serverError
        case serverUnavailable
    }
    static func requestData(url:String,method:HTTPMethod,parameters:parameters?,completion: @escaping (ApiResult)->Void) {
        
        let header =  ["Content-Type": "application/x-www-form-urlencoded"]
        
        var urlRequest = URLRequest(url: URL(string: baseUrl+url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        urlRequest.allHTTPHeaderFields = header
        urlRequest.httpMethod = method.rawValue
        if let parameters = parameters {
            let parameterData = parameters.reduce("") { (result, param) -> String in
                return result + "&\(param.key)=\(param.value as! String)"
            }.data(using: .utf8)
            urlRequest.httpBody = parameterData
        }
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print(error)
                completion(ApiResult.failure(.connectionError))
            }else if let data = data ,let responseCode = response as? HTTPURLResponse {
                do {
                    let responseJson = try JSON(data: data)
                    print("responseCode : \(responseCode.statusCode)")
                    print("responseJSON : \(responseJson)")
                    switch responseCode.statusCode {
                    case 200:
                    completion(ApiResult.success(responseJson))
                    case 400...499:
                    completion(ApiResult.failure(.authorizationError(responseJson)))
                    case 500...599:
                    completion(ApiResult.failure(.serverError))
                    default:
                        completion(ApiResult.failure(.unknownError))
                        break
                    }
                }
                catch let parseJSONError {
                    completion(ApiResult.failure(.unknownError))
                    print("error on parsing request to JSON : \(parseJSONError)")
                }
            }
        }.resume()
    }
}
