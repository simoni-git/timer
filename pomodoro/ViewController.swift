//
//  ViewController.swift
//  pomodoro
//
//  Created by MAC on 2023/03/06.
//

import UIKit
import AudioToolbox

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var toggleButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    var duration = 60
    var timerStatus: TimerStatus = .end
    var timer: DispatchSourceTimer?
    var CurrentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
     }
    
    func setTimerInFoVieVisble(isHidden: Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }
    
    func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
        // for: .nomal 은 일시정지상태일때를 의미
        // for: selected 는 선택되어있을때 를 의미.
        //그래서 토글버튼타이틀은 시작인데 언제'시작' 이라고나오냐? 버튼이 되어있을상태일때
        // 토글버튼타이틀은 일시정지인데 언제 '일시정지' 라고 나오냐? 버튼이 선택되어있는상태일때
        
    }
    func stratTimer() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [] , queue: .main)
            self.timer?.schedule(deadline: .now() , repeating: 1)
            self.timer?.setEventHandler(handler: {[weak self] in
                guard let self = self else { return }
                self .CurrentSeconds -= 1
                let hour = self.CurrentSeconds / 3600
                let minutes = (self.CurrentSeconds % 3600) / 60
                let seconds = (self.CurrentSeconds % 3600) % 60
                
                self.timerLabel.text = String (format: "%02d:%02d:%02d", hour , minutes , seconds)
                self.progressView.progress = Float(self.CurrentSeconds) / Float (self.duration)
                
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                })
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                })
                               
                
                if self.CurrentSeconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    func stopTimer() {
        if self.timerStatus == .pause {
            self.timer?.resume()
        }
        
        self.timerStatus = .end
        self.cancelButton.isEnabled = false
        self.toggleButton.isSelected = false
        UIView.animate(withDuration: 0.5,  animations: {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
        })

        self.timer?.cancel()
        self.timer = nil
    }
    
    
    @IBAction func tapcancelButton(_ sender: UIButton) {
        switch self.timerStatus {
        case .start, .pause:
                        self.stopTimer()
            
            
        default:
            break
       
        }
    }
    
    @IBAction func taptoggleButton(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration)
        switch self.timerStatus {
        case .end:
            self.CurrentSeconds = self.duration
            self.timerStatus = .start
            UIView.animate(withDuration: 0.5,  animations: {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            })
            self.toggleButton.isSelected = true
            self.cancelButton.isEnabled  = true
            self.stratTimer()
            
        case .start:
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()
        
        case .pause:
            self.timerStatus = .start
            self.toggleButton.isSelected = true
            self.timer?.resume()
            
        }
    }
    
}

