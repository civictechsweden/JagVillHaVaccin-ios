//
//  RemoteConfig.swift
//  ViteMaDose
//
//  Created by Paul on 14/04/2021.
//

import Foundation
import FirebaseRemoteConfig

struct RemoteConfiguration {

    static let shared = RemoteConfiguration()
    let configuration: RemoteConfig

    private init() {
        configuration = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()

        configuration.setDefaults(fromPlist: "remote-configuration")
        settings.minimumFetchInterval = 3600
        configuration.configSettings = settings
    }

    func synchronize(completion: @escaping (Result<Void, Error>) -> Void) {
        configuration.fetch(withExpirationDuration: 0) { _, error in
            if let error = error {
                print("Error while fetching remote configuration (\(error.localizedDescription)).")
                completion(.failure(error))
            } else {
                configuration.activate()
                print("[RemoteConfiguration] Successfully fetched remote configuration.")
                completion(.success(()))
            }
        }
    }
}

// MARK: - Defaults values

extension RemoteConfiguration {
    var baseUrl: String {
        return "https://raw.githubusercontent.com/civictechsweden/JagVillHaVaccin/master"
    }

    var statsPath: String {
        return "/data/output/stats.json"
    }

    var departmentsPath: String {
        return "/departements.json"
    }

    var maintenanceModeUrl: String? {
        let configValue = configuration.configValue(forKey: "ios_maintenance_mode_url").stringValue
        if let value = configValue, !value.isEmpty {
            return configValue
        } else {
            return nil
        }
    }

    var dataDisclaimerEnabled: Bool {
        return configuration.configValue(forKey: "data_disclaimer_enabled").boolValue
    }

    var dataDisclaimerMessage: String? {
        let configValue = configuration.configValue(forKey: "data_disclaimer_message").stringValue
        if let value = configValue, !value.isEmpty {
            return value
        } else {
            return nil
        }
    }

    var vaccinationCentresListRadiusInKm: NSNumber {
        return configuration.configValue(forKey: "vaccination_centres_list_radius_in_km").numberValue
    }

    var chronodoseMinCount: Int {
        return configuration.configValue(forKey: "chronodose_min_count").numberValue.intValue
    }

    var vaccinationCentresListRadiusInMeters: Double {
        return vaccinationCentresListRadiusInKm.doubleValue * 1000
    }

    func departmentPath(withCode code: String) -> String {
        let path = "/{code}.json"
        return path.replacingOccurrences(of: "{code}", with: code)
    }
}
