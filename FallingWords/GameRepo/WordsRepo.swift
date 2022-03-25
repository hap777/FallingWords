//
//  GamesRepo.swift
//  FallingWords
//
//  Created by Hossein Asadi on 3/24/22.
//

import Foundation

protocol WordsRepo {
    func fetchWords(completion: @escaping (Result<[Word], Error>) -> Void)
}

class LocalWordsRepo: WordsRepo {
    private let bundle: Bundle

    init(bundle: Bundle = Bundle.main) {
        self.bundle = bundle
    }

    func fetchWords(completion: @escaping (Result<[Word], Error>) -> Void) {
        guard let url = bundle.url(forResource: "words", withExtension: ".json") else { return }
        do {
            let data = try Data(contentsOf: url)
            let words = try JSONDecoder().decode([Word].self, from: data)
            completion(.success(words))
        } catch {
            completion(.failure(error))
        }
    }
}
