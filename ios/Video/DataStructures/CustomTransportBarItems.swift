
struct BarAction {
    let title: String
    let iconSystemName: String
    
    let type: String?
    let state: Bool?
    let activeIconSystemName: String?
    
    let json: NSDictionary?
    
    init(_ json: NSDictionary!) {
        guard json != nil else {
            self.json = nil
            self.title = ""
            self.iconSystemName = ""
            
            self.type = nil
            self.state = nil
            self.activeIconSystemName = nil
            return
        }
        self.json = json
        self.title = json["title"] as? String ?? ""
        self.iconSystemName = json["iconSystemName"] as? String ?? ""
        self.type = json["type"] as? String
        self.state = json["state"] as? Bool
        self.activeIconSystemName = json["activeIconSystemName"] as? String
    }
}

struct BarMenu {
    let children: [TransportBarItem]
    
    let json: NSDictionary?
    
    init(_ json: NSDictionary!) {
        guard json != nil else {
            self.json = nil
            self.children = []
            return
        }
        self.json = json
        let childrenItem = json["children"] as? [NSDictionary]
        self.children = childrenItem?.map({ item in
            if item["children"] != nil {
                return TransportBarItem.barMenu(BarMenu(item))
            }
            return TransportBarItem.barItem(BarAction(item))
        }) ?? []
    }
}

enum TransportBarItem {
    case barItem(BarAction)
    case barMenu(BarMenu)
}
