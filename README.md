# TTSKit
Text To Speech (TTS) library for Swift

## Overview

TTSKit was developed to solve the problem of intelligibility when synthesizing text. This is often an issue when generating short, single-word utterances without additional context. For example, spelling word drills and other similar use cases are especially troublesome. While the built-in AVFoundation utilities are useful for longer texts with more contextual support, TTSKit focuses on intelligibility over naturalness. TTSKit is based on [CMU Flite](https://github.com/festvox/flite), which is used for synthesis.

## Installation

TTSKit is available as an SPM package.

1. Add TTSKit to your Xcode project by selecting **File, Add Package Dependencies...** and entering the TTSKit GitHub repository URL: ```https://github.com/ameter/TTSKit``` in the search box.

<img src=".images/add_spm_pkg.png" width="400">

2. Select the **Dependency Rule** you want to use.  **Up to Next Major Version** is a good choice to allow non-breaking updates for dependencies that use [semantic versioning](https://semver.org).

3. Click **Add Package**.  Xcode will display the products.  TTSKit ships with 2 products:
- TTSKit - the core library.
- TTSVoiceLibrary - a collection of optional voices.

4. Select your **app's target** for each product you want to add.  For prototyping and development, go ahead and add both products to your app's target.  For additional information on voices, including best practices for production apps, see the [Voices](#voices) section of this README.

<img src=".images/add_products.png" width="400">

5. Click **Add Package**.

## Usage

### Basic Usage

```swift
import TTSKit
...
let tts = TTSKit()
try? tts.speak(text: "Hello, World!")
```

### Playback Controls

By default, `speak(text:)` starts speaking immediately and interrupts any audio that is already playing.  If you want multiple utterances to play back-to-back, use the queueing API.

#### Queueing Speech
Pass `queue: true` to append an utterance to the current playback queue instead of interrupting the one that is already in progress.

```swift
import TTSKit

let tts = TTSKit()

do {
    try tts.speak(text: "The first message starts right away.")
    try tts.speak(text: "This message is queued and will play after the first one finishes.", queue: true)
} catch {
    print("TTS error: \(error)")
}
```

#### Completion Handlers
Use the optional completion handler when you want to update your UI or trigger additional work after an utterance finishes playing.

```swift
import TTSKit

let tts = TTSKit()
try? tts.speak(text: "Hello, World!") {
    print("Finished speaking.")
}
```

#### Pausing and Resuming
Call `pause()` to temporarily halt playback and `resume()` to continue from the paused position.

```swift
tts.pause()
tts.resume()
```

#### Stopping Playback
Call `stop()` to stop the current utterance immediately.  This also clears any queued audio.

```swift
tts.stop()
```

You can also inspect `tts.isPlaying` to drive the enabled state of playback controls in your UI.

### Demo App

See the [Demo App](Examples/TTSKitDemo/TTSKitDemo.xcodeproj) for additional usage examples.  It also provides a quick way to get started with TTSKit and to experiment with different voices.

## Voices

TTSKit ships with built-in male and female voices.  Additional voices are available in the optional `TTSVoiceLibrary` product.  You can also load your own voices.  All **flitevox** compatible voices are supported.  If you do not load a specific voice, the default female voice will be used.

### Loading Voices

There are three different ways to load voices:

#### Built-in Voices:
```swift
import TTSKit
...
let tts = TTSKit()
tts.loadVoice(.male)
```

#### TTSVoiceLibrary Voices:
```swift
import TTSKit
import TTSVoiceLibrary
...
let tts = TTSKit()
try? tts.loadVoice(fromLibrary: .cmuUsRms)
```

#### Other Voices:
```swift
import TTSKit
...
let tts = TTSKit()
if let voiceURL = Bundle.main.url(forResource: "cmu_us_rms", withExtension: "flitevox") {
    try? tts.loadVoice(at: voiceURL)
}
```

### Bundle Size Optimization

For production apps, you should only include the full **TTSVoiceLibrary** if you specifically want to include **all** available voices.  Otherwise, you can decrease your app's bundle size by not including **TTSVoiceLibrary** in your app's target.  If you previously added it, you can remove it by navigating to your **App's Target**, **General**, **Frameworks, Libraries, and Embedded Content**, selecting **TTSVoiceLibrary**, and clicking the **Minus**.

<img src=".images/remove_product.png" width="400">

You can import individual voices by copying the **.flitevox** files into your app and then loading them via the URL.

## Voice Customization

TTSKit exposes voice tuning through `tts.settings`.  Settings are stored on the `TTSKit` instance, applied immediately to the currently loaded voice, and automatically re-applied when you load a different voice later.

```swift
import TTSKit

let tts = TTSKit()
tts.settings.duration = 0.9
tts.settings.shift = 1.05
tts.settings.pitchMean = 160
tts.settings.pitchStdDeviation = 20

try? tts.speak(text: "Customized speech.")
```

### Available Settings

#### `duration`
Controls overall speaking rate by stretching the synthesized duration.

- `1.0` is the default rate.
- Values greater than `1.0` slow speech down.
- Values less than `1.0` speed speech up.

#### `shift`
Scales the voice's pitch contour.

- `1.0` is neutral.
- Values greater than `1.0` raise the perceived pitch.
- Values less than `1.0` lower the perceived pitch.

#### `pitchMean`
Sets the baseline pitch in Hz.  This is useful when you want to move the overall voice higher or lower without changing how much variation it has.

#### `pitchStdDeviation`
Controls how much the pitch varies around `pitchMean`, in Hz.

- Higher values sound more expressive.
- Lower values sound flatter and more even.

#### `substitutionsEnabled`
Enables TTSKit's pronunciation substitutions for short utterances and single words.  This setting defaults to `true` and can improve intelligibility for spelling drills and similar use cases.

```swift
tts.settings.substitutionsEnabled = false
```

### Resetting Settings

Call `clear()` to remove any custom `duration`, `shift`, `pitchMean`, and `pitchStdDeviation` values and return to the voice defaults.  `clear()` does not change `substitutionsEnabled`.

```swift
tts.settings.clear()
```

## Contributing

I ❤️ community contributions.  An effective workflow for library development is to create a workspace (e.g. TTSKit.workspace) **outside** the TTSKit repo folder and then add both the [Demo App](Examples/TTSKitDemo/TTSKitDemo.xcodeproj) and the [TTSKit folder](.) to the workspace.  Please submit [pull requests](https://github.com/ameter/TTSKit/pulls) for any changes you would like to see included in the library. 
