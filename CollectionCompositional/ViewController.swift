//
//  ViewController.swift
//  CollectionCompositional
//
//  Created by jefferson.setiawan on 21/12/22.
//

import SnapKit
import UIKit

struct PdpModel: Equatable {
    var id: Int
    var name: String
    var components: [PdpComponent]
}

enum PdpComponent: Equatable {
    case media
    case info
    case variant
    case recommendation
}
//import BackgroundTasks
//BGTaskScheduler.register(<#T##self: BGTaskScheduler##BGTaskScheduler#>)

struct ProductCardModel: Equatable, Hashable {
    var id: Int
    var name: String
    var price: Int
    var discountPrice: Int?
}

class ViewController: UIViewController {
    enum Section {
        case main
    }
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var dataSource: UICollectionViewDiffableDataSource<Section, ProductCardModel>! = nil
    private var items: [ProductCardModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let shuffleBtn = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffle))
        navigationItem.rightBarButtonItem = shuffleBtn
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        collectionView.collectionViewLayout = generateCollectionLayout()
        configureDataSource()
    }
    
    @objc private func shuffle() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProductCardModel>()
        items.shuffle()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func generateCollectionLayout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.25),
            heightDimension: .estimated(2)
        ))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(20)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureDataSource() {
        collectionView.register(TextCell.self, forCellWithReuseIdentifier: "cell")
        dataSource = UICollectionViewDiffableDataSource<Section, ProductCardModel>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, model: ProductCardModel) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TextCell
            cell.label.text = Bool.random() ? "\(model.name)" : "This is \n \(model.name)"
            cell.label.numberOfLines = 0
            cell.contentView.backgroundColor = .lightGray
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
            cell.label.textAlignment = .center
            cell.label.font = UIFont.preferredFont(forTextStyle: .title1)
            return cell
        }
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProductCardModel>()
        items = (0..<94).map {
            ProductCardModel(id: $0, name: "Produk \($0)", price: $0 * 10)
        }
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        DispatchQueue.global(qos: .background).async {
            print("<<<", Thread.current)
            self.dataSource.apply(snapshot, animatingDifferences: false) {
                print("<<<", Thread.current)
            }
        }
    }
}
