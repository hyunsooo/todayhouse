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
    func reload()
    func deselectFilter(filter: Filter, type: FilterType)
    func selectFilter(filter: Filter, type: FilterType)
    func initializeFilter(type: FilterType)
    func showDetail(_ model: Model)
}

typealias Category = (key: FilterType, value: [Filter])

class ListViewController: UIViewController {

    @IBOutlet var categoryCollectionView: UICollectionView!
    @IBOutlet var filterCollectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    private let filterMenu = FilterMenu()
    
    var currentPage: Int = 1
    var filters = [Category]()                                                          // categoryCollectionView's dataSource
    var selectedFilters = [(filterName: String, key: FilterType, value: String)]()      // filterCollectionView's dataSourcde
    var dataSource = [Model]()                                                          // tableView's dataSource
    var isLoading: Bool = false
    var isEnd: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupViews()
        setCategory()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
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
        
        filterMenu.delegate = self
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
    }
}

extension ListViewController {
    func loadData() {
       
        let parameters = selectedFilters.map { "\("\($0.key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&")
         let urls = "https://s3.ap-northeast-2.amazonaws.com/bucketplace-coding-test/cards/page_\(currentPage).json?\(parameters)"
        if let url = URL(string: urls) {            // url string malform check
            let request = URLRequest(url: url)
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
    
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListViewCell.identifier, for: indexPath) as? ListViewCell else { return ListViewCell() }
        cell.update(dataSource[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadMore(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetail(dataSource[indexPath.row])
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
            let selectedFiltersByCategory = selectedFilters.filter { $0.key == filters[indexPath.row].key}
            if selectedFiltersByCategory.count > 0 {
                cell.backgroundColor = #colorLiteral(red: 0.9098039216, green: 0.9568627451, blue: 0.9843137255, alpha: 1)
                cell.categoryNameLabel.textColor = #colorLiteral(red: 0.2078431373, green: 0.7725490196, blue: 0.9411764706, alpha: 1)
                cell.downImageView.tintColor = #colorLiteral(red: 0.2078431373, green: 0.7725490196, blue: 0.9411764706, alpha: 1)
            } else {
                cell.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
                cell.categoryNameLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.54)
                cell.downImageView.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.54)
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.identifier, for: indexPath) as? FilterCell else { return FilterCell() }
            cell.filterNameLabel.text = selectedFilters[indexPath.row].filterName
            cell.delegate = self
            cell.filter = Filter(title: selectedFilters[indexPath.row].filterName, value: selectedFilters[indexPath.row].value)
            cell.type = selectedFilters[indexPath.row].key
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            print(filters[indexPath.row].key.rawValue)
            let selectedFiltersByCategory = selectedFilters.filter { $0.key == filters[indexPath.row].key}
            filterMenu.showFilter(filters[indexPath.row], selectedFilters: selectedFiltersByCategory.map { Filter(title: $0.filterName, value: $0.value) })
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
            return CGSize(width: width + 38.0, height: 26)
        }
    }
}

extension ListViewController: ListViewControllerDelegate {
    
    func showDetail(_ model: Model) {
        guard let detailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "detailViewController") as? DetailViewController else { return }
       detailViewController.model = model
       navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func selectFilter(filter: Filter, type: FilterType) {
        // 필터 추가
        let newFilter = (filterName: filter.title, key: type, value: filter.value)
        guard !selectedFilters.contains(where: { $0 == newFilter }) else {
            print("중복된 필터입니다.")
            return
        }
        selectedFilters.append(newFilter)
        categoryCollectionView.reloadData()
        filterCollectionView.reloadData()
    }
    
    func deselectFilter(filter: Filter, type: FilterType) {
        // 필터 없애기 -> reload
        selectedFilters.removeAll { (sfilter) -> Bool in
            return sfilter.key == type && sfilter.value == filter.value
        }
        categoryCollectionView.reloadData()
        filterCollectionView.reloadData()
    }
    
    func initializeFilter(type: FilterType) {
        selectedFilters.removeAll { (sfilter) -> Bool in
            return sfilter.key == type
        }
        categoryCollectionView.reloadData()
        filterCollectionView.reloadData()
    }
    
    func reload() {
        dataSource = []
        currentPage = 1
        isEnd = false
        loadData()
    }
}
