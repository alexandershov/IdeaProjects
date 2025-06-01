import requests


def main():
    response = requests.get('https://w3schools.com/python/demopage.htm')
    print(response.text)


if __name__ == '__main__':
    main()
