//
//  ViewController.swift
//  Weather_App
//
//  Created by 신지원 on 12/11/23.
//

import UIKit

import SnapKit
import Then

class ListViewController: UIViewController {
    
    // MARK: - Properties
    private var weatherDummy: [Weathers] = []
    
    // MARK: - UI Components
    
    private let rootView = ListView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWeathers(cities: Cities)
        
        gesture()
        target()
        delegate()
    }
    
    // MARK: - Custom Method
    private func gesture() {
        
    }
    
    private func target() {
        
    }
    
    private func delegate() {
        rootView.listTableView.delegate = self
        rootView.listTableView.dataSource = self
    }
    
}

extension ListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 117.0 + 16.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListTableViewHeader.identifier) as? ListTableViewHeader else { return UIView()}
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 169.0 - 16.0
    }
}

extension ListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDummy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier, for: indexPath) as? ListTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.dataBind(weatherDummy[indexPath.row])
        return cell
    }
}

extension ListViewController: ListTableViewCellDelegate {
    func listBtnTap(_ cell: UITableViewCell) {
        guard weatherDummy.count == Cities.count else {
            print("데이터가 아직 로드되지 않았습니다.")
            return
        }
        
        if let indexPath = rootView.listTableView.indexPath(for: cell) {
            let detailPageVC = DetailPageViewController()
            for index in 0..<weatherDummy.count {
                let detailVC = DetailViewController()
                detailVC.VCNum = index
                detailPageVC.VCList.append(detailVC)
            }
            
            detailPageVC.weatherDummy = self.weatherDummy
            detailPageVC.initializePageViewController(with: indexPath.row)
            self.navigationController?.pushViewController(detailPageVC, animated: false)
            
        } else {
            print("Error")
        }
    }
}

extension ListViewController {
    func getWeathers(cities : [String]) {
        var tempWeathers: [Weathers?] = Array(repeating: nil, count: cities.count)
        let dispatchGroup = DispatchGroup()
        
        for (index, city) in cities.enumerated() {
            dispatchGroup.enter()
            WeatherService.shared.getWeather(forCity: city) { weather, error in
                if let error = error {
                    print("Error: \(error)")
                } else if let weather = weather {
                    DispatchQueue.main.async { // 메인 스레드로 전환
                        tempWeathers[index] = weather
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.weatherDummy = tempWeathers.compactMap { $0 }
            self.loadData()
        }
    }
    
    func loadData() {
        rootView.listTableView.reloadData()
    }
}
