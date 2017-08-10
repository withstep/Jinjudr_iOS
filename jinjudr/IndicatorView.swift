//
//  IndicatorView.swift
//  jinjudr
//
//  Created by ByungGu Choi on 2017. 8. 9..
//  Copyright © 2017년 withstep. All rights reserved.
//

import Foundation
typealias CompletionHandler = () -> Swift.Void

/**
 특정 작업중에 사용자의 조작을 막기 위해 IndicatorView를 띄워준다.
 
 일정시간동안 작업이 완료되지 않아 hide()나 또 다른 show() 메소드를
 명시적으로 실행하지 못하는 경우에는 타임아웃이 동작하여 자동으로 hide() 시킨다.
 
 ```
 IndicatorView.shared.show(3) {
 UIAlertView.show(withTitle: nil, message: "타이머 종료", cancelButtonTitle: nil, otherButtonTitles: ["확인"], tap: nil)
 }
 ```
 */
import UIKit

class IndicatorView {
    static let shared: IndicatorView = {
        return IndicatorView()
    } ()
    
    private var timeout = Double.infinity
    private var waitingTimer : Timer?
    private var container = UIView()
    private var loadingView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    private var timeoutHandler: CompletionHandler?
    
    private func show(_ parentView: UIView) {
        container.frame = parentView.frame
        container.center = parentView.center
        container.backgroundColor = UIColor(white: 0x000000, alpha: 0.3)
        
        loadingView.frame = CGRect(x:0, y:0, width:100, height:100)
        loadingView.center = parentView.center
        loadingView.backgroundColor =  UIColor.black
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x:0, y:0, width:40, height:40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x:loadingView.frame.size.width / 2, y:loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        parentView.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    /**
     타임아웃 발생시 IndicatorView를 hide()시키고
     디버그 모드일때만 Toast 메시지를 보여준다.
     */
    @objc private func timeoutOccurred() {
        timeoutHandler?()
        hide()
    }
    
    /**
     타이머 시작시 기존 타이머는 정지하고 다시 시작한다.
     */
    private func startTimer() {
        if let timer = waitingTimer {
            timer.invalidate()
            waitingTimer = nil
        }
        
        waitingTimer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector:#selector(IndicatorView.timeoutOccurred), userInfo: nil, repeats: false)
    }
    
    /**
     타이머 멈추기
     */
    private func stopTimer() {
        waitingTimer?.invalidate()
        waitingTimer = nil
        timeoutHandler = nil
    }
    
    /**
     IndicatorView를 보여주며 타이머를 시작한다.
     
     - Parameter timeout: 타임아웃 시간 (default = 30, 무제한 : Double.infinity)
     - Parameter timeoutHandler: 타임아웃이 발생한 경우 처리할 동작 (default = nil)
     */
    func show(_ timeout: Double = 30, timeoutHandler: CompletionHandler? = nil) {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        
        self.timeout = timeout
        self.timeoutHandler = timeoutHandler
        startTimer()
        
        keyWindow.layoutIfNeeded()
        
        DispatchQueue.main.async {
            self.show(keyWindow)
        }
    }
    
    /**
     IndicatorView를 숨기며 타이머를 종료한다.
     */
    func hide() {
        stopTimer()
        
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.container.removeFromSuperview()
        }
    }
}
