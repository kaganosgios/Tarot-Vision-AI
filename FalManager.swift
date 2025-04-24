import Foundation
class FalManager: ObservableObject {
    @Published var secilenFal: String?
    @Published var falList: [String: String] = [:]
    func falID(for selectedDate: String) -> String? {
        let foundID = falList[selectedDate]
        print(" falID(for:) çağrıldı: Tarih: \(selectedDate)  falidd: \(foundID ?? "Bulunamadı")")
        return foundID
    }
}
