//
//  ViewController.swift
//  RxSwiftPlayground
//
//  Created by 吴迪玮 on 2020/8/22.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalTo(self.view)
            
        }
        
        let disposeBag = DisposeBag()
        Observable
            .of(1)
            .subscribe(onNext: { navigation in
            
            }).disposed(by: disposeBag)
    }


}

extension ViewController: UIScrollViewDelegate {
    
}
