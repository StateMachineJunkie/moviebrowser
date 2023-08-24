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

## Theory of Operation
Understanding how the view-model works is important so I've drawn you a little state-machine diagram.

![MovieList State Machine](MovieListFSM.pdf)

The states are as follows:

* **idle:** No activity; any data, if present is available for rendering by any observer. On entry to this state, if data is available, it will be displayed to the user. If there is no data then `NO DATA` will be displayed to the user.
* **isLoadingConfig:** We have issued a network request to `MovieDB` in order to fetch the configuration, which is mainly used for fetching and displaying images (movie posters) associated with the results of a `MovieDB` query. This configuration is useful for making the most of the display canvas but I don't use it for that purpose since this is a sample app.
* **configLoadFailure:** This is an error state. If entered, the app is dead-in-the-water. This should not normally happen and we don't do much but report the result to the console and just sit there. In a real app, you would need to handle this in a more robust way, perhaps notifying the user and then telling them to try again later, assuming the error was not the result of an internal (programmer) error.
* **isSearching:** The user has entered a search-term into the input text-field and tapped the `GO` or `search` buttons. On entry to this state, we issue a `MovieDB` request with the search term and the registered user's API key as arguments. We will remain in this state until the request completes or times-out. At that time we will transition back to the **idle** state with the results of the API call. If not successful, the transition to **idle** will still occur and an error is logged to the console. The UI is not updated and the last results, if any will still be displayed.
* **isFetching:** After the successful load of the first page of a given data-set, which is created by a search operation, the user can trigger a transition into this state by scrolling to the end of the displayed results, assuming more data is available. On entry to this state, we issue a `MovieDB` request to fetch the next page of the data-set. We will remain in this state until that request completes or times-out. At that time we will transition back to the **idle** state with the results of the API call appended to the existing result-set. If not successful, the transition to **idle** will still occur and an error is logged to the console. The UI is not updated and the last results, if any will still be displayed.

To be sure, there are details that are not included here but the goal is to give you a high-level understanding about how the app works.

## License
MovieBrowser is released under an MIT license. See [License.md](https://github.com/StateMachineJunkie/MovieBrowser/blob/master/License.md) for more information.
