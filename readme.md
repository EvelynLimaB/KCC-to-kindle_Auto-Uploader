# KCC-to-Kindle Autouploader

Automatically convert `.cbz` manga/comic archives (From [Suwayomi](https://github.com/Suwayomi/Suwayomi-Server) for example) to `.epub` with KCC and send them to your Kindle delivery address by email.

This project is a small automation script for a simple pipeline:

1. Find CBZ files in a folder.
2. Convert each file to EPUB using KCC.
3. Batch the converted EPUBs so the total email attachment size stays under a safe limit.
4. Send the batches to your Kindle email address.
5. Delete files only after a successful delivery step.

---

## Features

- Recursive scan for `.cbz` files inside a target folder
- KCC conversion in two modes:
  - local `kcc-c2e` command
  - Docker image mode via `docker://...`
- Automatic webtoon detection based on page aspect ratio
- Filename sanitization and chapter-based output naming
- Batch email delivery to avoid exceeding attachment limits
- Per-file fallback when a batch fails
- Optional inclusion of already-existing `.epub` files in the target folder
- `--dry-run` mode for safe testing
- Optional ZIP internals rewrite to force UTF-8 filenames

---

## Requirements

- Python 3.10 or newer
- A working KCC installation, either:
  - locally as `kcc-c2e`, or
  - through Docker with a KCC image
- A valid email account that can send mail through SMTP
- Your Kindle Send-to-Kindle email address

### Important limits

Amazon’s Send to Kindle service supports email delivery from approved sender addresses, and email delivery has a 50 MB limit for files sent to Kindle. If you exceed that, use a lower `MAX_EMAIL_SIZE` value or split files into smaller batches. Web uploads support larger files, but this project uses email delivery. 

---

## Installation

### 1) Clone the repository

```bash
git clone https://github.com/EvelynLimaB/KCC-to-kindle_autouploader.git
cd KCC-to-kindle_autouploader
```

### 2) Create a virtual environment

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
```

### 3) Install dependencies

This project currently uses only the Python standard library.

### 4) Install KCC

Choose one of the supported modes.

#### Local KCC binary

Install KCC so that the `kcc-c2e` command is available in your shell.

#### Docker-based KCC (Prefered method)

Use a Docker image that provides KCC. The script supports image references in this format:

```bash
docker://ghcr.io/ciromattia/kcc:latest
```

---

## Configuration

Create a `.env` file in the project root.

Example:

```env
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
EMAIL_USER= youremail@mail.com
EMAIL_PASS= yourpass

CBZ_FOLDER= C:CBZ/folder

KINDLE_ADDRESS= yourkindleadress@kindle.com

MAX_EMAIL_SIZE=26214400

KCC_PROFILE=K810

KCC_CMD=docker://ghcr.io/ciromattia/kcc:latest
```

### Variables

- `SMTP_SERVER`: SMTP host for your mail provider
- `SMTP_PORT`: SMTP port, usually `587`
- `EMAIL_USER`: SMTP username / email address
- `EMAIL_PASS`: SMTP password or app password
- `CBZ_FOLDER`: folder to scan recursively for `.cbz` files
- `KINDLE_ADDRESS`: your Kindle Send-to-Kindle address
- `MAX_EMAIL_SIZE`: maximum message size in bytes, default `26214400` (25 MB)
- `KCC_PROFILE`: KCC device profile, default `K810`
- `KCC_CMD`: local command or Docker image reference

#### Gmail Recommendation

For the best reliability, it is strongly recommended to use a dedicated account exclusively for Kindle deliveries.

This script authenticates through Gmail SMTP and should use a Google App Password instead of your regular account password. Google no longer supports basic username/password authentication for most applications, and attempts to use your normal password may fail or trigger additional security checks.

To use an App Password:

1. Enable 2-Step Verification on your Google account.
2. Generate an App Password from your Google Account security settings.
3. Use the generated App Password as `EMAIL_PASS` in your `.env` file.

Using a dedicated account helps prevent interruptions to your personal email, avoids accidental security lockouts, and makes it easier to manage Kindle-approved sender addresses.


---

## Usage

### Linux / macOS

```bash
./run_send_kindles.sh
```

### Windows

Use the batch script as a starting point, or run Python directly:

```bat
python send_kindles.py --folder "D:\CBZ" --profile "K810" --kcc-cmd "docker://ghcr.io/ciromattia/kcc:latest" --kindle-address "your-kindle@kindle.com"
```

### Manual run

```bash
python send_kindles.py \
  --folder "/path/to/Cbz_Manga" \
  --profile "K810" \
  --kcc-cmd "kcc-c2e" \
  --kindle-address "your-kindle@kindle.com"
```

### Dry run

Use this first to verify the workflow without sending mail or deleting files.

```bash
python send_kindles.py \
  --folder "/path/to/Cbz_Manga" \
  --profile "K810" \
  --kcc-cmd "docker://ghcr.io/ciromattia/kcc:latest" \
  --kindle-address "your-kindle@kindle.com" \
  --dry-run
```

### Force UTF-8 ZIP internals

If you have archives with filename encoding problems, add:

```bash
--force-zip-utf8
```

Example:

```bash
python send_kindles.py \
  --folder "/path/to/Cbz_Manga" \
  --profile "K810" \
  --kcc-cmd "kcc-c2e" \
  --kindle-address "your-kindle@kindle.com" \
  --force-zip-utf8
```

---

## How it works

### 1. Discover CBZ files

The script scans the target folder recursively and looks for files ending in `.cbz`.

### 2. Normalize filenames

It sanitizes CBZ filenames so conversion and output filenames are more stable.

### 3. Detect webtoon layout

For CBZ files containing tall pages, the script enables KCC’s webtoon mode automatically.

### 4. Convert to EPUB

Each CBZ is converted into an EPUB using KCC.

### 5. Batch email delivery

Converted EPUBs are grouped into batches to keep the email size within the configured limit.

### 6. Retry failed batches

If a batch fails, the script tries each file individually so one bad attachment does not block everything.

### 7. Cleanup

Source `.cbz` files are deleted after a successful conversion. Converted `.epub` files are deleted only after a batch is successfully sent. If sending fails, the EPUB files are kept on disk for retry.

---

## Output naming

Converted files are named using the source folder name and chapter number when available.

Examples:

- `My Manga_Ch001.epub`
- `My Manga_Ch012.epub`
- `My Manga_some_file_name.epub`

If a file with the same name already exists, the script adds a numeric suffix.

---

## Logging

The project writes logs to both the console and a log file.

Check the logs whenever conversion or delivery fails. The main Python script creates a `logs/` directory beside the script, and the helper shell script also writes to a log file under `./logs`.

---

## Included helper scripts

- `run_send_kindles.sh` — Linux shell launcher
- `run_send_kindles_dry.bat` — Windows batch launcher example

These scripts are meant to reduce setup friction and provide a repeatable way to start the program. Edit them for your own machine before using them, especially paths, SMTP settings, and credentials.

---

## Troubleshooting

### The script exits immediately

Check that the SMTP environment variables are set:

- `SMTP_SERVER`
- `SMTP_PORT`
- `EMAIL_USER`
- `EMAIL_PASS`

### KCC conversion fails

Make sure one of the following is true:

- `kcc-c2e` is installed and available in your `PATH`, or
- your Docker setup can run the image specified in `--kcc-cmd`

### EPUBs are not sent

Confirm that:

- your Kindle email address is correct,
- the email account is allowed to send to that address,
- the batch size is not too large,
- the logs do not show SMTP authentication errors.

### Files are not deleted

Files are only deleted after a successful send. If delivery fails, the script leaves them on disk so you can retry safely.

---

## Development notes

The codebase is intentionally small and easy to extend. Good next improvements include:

- adding automated tests,
- improving Windows documentation,
- adding a proper release workflow,
- documenting the expected KCC installation in more detail.

---

## Contributing

Contributions are welcome.

Suggested workflow:

1. Open an issue describing the problem or improvement.
2. Keep pull requests focused on a single change.
3. Test with `--dry-run` before changing defaults.
4. Include clear notes about any behavior changes.

Good contribution ideas:

- add tests for batch building and fallback sending,
- improve error messages,
- add documentation for common setup issues,
- refine filename normalization rules,
- improve platform-specific launch scripts.

---

## Acknowledgements

This project builds on KCC for comic-to-EPUB conversion and uses SMTP email delivery for Kindle transfer.
