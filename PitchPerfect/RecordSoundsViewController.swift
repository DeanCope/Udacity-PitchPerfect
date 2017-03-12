//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Dean Copeland on 3/10/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    var audioRecorder: AVAudioRecorder!
    
    // These are the states that we can be in with respect to recording.
    // The raw value for each state holds the message to display to the user in the recordingLabel
    enum RecordingState: String {
        case stopped = "Tap to Record"
        case recording = "Recording in Progress"
        case paused = "Recording is Paused"
    }
    
    var recordingState = RecordingState.stopped {
        didSet{
            // whenever the state is changed, update the UI (label and enable/disable buttons)
            recordingLabel.text = recordingState.rawValue
            
            switch(recordingState) {
            case .stopped:
                setUIState(isRecording: false, pauseColor: UIColor.white)
            case .recording:
                setUIState(isRecording: true, pauseColor: UIColor.white)
            case .paused:
                setUIState(isRecording: true, pauseColor: UIColor.red)
            }
        }
    }
    
    func setUIState(isRecording: Bool, pauseColor: UIColor) {
        recordButton.isEnabled = !isRecording
        stopRecordingButton.isEnabled = isRecording
        pauseResumeButton.isEnabled = isRecording
        pauseResumeButton.imageView?.backgroundColor = pauseColor
    }
    
    // MARK: - Outlets
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var pauseResumeButton: UIButton!
    
    struct Storyboard {
        static let stopRecordingSegueId = "stopRecording"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingState = .stopped
        
        // Prevent the images from being "squashed" in landscape on small screens
        recordButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        stopRecordingButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        pauseResumeButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    }

    // MARK: - Actions
    @IBAction func recordAudio(_ sender: Any) {
        recordingState = .recording
    
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        //print("Audio filePath: \(filePath)")
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func stopRecording(_ sender: Any) {
        recordingState = .stopped
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        // There an be a lag between the time we call "stop" and the when the audio file is ready,
        // so we don't segue here.  We need to wait for the audioRecorder to call
        // the "audioRecorderDidFinishRecording" function below.
    }
    
    @IBAction func pauseOrResume(_ sender: Any) {
        // The pause button is a toggle
        switch(recordingState) {
        case .recording:
            audioRecorder.pause()
            recordingState = .paused
        case .paused:
            audioRecorder.record()
            recordingState = .recording
        default: break
            // Ignore if stopped (should not happen because button is disabled)
        }
    }
    
    // MARK: - AVAudioRecorderDelegate Methods
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: Storyboard.stopRecordingSegueId, sender: audioRecorder.url)
        } else {
            //print("Recording error occurred.")
            showAlert("Audio File Error", message: "Error creating audio file")
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let message = error?.localizedDescription {
            showAlert("Recording Error", message: message)
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.stopRecordingSegueId {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}

