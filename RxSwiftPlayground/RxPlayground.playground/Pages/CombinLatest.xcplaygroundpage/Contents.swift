//: [Previous](@previous)

import XCPlayground
import UIKit
import RxSwift
import RxCocoa
import SnapKit

let vc = CombineLatestSampleViewController()
vc.view.backgroundColor = .red

XCPlaygroundPage.currentPage.liveView = vc

//: [Next](@next)

class CombineLatestSampleViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    private let emailTextFeild = UITextField()
    private let pwdTextFeild = UITextField()
    private let signupButton = UIButton()
    
    override func viewDidLoad() {
        signupButton.setTitle("登录", for: .normal)
        view.addSubview(emailTextFeild)
        view.addSubview(pwdTextFeild)
        view.addSubview(signupButton)

        emailTextFeild.backgroundColor = .white
        pwdTextFeild.backgroundColor = .white

        emailTextFeild.placeholder = "请输入邮箱"
        pwdTextFeild.placeholder = "请输入密码"
        emailTextFeild.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        pwdTextFeild.snp.makeConstraints { make in
        make.width.equalTo(200)
            make.top.equalTo(emailTextFeild).offset(40)
            make.centerX.equalToSuperview()
        }
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(pwdTextFeild).offset(40)
            make.centerX.equalToSuperview()
        }
        
        let signupDTOs = Observable.combineLatest(
            emailTextFeild.rx.text.orEmpty,
            pwdTextFeild.rx.text.orEmpty
        ).map(SignupDTO.init)
        
        let signupEvents = signupButton.rx.tap.withLatestFrom(signupDTOs)
        signupEvents.subscribe(onNext: { item in
            print("输入的邮箱是:\(item.email)")
            print("输入的邮箱是:\(item.pwd)")
        }).disposed(by: disposeBag)
    }
}

struct SignupDTO {
    let email: String
    let pwd: String
}

//: [Next](@next)
