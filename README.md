# `drone-gitea-comment`

This is a basic Docker image that allows you to leave comments in Gitea pull
requests from Drone pipelines, on success or failure. I didn't like existing
alternatives because the program itself is super simple, and they pulled in
heavy runtimes such as .NET to run just a couple of dozen lines of code.

## Usage

Pick a user that will leave comments in your PRs. Go to User Settings →
Applications → Manage Access Tokens.

Create a new token that has only one permission: "issue: Read and Write".

Add this token as a secret in your Drone repo configuration.

Add one of the statements below to your `.drone.yml`.

### Notify of both success and failure

```yaml
- name: comment
  image: ghcr.io/hg/gitea-comment:v1
  environment:
    GITEA_BASE: https://gitea.example.com
    GITEA_TOKEN: { from_secret: GITEA_TOKEN } # add as secret in drone repo configuration
    SUCCESS_MESSAGE: "✅ Build finished [successfully]($DRONE_BUILD_LINK)."
    FAILURE_MESSAGE: "🚫 Build finished with [errors]($DRONE_BUILD_LINK)."
    MESSAGE: |
      This is a generic message that will be used regardless of pipeline
      execution status. If you use this property, omit SUCCESS_MESSAGE and
      FAILURE_MESSAGE, or the stage will fail and nothing will get posted.
  when:
    status: [success, failure]
    event: pull_request
```

### Notify of failure

```yaml
- name: notify of failure
  image: ghcr.io/hg/gitea-comment:v1
  environment:
    GITEA_BASE: https://gitea.example.com
    GITEA_TOKEN: { from_secret: GITEA_TOKEN }
    MESSAGE: |
      Build №$DRONE_BUILD_NUMBER has failed.
      Please look [here]($DRONE_BUILD_LINK) for more information.
  when:
    status: [failure]
    event: pull_request
```

### Notify of success

```yaml
- name: notify of success
  image: ghcr.io/hg/gitea-comment:v1
  environment:
    GITEA_BASE: https://gitea.example.com
    GITEA_TOKEN: { from_secret: GITEA_TOKEN }
    MESSAGE: "Build №$DRONE_BUILD_NUMBER finished [successfully]($DRONE_BUILD_LINK)."
  when:
    event: pull_request
```

## Message text

Use **either** `MESSAGE` **or** `SUCCESS_MESSAGE` + `FAILURE_MESSAGE`. The
first one will post the same comment regardless of how the pipeline executes up
to that point. The other two will pick the appropriate message based on the
pipeline status.

If both `MESSAGE` and any of the other two are used, the stage will fail.

Any of the three variables can contain either the text itself or the path to a
text file whose contents will be used as the comment body:

```sh
# somewhere during the build process
echo 'execution failed' >build.log
```

```yaml
# .drone.yml
SUCCESS_MESSAGE: "build finished ok"
FAILURE_MESSAGE: build.log
```
