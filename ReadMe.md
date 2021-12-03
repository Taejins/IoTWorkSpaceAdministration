IoT 클라우드 플랫폼 프로젝트에 사용한 코드입니다.

1. AWS_GPS 
아두이노 IDE를 이용한 코드 파일입니다.
MKR1010 Wifi 기종을 사용하였고 NEO 6m GPS 모듈, LCD I2C 모듈 등을 사용하였고 부수적으로 버튼 2개, 부저 1개, LED 1개 이용하여 작업하였습니다.

2. WSAP_Web
구글 맵 api를 이용한 맵 플로팅과 aws api를 이용하여 dynamoDB의 데이터를 출력합니다. 사용시 구글 맵 api 키와 aws api gateway를 이용하여 api를 구축해야 합니다.

3. work_space_adminstration
flutter를 이용한 안드로이드 앱입니다. aws api gateway에서 구축한 api 주소를 이용하여야 합니다.
aws sns에 안드로이드 앱을 연결하기 위해 FCM을 이용하여 안드로이드 /app 폴더 밑에 파이어베이스 연결 json 파일을 포함하여야합니다.
구글 맵 api를 이용하기 때문에 androidmanifest 파일에 구글 맵 api 키를 추가하여야 합니다.
코드 내에 배열에 주석 형태로 json 포맷이 명시되어 있으나 사용자의 api에 맞게 수정하시면 됩니다.

