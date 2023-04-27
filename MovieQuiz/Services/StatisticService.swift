import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get set } //здесь указал дополнительно set для сохранения значения
    
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private var _totalAccuracy: Double = 0.0
    private var _gamesCount: Int = 0
    
    var totalAccuracy: Double {
        get {
            return self._totalAccuracy
        }
        set {
            self._totalAccuracy = newValue
        }
    }
    
    var gamesCount: Int {
        get {
            return self._gamesCount
        }
        set {
            self._gamesCount = newValue
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let accuracy = Double(count) / Double(amount) * 100.0 //вычисление точности
        totalAccuracy = (totalAccuracy * Double(gamesCount) + accuracy) / Double(gamesCount + 1) //вычисление средней точности
        gamesCount += 1 //увеличение отыгранных квизов
        let newGameRecord = GameRecord(correct: count, total: amount, date: Date()) //создание нового экземпляра GameRecord
        if bestGame < newGameRecord { //здесь происходит проверка на результат и если он лучше, то сохраняем его в bestGame
            bestGame = newGameRecord
        }
        let formattedAccuracy = String(format: "%.2f", accuracy)
    }
    
}

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func <(lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct
    }
}
