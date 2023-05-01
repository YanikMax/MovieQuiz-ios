import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get set }
    
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, totalAccuracy
    }
    
    private var _totalAccuracy: Double
    private var _gamesCount: Int
    private var _bestGame: GameRecord
    
    init() {
        self._totalAccuracy = userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
        self._gamesCount = userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        if let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
           let bestGame = try? JSONDecoder().decode(GameRecord.self, from: data) {
            self._bestGame = bestGame
        } else {
            self._bestGame = GameRecord(correct: 0, total: 0, date: Date())
        }
    }
    
    var totalAccuracy: Double {
        get {
            return self._totalAccuracy
        }
        set {
            self._totalAccuracy = newValue
            userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            return self._gamesCount
        }
        set {
            self._gamesCount = newValue
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
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
        let totalCorrect = Double(userDefaults.integer(forKey: Keys.correct.rawValue)) + Double(count)
        let totalAmount = Double(userDefaults.integer(forKey: Keys.total.rawValue)) + Double(amount)
        totalAccuracy = (totalCorrect / totalAmount) * 100 // вычисление средней точности
        userDefaults.set(Int(totalCorrect), forKey: Keys.correct.rawValue)
        userDefaults.set(Int(totalAmount), forKey: Keys.total.rawValue)
        gamesCount += 1 //увеличение отыгранных квизов
        let newGameRecord = GameRecord(correct: count, total: amount, date: Date()) //создание нового экземпляра GameRecord
        if bestGame < newGameRecord { //здесь происходит проверка на результат и если он лучше, то сохраняем его в bestGame
            bestGame = newGameRecord
        }
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
