//
//  NetworkRequest.swift
//  MVVM-C
//
//  Created by Abdurrahman Alboghdady on 09/04/2022.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class NetworkRequest {
    
    static var shared = NetworkRequest()
    private let disposeBag = DisposeBag()
    
    func sendRequest<T: Codable>(function: ApiManager, model: T.Type, showLoading: Bool = true,
                                  success: @escaping(_ model: T)->(), failure: @escaping (_ errors:String)->()) {
        switch Reachability().connectionStatus() {
        case .unknown, .offline:
            failure("No internet connection")
        case .online(.wwan), .online(.wiFi):
            let provider = MoyaProvider<ApiManager>()
            provider.rx.request(function)
                .map(T.self)
                .subscribe { (value) in
                    success(value)
                } onFailure: { (error) in
                    print(error.localizedDescription)
                    failure(error.localizedDescription)
                }.disposed(by: disposeBag)
        }
    }
}
