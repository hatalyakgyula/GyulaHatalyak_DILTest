import UIKit

func isIPhone() -> Bool { 
    return UIDevice.current.userInterfaceIdiom == .phone
}

class someVC: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var detailViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var detailView: UIView!
    
    var detailVC : UIViewController?
    var dataArray : [Any]?
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        self.collectionView.dataSource = self
         self.collectionView.delegate = self 
        self.collectionView.register(UINib(nibName: "someCell", bundle: nil), forCellWithReuseIdentifier: "someCell")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title:NSLocalizedString("Done", comment: ""), style: .plain, target: self, action: #selector(dissmissController))
    }
    
    @objc func dissmissController () {}
    
    func fetchData() {
        let url = URL(string: "testreq")!
        let task = URLSession.shared.dataTask(with: url) { [self] (data, response, error) in
            self.dataArray = data as? [Any]
            self.collectionView.reloadData()
        }
        task.resume()
    }
    
    @IBAction func closeshowDetails() {
        self.detailViewWidthConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) 
        { (completed) in
            self.detailVC?.removeFromParent()
        }
} 
    @IBAction func showDetail() {
        self.detailViewWidthConstraint.constant = 100
        UIView.animate(withDuration: 0.5, animations: {
             self.view.layoutIfNeeded()
        }) 
        { (completed) in
            self.view.addSubview(self.detailView)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var widthMultiplier: CGFloat = 0.2929
        if isIPhone() {
            widthMultiplier = 0.9
        }
        return CGSize(width: view.frame.width * widthMultiplier , height: 150.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let frameWidth = (view.frame.width * 0.2929 * 3) + 84
         var minSpacing: CGFloat = (view.frame.width - frameWidth)/2
        if isIPhone() {
            minSpacing = 24
        }
        return minSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showDetail()
    }
} 







 





