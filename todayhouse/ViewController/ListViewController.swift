//
//  ViewController.swift
//  todayhouse
//
//  Created by hyunsu han on 2019/11/23.
//  Copyright © 2019 hyunsoo. All rights reserved.
//

import UIKit

enum FilterType: String {
    case order = "정렬"
    case space = "공간"
    case residence = "주거형태"
}

protocol ListViewControllerDelegate: class {
    func deselectFilter(filter: Filter, type: FilterType)
    func selectFilter(filter: Filter, type: FilterType)
}

typealias Category = (key: FilterType, value: [Filter])

class ListViewController: UIViewController {

    @IBOutlet var categoryCollectionView: UICollectionView!
    @IBOutlet var filterCollectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    private let filterMenu = FilterMenu()
    
    var currentPage: Int = 1
    var filters = [Category]()            // categoryCollectionView's dataSource
    var selectedFilters = [(filterName: String, key: String, value: String)]()      // filterCollectionView's dataSourcde
    var dataSource = [Model]()                                      // tableView's dataSource
    var isLoading: Bool = false
    var isEnd: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupViews()
        setCategory()
        loadData()
    }
    
    func setupViews() {
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: CategoryCell.identifier)
        if let layout = categoryCollectionView.collectionViewLayout as? FilterLayout {
            layout.delegate = self
        }
        filterCollectionView.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: FilterCell.identifier)
        if let layout = filterCollectionView.collectionViewLayout as? FilterLayout {
            layout.delegate = self
        }
    }
    
    func setCategory() {
        filters.append((key: FilterType.order, value: [Filter(title: "최신순", value: "recent"),
                                                       Filter(title: "베스트", value: "best"),
                                                       Filter(title: "인기순", value: "popular")]))
        filters.append((key: FilterType.space, value: [Filter(title: "거실", value: "1"),
                                                       Filter(title: "침실", value: "2"),
                                                       Filter(title: "주방", value: "3"),
                                                       Filter(title: "욕실", value: "4")]))
        filters.append((key: FilterType.residence, value: [Filter(title: "아파트", value: "1"),
                                                           Filter(title: "빌라&연립", value: "2"),
                                                           Filter(title: "단독주택", value: "3"),
                                                           Filter(title: "사무공간", value: "4")]))
        
        categoryCollectionView.reloadData()
        
//        selectedFilters.append((filterName: "거실", param: URLQueryItem(name: "\(FilterType.space)", value: "1")))
//        selectedFilters.append((filterName: "아파트", param: URLQueryItem(name: "\(FilterType.residence)", value: "1")))
        
//        filterCollectionView.reloadData()
    }
}

extension ListViewController {
    func loadData() {
        let urls = "https://s3.ap-northeast-2.amazonaws.com/bucketplace-coding-test/cards/page_\(currentPage).json"
        if var url = URL(string: urls) {            // url string malform check
//            let params: [String] = selectedFilters.map { (filterName, key, value) -> String in
//                return key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" + "=" + value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
//            }
            
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
//            request.httpBody = parameters.map { (key, value) -> String in
//
//            }.joined(separator: "&").data(using: .utf8)
            self.isLoading = true
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self else { return }
                self.isLoading = false
                guard let data = data else { print("데이터가 없습니다."); return }
                guard error == nil else {
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    return
                }
                let dataString = String(decoding: data, as: UTF8.self)
//                print(dataString)
                
                guard let status = (response as? HTTPURLResponse)?.statusCode, status == 200 else {
                    print("CODE (\((response as? HTTPURLResponse)?.statusCode ?? 0)) : \(dataString)")
                    return
                }
                
                let decoder = JSONDecoder()
                do {
                    let decoded: [Model] = try decoder.decode([Model].self, from: data)
                    if decoded.isEmpty { self.isEnd = true }
                    self.dataSource.append(contentsOf: decoded)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }.resume()
        }
    }
    
    func loadMore(indexPath: IndexPath) {
        guard indexPath.item == dataSource.count - 3 else { return }
        guard !isLoading else {
            print("데이터를 가져오고 있습니다.")
            self.alert(message: "데이터를 가져오고 있습니다.")
            return
        }
        
        guard !isEnd else {
            print("더 이상 데이터가 없습니다.")
            alert(message: "더 이상 데이터가 없습니다.")
            return
        }
        
        currentPage += 1
        loadData()
    }
    
    func reload() {
        dataSource = []
        currentPage = 1
        isEnd = false
        loadData()
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListViewCell.identifier, for: indexPath) as? ListViewCell else { return ListViewCell() }
        cell.setDescriptionLabel(dataSource[indexPath.row].description ?? "")
        cell.imageUrls = [dataSource[indexPath.row].imageUrl]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadMore(indexPath: indexPath)
    }
    
}

extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return filters.count
        } else {
            return selectedFilters.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else { return CategoryCell() }
            cell.categoryNameLabel.text = filters[indexPath.row].key.rawValue
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.identifier, for: indexPath) as? FilterCell else { return FilterCell() }
            cell.filterNameLabel.text = selectedFilters[indexPath.row].filterName
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            print(filters[indexPath.row].key.rawValue)
            filterMenu.showFilter(filters[indexPath.row])
        }
    }
}

extension ListViewController: FilterLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            let width: CGFloat = Utils.getTextSize(text: filters[indexPath.row].key.rawValue, font: UIFont(name: "AppleSDGothicNeo-Regular", size: 15)!).width
            return CGSize(width: width + 30.0, height: 32)
        }
        else {
            let width: CGFloat = Utils.getTextSize(text: selectedFilters[indexPath.row].filterName, font: UIFont(name: "AppleSDGothicNeo-Regular", size: 15)!).width
            return CGSize(width: width + 36.0, height: 26)
        }
    }
}

extension ListViewController: ListViewControllerDelegate {
    func selectFilter(filter: Filter, type: FilterType) {
        // 필터 추가
        let selected = (filterName: filter.title, key: type.rawValue, value: filter.value)
        selectedFilters.append(selected)
        filterCollectionView.reloadData()
        
        reload()
    }
    
    func deselectFilter(filter: Filter, type: FilterType) {
        // 필터 없애기 -> reload
    }
}
