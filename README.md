# iOS Sample Project
August 23rd, 2023

What follows was provided to me by a potential employer. After completing the exercise, I decided to take another offer from a different employer and so this code has sat on my disk collecting dust for a couple of years. I decided to put the work in my repo as a sample. 

This app utilizes the [MovieDB API](https://developer.themoviedb.org) in order to provide a simple movie browser.

Yes, this is two years old, but I updated it with a config file and some minor UI Changes. I also added a mode of behavior where we playback some JSON if the API key is not found in the config file. Note that when playing back the JSON payloads contained in the bundle, we still reach out to the network in order to download and cache movie-poster images. The original requirements specified that `UIKit` was to be preferred over `SwiftUI`. That made sense two years ago but today, I suspect the reverse is true.

Looking at the old code, I realized that I left out a major piece of functionality. We are not handling paging when multiple pages of content are available. I'm certain I would have taken a beating during the interview on that one, assuming it didn't torpedo the possibility of even getting an interview. On the other hand, I may not have been finished when I took the other offer. I honestly can't remember.

August 24th, 2023

I looked into what it would take to add the missing paging functionality and most of the architecture was already in place, so it looks like I was planning to add that code but got interrupted by the better offer. I've added the missing bits needed and we now load in the full result-set as the user scrolls down. There are some caveats.

If the result set is large enough, one could exhaust the available memory for the app, thus causing the runtime to kill it. I have not taken the time to handle this case as this is, after all, a sample app. Potential solutions include (off the top of my head):

1. Watching for the out-of-memory notification, and flushing the oldest page(s) of the movie-list.
2. Implement a circular buffer (list) where the oldest page is automatically overwritten by the newest page once `max-in-memory-pages` has been reached.
3. Use `CoreData` to implement the in-memory cache and wire it up to fetch the data from the back-end, as needed.

I'm sure someone else (perhaps you the reader) has an even better idea. In any case, I'm not going to take this any further. With regard to my original purpose for posting the code in the first place, It is "good enough."

## License
MovieBrowser is released under an MIT license. See [License.md](https://github.com/StateMachineJunkie/MovieBrowser/blob/master/License.md) for more information.
