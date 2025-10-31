import ObjectiveC
import UIKit

// MARK: - Base Handler
class BaseCollectionHandler<Item: Equatable, Cell: UICollectionViewCell>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private weak var collectionView: UICollectionView?
    private let items: [Item]
    private let configure: (Cell, Item, Bool) -> Void
    private let onSelect: (Item) -> Void
    private let configureHeader: ((UICollectionReusableView) -> Void)?
    private var selectedItemIndexPath: IndexPath?
    
    init(
        items: [Item],
        configure: @escaping (Cell, Item, Bool) -> Void,
        onSelect: @escaping (Item) -> Void,
        configureHeader: ((UICollectionReusableView) -> Void)? = nil
    ) {
        self.items = items
        self.configure = configure
        self.onSelect = onSelect
        self.configureHeader = configureHeader
    }
    
    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: Cell.self),
            for: indexPath
        ) as? Cell else {
            return UICollectionViewCell()
        }
        
        configure(cell, items[indexPath.row], indexPath == selectedItemIndexPath)
        return cell
    }
    
    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var indexPathsToReload: [IndexPath] = [indexPath]
        
        if let oldIndexPath = selectedItemIndexPath, oldIndexPath != indexPath {
            indexPathsToReload.append(oldIndexPath)
        }
        selectedItemIndexPath = indexPath
        collectionView.reloadItems(at: indexPathsToReload)
        onSelect(items[indexPath.row])
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let configureHeader = configureHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CollectionHeaderView.identifier,
            for: indexPath
        )
        configureHeader(header)
        return header
    }
    
    // MARK: - Public Methods
    func attach(to collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func selectItem(_ item: Item) {
        guard let collectionView,
              let newIndex = items.firstIndex(of: item) else { return }
        
        let indexPath = IndexPath(item: newIndex, section: 0)
        
        selectedItemIndexPath = indexPath
        collectionView.reloadItems(at: [indexPath])
    }
    
    class func makeLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let sideInset: CGFloat = 18
        let spacing: CGFloat = 0
        let itemsPerRow: CGFloat = 6
        
        let totalSpacing = (itemsPerRow - 1) * spacing + sideInset * 2
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / itemsPerRow
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 30)
        
        return layout
    }
}

// MARK: - Emoji Handler
final class EmojiCollectionHandler: BaseCollectionHandler<String, EmojiCell> {
    init(onSelect: @escaping (String) -> Void) {
        let emojis = [
            "🙂", "😻", "🌺", "🐶", "❤️", "😱",
            "😇", "😡", "🥶", "🤔", "🙌", "🍔",
            "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
        ]
        super.init(
            items: emojis,
            configure: { cell, emoji, isSelected in
                cell.configure(emoji: emoji, isSelected: isSelected)
            },
            onSelect: { emoji in
                onSelect(emoji)
            },
            configureHeader: { header in
                guard let header = header as? CollectionHeaderView else { return }
                header.headerLabel.text = L10n.emoji
            }
        )
    }
}

// MARK: - Color Handler
final class ColorCollectionHandler: BaseCollectionHandler<UIColor, ColorCell> {
    init(onSelect: @escaping (UIColor) -> Void) {
        let colors: [UIColor] = [
            .colorSelection1, .colorSelection2, .colorSelection3,
            .colorSelection4, .colorSelection5, .colorSelection6,
            .colorSelection7, .colorSelection8, .colorSelection9,
            .colorSelection10, .colorSelection11, .colorSelection12,
            .colorSelection13, .colorSelection14, .colorSelection15,
            .colorSelection16, .colorSelection17, .colorSelection18,
        ]
        super.init(
            items: colors,
            configure: { cell, color, isSelected in
                cell.configure(color: color, isSelected: isSelected)
            },
            onSelect: { color in
                onSelect(color)
            },
            configureHeader: { header in
                guard let header = header as? CollectionHeaderView else { return }
                header.headerLabel.text = L10n.color
            }
        )
    }
}
