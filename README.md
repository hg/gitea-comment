# `drone-gitea-comment`

This is a basic Docker image that allows you to leave comments in Gitea or
Forgejo pull requests from Drone or Woodpecker pipelines, on success or
failure. I didn't like existing alternatives because the program itself is
super simple, and they pulled in heavy runtimes such as .NET to run just a
couple of dozen lines of code.

## Usage

Pick a user that will leave comments in your PRs. Go to User Settings →
Applications → Manage Access Tokens.

Create a new token that has only one permission: "issue: Read and Write".

Add this token as a secret in your Drone/Woodpecker repo configuration.

Add one of the statements below to your `.drone.yml` / `.woodpecker.yml`.

`GITEA_BASE` can be omitted under Woodpecker.

### Notify of both success and failure

```yaml
- name: comment
  image: ghcr.io/hg/gitea-comment:v2
  commands:
    - comment
  environment:
    GITEA_BASE: https://gitea.example.com
    GITEA_TOKEN: { from_secret: GITEA_TOKEN } # add as a secret in CI repo configuration
    SUCCESS_MESSAGE: "✅ Build finished [successfully]($CI_PIPELINE_URL)."
    FAILURE_MESSAGE: "🚫 Build finished with [errors]($CI_PIPELINE_URL)."
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
  image: ghcr.io/hg/gitea-comment:v2
  environment:
    GITEA_BASE: https://gitea.example.com
    GITEA_TOKEN: { from_secret: GITEA_TOKEN }
    MESSAGE: |
      Workflow $CI_WORKFLOW_NAME has failed.
      Please look [here]($CI_PIPELINE_URL) for more information.
  when:
    status: [failure]
    event: pull_request
```

### Notify of success

```yaml
- name: notify of success
  image: ghcr.io/hg/gitea-comment:v2
  environment:
    GITEA_BASE: https://gitea.example.com
    GITEA_TOKEN: { from_secret: GITEA_TOKEN }
    MESSAGE: "Pipeline $CI_PIPELINE_NUMBER finished [successfully]($CI_PIPELINE_URL)."
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
