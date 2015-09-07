url     = require 'url'
{spawn} = require 'child_process'
fs      = require 'fs'

BASE_URL = 'https://www.zkorean.com/study/serve_audio_public/%s.mp3'
DOWNLOAD_DIR = './'

sounds =
  consonants:
    "ㄱ": "bd67bd87e2c64d7e6664bdb05a84ff1d266f2f9993e86839500a5c420772fe48_1"
    "ㄲ": "bd67bd87e2c64d7e6664bdb05a84ff1d68615a9386663ec835f24d730ca87124_2"
    "ㄴ": "bd67bd87e2c64d7e6664bdb05a84ff1d44d07656275fc0c466ef025ee7dd505a_3"
    "ㄷ": "bd67bd87e2c64d7e6664bdb05a84ff1d857a3c69cd961caa1e076975226f606a_4"
    "ㄸ": "bd67bd87e2c64d7e6664bdb05a84ff1dc06c81807bfc41d4ee3eefad0ff2494a_5"
    "ㄹ": "bd67bd87e2c64d7e6664bdb05a84ff1d1d9dfa5545a9c46c7da61c0399c4eac6_6"
    "ㅁ": "bd67bd87e2c64d7e6664bdb05a84ff1dd3e8dd7356889f71aaed8d84881cf877_7"
    "ㅂ": "bd67bd87e2c64d7e6664bdb05a84ff1d7b1272148e17919b8bf1bd7b4e51c6c1_8"
    "ㅃ": "bd67bd87e2c64d7e6664bdb05a84ff1d3986c4af873bbaba93c3702b3b40dcc7_9"
    "ㅅ": "bd67bd87e2c64d7e6664bdb05a84ff1dca303fbade9b44d72c413cc06cbb7e74_10"
    "ㅆ": "bd67bd87e2c64d7e6664bdb05a84ff1d6c0597b4d87ca0d0e3165cca6ad0c86d_11"
    "ㅇ": "bd67bd87e2c64d7e6664bdb05a84ff1df5cc82ce8f1854afe0dc35357d1c3301_12"
    "ㅈ": "bd67bd87e2c64d7e6664bdb05a84ff1d756d46a2ec8c4bb5ff438b86a65575eb_13"
    "ㅉ": "bd67bd87e2c64d7e6664bdb05a84ff1dfccc41e233c3ad1853e65f9e57f42dd7_14"
    "ㅊ": "bd67bd87e2c64d7e6664bdb05a84ff1d94cda55deb5800cf941b4e09506785b2_15"
    "ㅋ": "bd67bd87e2c64d7e6664bdb05a84ff1dc402b4daecf37f315c316e1b89443ff4_16"
    "ㅌ": "bd67bd87e2c64d7e6664bdb05a84ff1d4f8b1517eef7813489643bbb6af8f5d9_17"
    "ㅍ": "bd67bd87e2c64d7e6664bdb05a84ff1d437ab5e7ed3bb1d646ebde72579d881d_18"
    "ㅎ": "bd67bd87e2c64d7e6664bdb05a84ff1d262323afcf7b62413cca9c89be46943b_19"

  vowels:
    "ㅏ": "170fe09ec7464561fbf58058651c81335b6e239e9c53a42d_20"
    "ㅓ": "170fe09ec7464561a651f112bcc34c74d3a29963db135e55_21"
    "ㅗ": "170fe09ec7464561b5540a40dc0e06cc2d916ecbb6ce058f_22"
    "ㅜ": "170fe09ec7464561f81f693716f67119de4bd0f10ca29201_23"
    "ㅡ": "170fe09ec74645610c33962c2f630f89cf091f74d90cee47_24"
    "ㅣ": "170fe09ec746456110b311bd491b88df8961f6994b5ad4f3_25"
    "ㅐ": "170fe09ec746456195d095b7bb33ad4278a1844f0bdaf70a_26"
    "ㅔ": "170fe09ec7464561f0908e7b59996d3d60283734532dd751_27"
    "ㅑ": "170fe09ec74645617a6d0ab84785d740ce93a0d5acebf59a_28"
    "ㅕ": "170fe09ec746456101755731cb5f1d1e7b63d174fd75cc8f_29"
    "ㅛ": "170fe09ec74645615db4e42d90eaed61e62652db128a3655_30"
    "ㅠ": "170fe09ec7464561767cd75cf19968695a3db02e2cf1caec_31"
    "ㅒ": "170fe09ec7464561564b5308200c0ac0c9f878a4f585ded6_32"
    "ㅖ": "170fe09ec74645617fd01901606b14eb04d8b00f3c02c8e6_33"
    "ㅘ": "170fe09ec7464561184dc556ddf7a995508fb05eef0fa96b_34"
    "ㅙ": "170fe09ec746456160f872aafb59da5390e9668a3c2d5939_35"
    "ㅝ": "170fe09ec7464561e1a2064663b774871aa42272376a3575_36"
    "ㅞ": "170fe09ec7464561ba72605178a313a8727d8f5f59538dc1_37"
    "ㅚ": "170fe09ec74645613a8b5cb0b31eebf56f33a11c4b784028_38"
    "ㅟ": "170fe09ec74645618a7018ad366f148018e361e4631ad217_39"
    "ㅢ": "170fe09ec7464561717d20ea15a7a39c49efc6a10c895164_40"


download_file_curl = (file_url, file_name) ->
    file_name += '.mp3'
    file = fs.createWriteStream DOWNLOAD_DIR + file_name
    curl = spawn 'curl', [file_url]
    curl.stdout.on 'data', (data) -> file.write data
    curl.stdout.on 'end', (data) ->
      file.end()
      console.log file_name + ' downloaded to ' + DOWNLOAD_DIR

    curl.on 'exit', (code) ->
      if code isnt 0
        console.log 'Failed: ' + code

for name, path of sounds.consonants
  download_file_curl BASE_URL.replace('%s', path), name + '?'

for name, path of sounds.vowels
  download_file_curl BASE_URL.replace('%s', path), name
