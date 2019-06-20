# Basics

Normal

```pwsh
./build.ps1 -target build
```

Test manual

```pwsh
docker build .
```

Test manual w/ proxy

```pwsh
docker build --build-arg HTTP_PROXY= .
docker build --build-arg HTTP_PROXY=http://10.0.75.1:3128 .
```
