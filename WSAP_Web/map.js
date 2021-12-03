    var map;
    var marker;
    
    var intervalId1 = null;
    var intervalId2 = null;
    var intervalId3 = null;

    // API 시작
    function Start() {
        setTimeout(invokeEmployeeAPI, 500);
        setTimeout(invokeEventAPI, 500);
        setTimeout(invokeLocAPI, 500);
        intervalId1 = setInterval(invokeEmployeeAPI, 30000);
        intervalId2 = setInterval(invokeEventAPI, 30000);
        intervalId3 = setInterval(invokeLocAPI, 30000);
        document.getElementById("bt1").disabled = true;
        document.getElementById("bt2").disabled = false;
    }
    // API 중지

    function Stop() {
        if(intervalId1 != null || intervalId2 != null || intervalId3 != null) {
            clearInterval(intervalId1);
            clearInterval(intervalId2);
            clearInterval(intervalId3);
            document.getElementById("bt1").disabled = false;
            document.getElementById("bt2").disabled = true;
        }
    }

    // 지도 출력
    function initMap(data){

        // 위치데이터 경도, 위도로 구성된 jso 파일은 항상 이런식으로 구성되어있다.
        var lnit_location = {lat: 37.582345803468556, lng: 127.00945758457985};
        map = new google.maps.Map(
                document.getElementById("map"),
                {zoom: 17, center: lnit_location}
                );

        setMarkers(map);
        // new google.maps.Marker(
        //     {position: lnit_location,
        //         map: map,
        //         label :'hi'}        
        //     );
    }
    
    function setMarkers(map) {
        for (let i = 0; i < marker.length; i++) {
            const mark = marker[i];
            new google.maps.Marker({
                position: { lat: parseFloat(mark.lat), lng: parseFloat(mark.lon) },
                map,
                label: mark.deviceid,
            });
        }
    }
    function invokeEmployeeAPI() {
        var API_URI = '/employee?type=all';
        
        $.ajax('api' + API_URI, {
            method: 'GET',
            contentType: "application/json",
            dataType:"json",
            success: function (data, status, xhr) {
               printEmployeeList(data,'#employees');
               marker = data;
               initMap();
            },
            error: function(xhr,status,e){
                alert("error");
            }
        });
    };

    function printEmployeeList(data, place){
        if (data.length > 0) {
            var tr = document.createElement("tr");
            tr.setAttribute("style","background-color:lightgrey");
            var th1 = document.createElement("th");
            var th2 = document.createElement("th");
            var th3 = document.createElement("th");
            var th4 = document.createElement("th");

            
            th1.innerText = "deviceID";
            th2.innerText = "lat";
            th3.innerText = "lon";
            th4.innerText = "time";

            
            tr.append(th1);
            tr.append(th2);
            tr.append(th3);
            tr.append(th4);


            
            $(place).append(tr);  

             // id가 devices인 태그에 테이블 제목 행을 추가
            data.forEach(function(v){
                var tr = document.createElement("tr");
                var td1 = document.createElement("td");
                var td2 = document.createElement("td");
                var td3 = document.createElement("td");
                var td4 = document.createElement("td");

                td1.innerText = v.deviceid;
                td2.innerText = v.lat;
                td3.innerText = v.lon;
                td4.innerText = v.time;


                // var a = document.createElement('a');    // <a> 태그 생성
       
                // // 해당 링크 클릭시에 device id를 기반으로 태그스트림 목록 조회
                // a.setAttribute('href',`javascript:listTags('${v.id}');javascript:listEvents( '${v.id}' );`);
                // a.innerHTML = v.id;

                // td2.append(a);

                tr.appendChild(td1);
                tr.appendChild(td2);
                tr.appendChild(td3);
                tr.appendChild(td4);

                $(place).append(tr); // id가 devices인 태그에 테이블 행을 추가
            })


            
        }
    }
