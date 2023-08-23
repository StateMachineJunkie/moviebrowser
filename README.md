# iOS Sample Project
August 23rd, 2023

What follows was provided to me by a potential employer. After completing the exercise, I decided to take another offer from a different employer and so this code has sat on my disk collecting dust for a couple of years. I decided to put the work in my repo as a sample. 

This app utilizes the [MovieDB API](https://developer.themoviedb.org) in order to provide a simple movie browser.

Yes, this is two years old but I updated it with a config file and some minor UI Changes. I also added a mode of behavior where we playback some JSON if the API key is not found in the config file. Note that when playing back the JSON payloads contained in the bundle, we still reach out to network in order to download and cache movie-poster images. The original requirements specified that `UIKit` was to be preferred over `SwiftUI`. That made sense two years ago but today, I suspect the reverse is true.

Looking at the old code, I realized that I left out a major piece of functionality. We are not handling paging when multiple pages of content are available. I'm certain I would have taken a beating during the interview on that one, assuming it didn't torpedo the possibility of even getting an interview. On the other hand, I may not have been finished when I took the other offer. I honestly can't remember.

## License
MovieBrowser is released under an MIT license. See [License.md](https://github.com/StateMachineJunkie/MovieBrowser/blob/master/License.md) for more information.
