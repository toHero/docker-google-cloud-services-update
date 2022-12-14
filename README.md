# Bitbucket Pipelines Pipe: Google Cloud Services Update

Update google cloud platform services (Cloud Tasks, Cloud Scheduler, Datastore)

## Prerequisites

* An IAM user is configured with sufficient permissions to perform an update of your gcloud services.
* You have [enabled APIs and services](https://cloud.google.com/service-usage/docs/enable-disable) needed for your application.

## YAML Definition

Add the following snippet to the script section of your `bitbucket-pipelines.yml` file:

```yaml
script:
  - pipe: docker://tohero/google-cloud-services-update:latest
    variables:
      KEY_FILE: '<string>'
      PROJECT:  '<string>'
      # SERVICES: '<string>' # Optional.
      # CONFIG_FILES_DIR: '<string>' # Optional.
      # DEBUG: '<boolean>' # Optional.
```

## Variables

| Variable               | Usage                                                                                                                                                                        |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| KEY_FILE (*)           | base64 encoded content of Key file for a [Google service account][Google service account]. To encode this content, follow [encode private key doc][encode-string-to-base64]. |
| PROJECT (*)            | The Project ID of the project that owns the app to deploy.                                                                                                                   |
| SERVICES               | List of google cloud services to update. Default `'cloud-tasks cloud-scheduler datastore'`                                                                                   |
| CONFIG_FILES_DIR       | Directory containing all required files for services update. Default `build`.                                                                                                |
| DEBUG                  | Turn on extra debug information. Default `false`.                                                                                                                            |

_(*) = required variable._

### Available Services

> Select the services to update using the optional variable `SERVICES` (services keys seperated by space)

| Service         | Key             | Required file | Usage                                              |
|-----------------|-----------------|---------------|----------------------------------------------------|
| Cloud Tasks     | cloud-tasks     | `queue.yaml`  | Update google cloud tasks queues configuration     |
| Cloud Scheduler | cloud-scheduler | `cron.yaml`   | Deploy google app engine cron table configuration  |
| Datastore       | datastore       | `index.yaml`  | Deploy datastore indexes + cleanup removed indexes |

#### Example (Update only Cloud Tasks and Cloud Scheduler)
```yaml
script:
  - pipe: docker://tohero/google-cloud-services-update:latest
    variables:
      KEY_FILE: $KEY_FILE
      PROJECT: 'my-project'
      SERVICE: 'cloud-tasks cloud-scheduler'
```

## Examples

Basic example:

```yaml
script:
  - pipe: docker://tohero/google-cloud-services-update:latest
    variables:
      KEY_FILE: $KEY_FILE
      PROJECT: 'my-project'
```

Advanced example:

```yaml
script:
  - pipe: docker://tohero/google-cloud-services-update:latest
    variables:
      KEY_FILE: $KEY_FILE
      PROJECT: 'my-project'
      SERVICES: 'datastore'             # Only the specified services will be updated
      CONFIG_FILES_DIR: 'war/WEB_INF'   # Custom path for required config files
      DEBUG: "true"
```

## Deployment
```shell
docker build -t tohero/google-cloud-services-update .
docker push tohero/google-cloud-services-update
``` 

## Support
If you’d like help with this pipe, or you have an issue or feature request, let us know.
The pipe is maintained by tohero.

If you’re reporting an issue, please include:

- the version of the pipe
- relevant logs and error messages
- steps to reproduce

## License
Apache 2.0 licensed, see [LICENSE](LICENSE.txt) file.

[encode-string-to-base64]: https://confluence.atlassian.com/bitbucket/use-ssh-keys-in-bitbucket-pipelines-847452940.html#UseSSHkeysinBitbucketPipelines-UsemultipleSSHkeysinyourpipeline
[gcloud components]: https://cloud.google.com/sdk/docs/components#additional_components
[Google service account]: https://cloud.google.com/iam/docs/creating-managing-service-account-keys
