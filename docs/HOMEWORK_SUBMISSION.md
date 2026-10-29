# gRPC homework — submission checklist

## GitHub

https://github.com/Leonid328/libratrack-grpc

## Requirements covered

| Points | Evidence |
|--------|----------|
| Presentation examples on PC (70) | `make test`, `make smoke`, `docs/screenshots/` |
| Unary + streaming RPC (+30) | `01-unary-getcopy.txt`, `02-server-streaming-watch.txt`, `03-client-streaming-bulk.txt` |
| SonarQube Cloud (**) | `.github/workflows/sonarcloud.yml` — add `SONAR_TOKEN` in repo secrets, run workflow, attach dashboard screenshot |

## Reproduce locally

```bash
make test
make smoke
bash scripts/capture-homework-demos.sh
```

## Screenshots / video

Upload folder `docs/screenshots/` to Google Drive and link in the LMS.
