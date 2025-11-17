import subprocess


def main():
    subprocess.run(["gunicorn", "app:app", "--bind=127.0.0.1:5261", "--workers=4"])


if __name__ == "__main__":
    main()
