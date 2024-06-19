//
//  ViewController.swift
//  OpenWheather
//
//  Created by t2023-m0032 on 6/19/24.
//

import UIKit
import SnapKit
import Alamofire
import Kingfisher
import CoreLocation // 1.위치 프레임워크 임포트

class ViewController: UIViewController {
    let dateLabel = UILabel()
    let locationImage = UIImageView()
    let locationLabel = UILabel()
    let shareButton = UIButton()
    let refreshButton = UIButton()
    
    let tempLabel = UILabel()
    let humLabel = UILabel()
    let windLabel = UILabel()
    let weatherImage = UIImageView()
    let message = UILabel()
    
    let locationManager = CLLocationManager() //2.위치 매니저 생성 : 위치의 대부분을 담당
    
    var lat = 37.0
    var lon = 127.0
    
    var icon = ""
    var temp = 0.0
    var hum = 0.0
    var speed = 0.0
    var city = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    func callRequest() {
        
        let appid = appid
        let url = "https://api.openweathermap.org/data/2.5/weather?appid=\(appid)&units=metric&lang=kr&lat=\(lat)&lon=\(lon)"
        AF.request(url).responseDecodable(of: WeatherAPI.self) { [self] response in
            switch response.result {
            case .success(let value):
                print(value)
                self.icon = value.weather[0].icon
                self.temp = value.main.temp
                self.hum = value.main.humidity
                self.speed = value.wind.speed
                self.city = value.name
                
                self.date()
                self.locationLabel.text = self.city
                self.tempLabel.text = "지금은 \(round(self.temp*10)/10)°C 에요"
                self.humLabel.text = "\(Int(round(self.hum)))% 만큼 습해요"
                self.windLabel.text = "\(Int(round(self.speed)))m/s의 바람이 불어요"
                let url = URL(string: "https://openweathermap.org/img/wn/\(self.icon)@2x.png")
                self.weatherImage.kf.setImage(with: url)
                self.message.text = positiveMessages.randomElement()
            case .failure(let error):
                print(error)
            }
        }
    }
    func date() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일 HH시 mm분"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dateLabel.text = dateFormatter.string(from: date)
    }
    @objc func refreshButtonClicked() {
        //locationManager.startUpdatingLocation()는
/*     case .authorizedWhenInUse:
        print("위치 정보 알려달라고 로직 구성 가능")
        locationManager.startUpdatingLocation() 에서만 쓰임 */
        checkDeviceLocationAuthorization()
    }
    func configureHierarchy() {
        view.addSubview(dateLabel)
        view.addSubview(locationImage)
        view.addSubview(locationLabel)
        view.addSubview(shareButton)
        view.addSubview(refreshButton)
        view.addSubview(tempLabel)
        view.addSubview(humLabel)
        view.addSubview(windLabel)
        view.addSubview(weatherImage)
        view.addSubview(message)
        locationManager.delegate = self // 4.클래스와 프로토콜 연결
    }
    func configureLayout() {
        dateLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).offset(30)
        }
        locationImage.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(15)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.width.equalTo(30)
        }
        locationLabel.snp.makeConstraints { make in
            make.leading.equalTo(locationImage.snp_trailingMargin).offset(20)
            make.centerY.equalTo(locationImage.snp.centerY)
        }
        refreshButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerY.equalTo(locationImage.snp.centerY)

        }
        shareButton.snp.makeConstraints { make in
            make.trailing.equalTo(refreshButton.snp.leading).offset(-30)
            make.centerY.equalTo(locationImage.snp.centerY)
        }
        tempLabel.snp.makeConstraints { make in
            make.top.equalTo(locationImage.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(35)
            make.width.equalTo(130)
        }
        humLabel.snp.makeConstraints { make in
            make.top.equalTo(tempLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(35)
            make.width.equalTo(115)
        }
        windLabel.snp.makeConstraints { make in
            make.top.equalTo(humLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(35)
            make.width.equalTo(140)
        }
        weatherImage.snp.makeConstraints { make in
            make.top.equalTo(windLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(120)
            make.width.equalTo(170)
        }
        message.snp.makeConstraints { make in
            make.top.equalTo(weatherImage.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.height.greaterThanOrEqualTo(35)
            make.width.greaterThanOrEqualTo(170)
        }
        
    }
    func configureUI() {
        view.backgroundColor = .link
        
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .white
        
        locationImage.image = UIImage(systemName: "location.fill")
        locationImage.tintColor = .white
        
        locationLabel.font = .systemFont(ofSize: 18)
        locationLabel.textColor = .white
        
        refreshButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        refreshButton.tintColor = .white
        refreshButton.addTarget(self, action: #selector(refreshButtonClicked), for: .touchUpInside)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .white
        
        tempLabel.textColor = .black
        tempLabel.font = .systemFont(ofSize: 14)
        tempLabel.textAlignment = .center
        tempLabel.backgroundColor = .white
        tempLabel.clipsToBounds = true
        tempLabel.layer.cornerRadius = 10
        
        humLabel.textColor = .black
        humLabel.font = .systemFont(ofSize: 14)
        humLabel.textAlignment = .center
        humLabel.backgroundColor = .white
        humLabel.clipsToBounds = true
        humLabel.layer.cornerRadius = 10
        
        windLabel.textColor = .black
        windLabel.font = .systemFont(ofSize: 14)
        windLabel.textAlignment = .center
        windLabel.backgroundColor = .white
        windLabel.clipsToBounds = true
        windLabel.layer.cornerRadius = 10
        
        weatherImage.backgroundColor = .white
        weatherImage.layer.cornerRadius = 10
        weatherImage.contentMode = .center
        
        message.textColor = .black
        message.font = .systemFont(ofSize: 14)
        message.numberOfLines = 0
        message.backgroundColor = .white
        message.layer.cornerRadius = 10
        message.clipsToBounds = true
        message.textAlignment = .center
    }
}
//1)사용자에게 권한 요청을 하기 위해, iOS 위치 서비스 활성화 여부 체크
extension ViewController {
    func checkDeviceLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            //2)현재 사용자의 위치 권한 상태 확인
            checkCurrentLocationAuthorization()
        }
        else {
            print("위치 서비스가 꺼져 있아서, 위치 권한 요청을 할 수 없어요.")
        }
    }
    func checkCurrentLocationAuthorization() {
        //2)현재 사용자의 위치 권한 상태 확인
        var status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        }
        else {
            status = CLLocationManager.authorizationStatus()
        }
        switch status {
            
        case .notDetermined:
            print("이 권한에서만 권한 문구를 띄울 수 있음")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("iOS 설정 찾으러 이동하라는 얼럿 띄워주기")
        case .authorizedWhenInUse:
            print("위치 정보 알려달라고 로직 구성 가능")
            locationManager.startUpdatingLocation()
        default:
            print(status)
        }
    }
}
extension ViewController: CLLocationManagerDelegate { //3. 위치 관련 프로토콜 선언
    //5.사용자 위치를 성공적으로 가져온 경우
    //코드 구성에 따라 여러번 호출이 될 수도 있다
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        
        if let coorinate = locations.last?.coordinate {
            print(coorinate)
            print(coorinate.latitude)
            print(coorinate.longitude)
            lat = coorinate.latitude
            lon = coorinate.longitude
        }
        //startUpdatingLocation을 했으면 더 이상 위치를 안받아도 되는 시점에서는 stop을 외쳐야합니다
        callRequest()
        locationManager.stopUpdatingLocation()

    }
    //6.사용자 위치를 못 가져온 경우
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error)
    }
    //7.사용자 권한 상태가 변경이 될때(iOS14기준으로 다름) + 인스턴스가 생성이 될 때도 호출이 된다.
    //사용자가 허용했는데 아이폰 설정에서 나중에 허용을 거부한다면
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //권한 요청 문구 띄우기
        //항상 띄우진 않음 '처음' 기준은?
        //iPhone 위치 섭시ㅡ
        //notDetermined
        
        //1)사용자에게 권한 요청을 하기 위해, iOS 위치 서비스 활성화 여부 체크
        checkDeviceLocationAuthorization()
        //2)현재 사용자의 위치 권한 상태 확인
        checkCurrentLocationAuthorization()
        //3)notDetermined일 때 권한을 요청

    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status,"iOS14-")
    }
}
