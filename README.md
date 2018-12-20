# NTNU Lectures Server

A small server project that makes it simple to query different lectures.

## GET /recordings

Returns a list of lectures

### Parameters
cursor - Int value that "skipes" the n-th first values
amount - Int value that controls the maximum amount of recordings
lector - String value. Filter recordings on lector
subject - String value. Filter on subject code

### Example response

```json
[
    {
        "lector": "Jo Sterten",
        "title": "3 DTEC T",
        "combinedMediaUrl": "https://forelesning.gjovik.ntnu.no/1544710861-ed4d757943ac/combined.mp4",
        "screenUrl": "https://forelesning.gjovik.ntnu.no/1544710861-ed4d757943ac/screen.mp4",
        "duration": 105,
        "subject": "TEK3106",
        "cameraUrl": "https://forelesning.gjovik.ntnu.no/1544710861-ed4d757943ac/camera.mp4",
        "startDate": "2018-12-13T13:03:00Z",
        "audioUrl": "https://forelesning.gjovik.ntnu.no/1544710861-ed4d757943ac/audio.mp3",
        "id": 1,
        "info": "Muntlig fremføring"
    },
    ...
]
```

## GET /lectores

Returns all lectores

### Example response

```json
[
    {
        "lector": "Robin Sommer"
    },
    ...
]
```

## GET /subjects

Returns all subjects

### Example response

```json
[
    {
        "subject": "IMT1021"
    },
    ...
]
```
