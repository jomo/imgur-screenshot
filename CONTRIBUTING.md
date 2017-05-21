# Issues

If the [troubleshooting guide](https://github.com/jomo/imgur-screenshot/wiki/Troubleshooting) and searching [reported issues](https://github.com/jomo/imgur-screenshot/issues) didn't help, please run `imgur-screenshot.sh` with `--debug` as the *first option* in your terminal and paste the output in your issue.

**Make sure to remove all credentials before pasting!**

Please include as many details as possible, so I can reproduce the problem you're having.


# Pull Requests

Please try to adopt the code style already in use.

* Indent using *2 spaces*
* `if ...; then` go in the same line
* The function definition style is `function_name()` (without the `function` prefix)
* Create global variables in uppercase: `declare -g GLOBAL_VARIABLE`
* Create local variables at the function top in lowercase: `local local_variable`
* Comment code that isn't obvious
* Lint your code using [shellcheck](https://github.com/koalaman/shellcheck) before submitting.