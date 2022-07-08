<!--
*** Thanks for checking out this README Template. If you have a suggestion that would
*** make this better, please fork the repo and create a pull request or simply open
*** an issue with the tag "enhancement".
*** Thanks again! Now go create something AMAZING! :D
***
***
***
*** To avoid retyping too much info. Do a search and replace for the following:
*** github_username, repo, twitter_handle, email
-->


<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project
This is a Kwin Script to tile windows by clicking in a grid. For now, its a [Divvy](https://mizage.com/divvy/) clone from Mac Osx in KDE.

<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

This was tested in the following settings. If you try it in another and it works, let me know so i can put it here.

* Plasma 5.24.4
* KDE Frameworks 5.92.0
* Qt 5.15.3


### Installation

1. Download the release file
2. Load it from *System Settings -> Window Management -> KWin Scripts -> Install from file*
3. You could change the number of columns and rows from the settings.
4. The default shortcut is *Meta+Ctrl+D*. If you dont like it, you could change it from *System Settings -> Shortcuts -> Kwin -> Manual Tiling*

<!-- USAGE EXAMPLES -->
## Usage
[First Prototype](https://user-images.githubusercontent.com/814791/177024333-dd5e8175-f091-41b8-ab46-2ed49185ffe8.mp4)

https://user-images.githubusercontent.com/814791/178079470-98b6f75a-cf18-4def-b0f2-d4ec025dea9b.mp4

Press the assigned shortcut and the applet will be shown. On the right, you could choose the window to tile clicking it. It would bring it to focus. On the left, click on a grid square, then on another, and the window will be resized to fit that space. Do the same for another one. When you are done, press the assigned shortcut again to hide it.

The icons on the grid are merely decorative, you could still click on the squares, *but would you?*

Opening and closing the applet will clean the grid, the idea is to launch it, arrange the windows and then forget about it. I dont want to force already placed windows into a made up grid.

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/pudymody/kde-manual-tiling/issues) for a list of proposed features (and known issues).

<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

Thanks to this for letting me read scripting code, and understand better some things.
* [Desktop change OSD](https://invent.kde.org/plasma/kwin/-/blob/master/src/scripts/desktopchangeosd/contents/ui/osd.qml)
* [Parachute](https://github.com/tcorreabr/Parachute)

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request



<!-- LICENSE -->
## License

Distributed under the GPL-3.0 License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

[Federico Scodelaro](https://pudymody.netlify.com) - [@pudymody](https://twitter.com/pudymody) - federicoscodelaro@gmail.com
