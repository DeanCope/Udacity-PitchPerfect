# Udacity-PitchPerfect
This is the second assignment for the Udacity Nanodegree.
It allows the user to record their voice and play it back with various "sound effects" (changes in pitch, 
speed, echo or reverb.)

The part of the code that does the audio setup and recording (extension PlaySoundsViewController: AVAudioPlayerDelegate) 
was provided by Udacity.

The app has two pages inside of a Navigation Controller.
Both pages use stack views to arrange the UI elements.
It uses a couple of Alerts.

It took a bit of work to get the UI to look right on all devices and orientations.  (e.g. squashing butttons, clipping text)
I learned to use, for example, "snailButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit" to 
prevent the images from getting "squashed" when in landscape mode.

One "tricky" part was causing the segue to happen after the recording is finished, instead of right away when
the user taps "Stop".  To do this, I had to implement the AVAudioRecorderDelegate Method: audioRecorderDidFinishRecording
and do the segue there.

The Udacity reviewer helped with advice on avoiding repetitive code for enabling/disabling buttons in the various modes.
