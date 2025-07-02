# Support

Looking for help with this repo? You're in the right place!
This guide will walk you through getting the support you need.

> 👉 **Note**: Before participating in our community,
> please read our [Code of Conduct][cocFile].
> By interacting with this repo or community,
> you agree to abide by its terms.

## Asking Quality Questions

Questions, ideas, and suggestions are best handled
in the [Discussions][ghDiscussions].

Help us help you!
Spend time framing questions and add links and resources.
Spending the extra time up front can help save everyone time in the long run.
Here are some tips:

- First, [talk to a duck][rubberDuck]!
- Don’t fall for the [XY problem][xyProblem]
- Search to find out if a similar question has been asked
  - The [Documentation][docsFolder] and [Wiki][ghWiki] are great places to start
  - A [Discussion][ghDiscussions] or [Issue][ghIssues]
    may have already been created that addresses your topic
  - An old-fashioned internet search can also be helpful
- Try to define what you need help with:
  - Is there something in particular you want to do?
  - What problem are you encountering,
    and what steps have you taken to try to fix it?
  - Is there a concept you don’t understand?
- Provide sample code, such as a [CodeSandbox][codeSandbox] or video, if possible
- Screenshots can help, but if there’s important text
  such as code or error messages in them,
  please also provide them as text to make them more searchable
- The more time you put into asking your question, the better we can help you!

## Contributions

See [CONTRIBUTING.md][contribFile] on how to contribute.

## Supported Platforms

This project aims to support a wide range of .NET platforms for compatibility.
To this end, we try to support platforms that implement .NET Standard 2.0 or higher.
However, we **highly recommend** using _only_ the platforms that are
officially supported by Microsoft.

- 🟢 = Fully supported
- 🟡 = Still works, but upgrading is highly recommended
- 🔴 = Not supported _(security vulnerabilities, lack of tool support, etc.)_

| LTS | Platform             | End of<br/>Microsoft Support | .NET Standard<br/>2.0 | .NET Standard<br/>2.1 |
| :-: | :------------------- | ---------------------------: | :-------------------: | :-------------------: |
| ✅  | .NET 10              |            November 14, 2028 |          🟢           |          🟢           |
|     | .NET 9               |                 May 12, 2026 |          🟢           |          🟢           |
| ✅  | .NET 8               |            November 10, 2026 |          🟢           |          🟢           |
|     | .NET 7               |                 May 14, 2024 |          🟡           |          🟡           |
| ✅  | .NET 6               |            November 12, 2024 |          🟡           |          🟡           |
|     | .NET 5               |                 May 10, 2022 |          🟡           |          🟡           |
|     | .NET Core 3.1        |            December 13, 2022 |          🟡           |          🟡           |
|     | .NET Core 3.0        |                March 3, 2020 |          🔴           |          🔴           |
|     | .NET Core 2.2        |            December 23, 2019 |          🔴           |          N/A          |
|     | .NET Core 2.1        |              August 21, 2021 |          🔴           |          N/A          |
|     | .NET Core 2.0        |              October 1, 2018 |          🔴           |          N/A          |
|     | .NET Core 1.1        |                June 27, 2019 |          N/A          |          N/A          |
|     | .NET Core 1.0        |                June 27, 2019 |          N/A          |          N/A          |
|     | .NET Framework 4.8.1 |               _\<see note\>_ |          🟢           |          N/A          |
|     | .NET Framework 4.8   |               _\<see note\>_ |          🟢           |          N/A          |
|     | .NET Framework 4.7.2 |               _\<see note\>_ |          🟢           |          N/A          |
|     | .NET Framework 4.7.1 |               _\<see note\>_ |          🟢           |          N/A          |
|     | .NET Framework 4.7   |               _\<see note\>_ |          🟢           |          N/A          |
|     | .NET Framework 4.6.2 |             January 12, 2027 |          🟢           |          N/A          |
|     | .NET Framework 4.6.1 |                 Apr 26, 2022 |          🔴           |          N/A          |
|     | .NET Framework 4.6   |                 Apr 26, 2022 |          N/A          |          N/A          |
|     | .NET Framework 4.5.2 |                 Apr 26, 2022 |          N/A          |          N/A          |
|     | .NET Framework 4.5.1 |                 Jan 12, 2016 |          N/A          |          N/A          |
|     | .NET Framework 4.5   |                 Jan 12, 2016 |          N/A          |          N/A          |

> [!NOTE]
> .NET Framework 4.6.2 and later are supported as long as they're on a supported
> Windows OS.

More information about supported platforms can be found here:

- [.NET Core & .NET][netCore] support policies
- [.NET Standard][netStandard] implementation
- [.NET Framework][netFramework] support policies
- [Microsoft Product & Service Lifecycle information][winLifecycle] (search page)
  - [Windows 10 Home and Pro][winHomePro] release support
  - [Windows Server][winServer] release support

## Attribution

This document was shamelessly stolen and modified
from the [Remark][remark] repo.

<!-- Source Code URIs (alphabetical by file hierarchy) -->

[docsFolder]: ./docs/
[cocFile]: ./CODE_OF_CONDUCT.md
[contribFile]: ./CONTRIBUTING.md

<!-- GitHub Repo URIs (alphabetical by name) -->

[ghDiscussions]: https://github.com/TaffarelJr/.template-nuget/discussions
[ghIssues]: https://github.com/TaffarelJr/.template-nuget/issues
[ghWiki]: https://github.com/TaffarelJr/.template-nuget/wiki

<!-- Public URIs (alphabetical by name) -->

[codeSandbox]: https://codesandbox.io
[netCore]: https://dotnet.microsoft.com/platform/support/policy/dotnet-core
[netFramework]: https://docs.microsoft.com/en-us/lifecycle/products/microsoft-net-framework
[netStandard]: https://docs.microsoft.com/en-us/dotnet/standard/net-standard
[remark]: https://github.com/remarkjs/.github/blob/main/support.md
[rubberDuck]: https://rubberduckdebugging.com
[winHomePro]: https://docs.microsoft.com/en-us/lifecycle/products/windows-10-home-and-pro
[winLifecycle]: https://docs.microsoft.com/en-us/lifecycle/products
[winServer]: https://docs.microsoft.com/en-us/lifecycle/products/windows-server
[xyProblem]: https://meta.stackexchange.com/questions/66377/what-is-the-xy-problem/66378#66378
