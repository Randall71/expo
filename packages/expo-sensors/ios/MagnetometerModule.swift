// Copyright 2023-present 650 Industries. All rights reserved.

import ExpoModulesCore

private let EVENT_MAGNETOMETER_DID_UPDATE = "magnetometerDidUpdate"

public final class MagnetometerModule: Module {
  lazy var operationQueue = OperationQueue()

  public func definition() -> ModuleDefinition {
    Name("ExponentMagnetometer")

    Events(EVENT_MAGNETOMETER_DID_UPDATE)

    AsyncFunction("isAvailableAsync") {
      return motionManager.isMagnetometerAvailable
    }

    AsyncFunction("setUpdateInterval") { (intervalMs: Double) in
      motionManager.magnetometerUpdateInterval = intervalMs
    }

    OnStartObserving {
      if motionManager.isMagnetometerActive {
        return
      }
      motionManager.startMagnetometerUpdates(to: operationQueue) { [weak self] data, error in
        guard let magneticField = data?.magneticField else {
          return
        }
        self?.sendEvent(EVENT_MAGNETOMETER_DID_UPDATE, [
          "x": magneticField.x,
          "y": magneticField.y,
          "z": magneticField.z
        ])
      }
    }

    OnStopObserving {
      motionManager.stopMagnetometerUpdates()
    }

    OnDestroy {
      motionManager.stopMagnetometerUpdates()
    }
  }
}
