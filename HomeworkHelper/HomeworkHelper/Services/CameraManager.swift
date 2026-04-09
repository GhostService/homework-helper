import AVFoundation
import UIKit

final class CameraManager: NSObject, ObservableObject {
    @Published var permissionGranted = false
    @Published var flashOn = false

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.homeworkhelper.camera.session")
    private let photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((UIImage?) -> Void)?

    // MARK: - Setup

    func requestPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sessionQueue.async { self.configureSession() }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { self.permissionGranted = granted }
                if granted { self.sessionQueue.async { self.configureSession() } }
            }
        default:
            DispatchQueue.main.async { self.permissionGranted = false }
        }
    }

    func startSession() {
        sessionQueue.async {
            if !self.session.isRunning { self.session.startRunning() }
        }
    }

    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    func toggleFlash() {
        DispatchQueue.main.async { self.flashOn.toggle() }
    }

    // MARK: - Capture

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        captureCompletion = completion
        sessionQueue.async {
            let settings = AVCapturePhotoSettings()
            if self.photoOutput.supportedFlashModes.contains(.on) {
                settings.flashMode = self.flashOn ? .on : .off
            }
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    // MARK: - Private

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
        session.startRunning()
        DispatchQueue.main.async { self.permissionGranted = true }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard
            error == nil,
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else {
            DispatchQueue.main.async { self.captureCompletion?(nil); self.captureCompletion = nil }
            return
        }
        DispatchQueue.main.async { self.captureCompletion?(image); self.captureCompletion = nil }
    }
}
