# catatau

Simple sinatra github webhook that creates and triggers jenkins jobs.

### Configuration

Load the following environment variables:

```
CATATAU_JENKINS_URL
CATATAU_JENKINS_USERNAME
CATATAU_JENKINS_PASSWORD
CATATAU_TEMPLATES=template_job_1,template_job_2,and_so_on
```

and `rackup`.
