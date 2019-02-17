//import Alamofire
//import SwiftyJSON
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet var tableView: UITableView!
    
    
    struct Book {
        var title = String()
        var author = String()
        var price = Float()
        var isbn = String()
        var condition: Condition
        
        enum Condition {
            case New
            case Great
            case Good
            case Fair
            case Poor
        }
    }
    
    var books = [Book(title:"book1", author:"a", price:2.24 , isbn: "isbn1",  condition: Book.Condition.New),
                 Book(title:"book2",author:"b",price: 21.24 ,isbn: "isbn2",  condition: Book.Condition.New),
                 Book(title:"book3",author:"c",price: 24.24 ,isbn: "isbn3",  condition: Book.Condition.New),
                 Book(title:"book4",author:"d",price: 26.24 ,isbn: "isbn4",  condition: Book.Condition.New)]
    
    var filteredBooks = [Book]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredBooks = []
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let tap = UITapGestureRecognizer(target: self, action: Selector(("tapFunction:")))
        
  /*      let button = UIButton(frame: CGRect(x: 100, y: 400, width: 200, height: 100))
        button.backgroundColor = .green
        button.setTitle("Price", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        buttonAction(sender: button)
        self.view.addSubview(button)
 */
    }
    
    @IBAction func price(_ sender: Any) {
        guard let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json") else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                //here dataResponse received from a network request
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                print(jsonResponse) //Response result
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
        
        
    }
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
        
    }
    
    func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // If we haven't typed anything into the search bar then do not filter the results
        if searchController.searchBar.text! == "" {
            filteredBooks = []
        } else {
            // Filter the results
            filteredBooks = books.filter { $0.title.lowercased().contains(searchController.searchBar.text!.lowercased()) } + books.filter  { $0.author.lowercased().contains(searchController.searchBar.text!.lowercased()) } + books.filter  { $0.isbn.lowercased().contains(searchController.searchBar.text!.lowercased()) }
            
        }
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell     {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = self.filteredBooks[indexPath.row].title
        cell.detailTextLabel?.text = self.filteredBooks[indexPath.row].author
        //cell.detailTextLabel?.text = self.filteredBooks[indexPath.row].condition
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row \(indexPath.row) selected")
    }
    
    
}

/*import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var labelHeader: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var filteredBooks = [Book]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url = Bundle.main.url(forResource: "response", withExtension: "json")
        
        guard let jsonData = url
            else{
                print("data not found")
                return
        }
        
        guard let data = try? Data(contentsOf: jsonData) else { return }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else{return}
        
        if let dictionary = json as? [String: Any] {
            
            if let title = dictionary["title"] as? String {
                labelHeader.text = title
            }
            
            if let year = dictionary["year"] as? Double {
                print("Year is \(year)")
            }
            if let more_info = dictionary["more_info"] as? Double {
                //This doesn't get printed.
                print("More_info is \(more_info)")
            }
            
            for (key, value) in dictionary {
                print("Key is: \(key) and value is \(value)" )
            }
            
        }
        
        //Now lets populate our TableView
        let newUrl = Bundle.main.url(forResource: "marvel", withExtension: "json")
        
        guard let j = newUrl
            else{
                print("data not found")
                return
        }
        
        guard let d = try? Data(contentsOf: j)
            else { print("failed")
                return
                
        }
        
        guard let rootJSON = try? JSONSerialization.jsonObject(with: d, options: [])
            else{ print("failedh")
                return
                
        }
        
        if let JSON = rootJSON as? [String: Any] {
            labelHeader.text = JSON["title"] as? String
            
            guard let jsonArray = JSON["movies"] as? [[String: Any]] else {
                return
            }
            
            print(jsonArray)
            let name = jsonArray[0]["name"] as? String
            print(name ?? "NA")
            print(jsonArray.last!["year"] as? Int ?? 1970)
            
            for json in jsonArray
            {
                guard let title = json["code"] as? String else{ return }
                guard let price = json["rate_float"] as? Float else{ return }
                guard let author = json["description"] as? String else{ return }
                guard let isbn = json["symbol"] as? String else{ return }
               // guard let condition = json["symbol"] as? String else{ return }
                filteredBooks.append(Book(title: title, author: author, price: price ,isbn: isbn))
            }
            
            self.tableView.reloadData()
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBooks.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentBook = filteredBooks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = currentBook.title
        cell.detailTextLabel?.text = "\(currentBook.author)"
        return cell
    }
    
}

func Button(sender: Any) {
    let url = Bundle.main.url(forResource: "response", withExtension: "json")
    
    guard let jsonData = url
        else{
            print("data not found")
            return
    }
    
    guard let data = try? Data(contentsOf: jsonData) else { return }
    
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else{return}
    
    if let dictionary = json as? [String: Any] {
        
        if let title = dictionary["title"] as? String {
            labelHeader.text = title
        }
        
        if let year = dictionary["year"] as? Double {
            print("Year is \(year)")
        }
        if let more_info = dictionary["more_info"] as? Double {
            //This doesn't get printed.
            print("More_info is \(more_info)")
        }
        
        for (key, value) in dictionary {
            print("Key is: \(key) and value is \(value)" )
        }
        
    }
    
    //Now lets populate our TableView
    let newUrl = Bundle.main.url(forResource: "marvel", withExtension: "json")
    
    guard let j = newUrl
        else{
            print("data not found")
            return
    }
    
    guard let d = try? Data(contentsOf: j)
        else { print("failed")
            return
            
    }
    
    guard let rootJSON = try? JSONSerialization.jsonObject(with: d, options: [])
        else{ print("failedh")
            return
            
    }
    
    if let JSON = rootJSON as? [String: Any] {
        labelHeader.text = JSON["title"] as? String
        
        guard let jsonArray = JSON["movies"] as? [[String: Any]] else {
            return
        }
        
        print(jsonArray)
        let name = jsonArray[0]["name"] as? String
        print(name ?? "NA")
        print(jsonArray.last!["year"] as? Int ?? 1970)
        
        for json in jsonArray
        {
            guard let title = json["code"] as? String else{ return }
            guard let price = json["rate_float"] as? Float else{ return }
            guard let author = json["description"] as? String else{ return }
            guard let isbn = json["symbol"] as? String else{ return }
            // guard let condition = json["symbol"] as? String else{ return }
            filteredBooks.append(Book(title: title, author: author, price: price ,isbn: isbn))
        }
        
        self.tableView.reloadData()
}

struct Book {
    var title = String()
    var author = String()
    var price = Float()
    var isbn = String()
   // var condition: Condition
    
    enum Condition {
        case New
        case Great
        case Good
        case Fair
        case Poor
    }
}


*/
