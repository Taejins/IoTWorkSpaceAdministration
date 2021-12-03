


    function invokeLocLogAPI(start, end) {
        var API_URI = '/location?type=scan&start='+start+'&end='+end;
        
        $.ajax('api' + API_URI, {
            method: 'GET',
            contentType: "application/json",
            dataType:"json",
            success: function (data, status, xhr) {
                
                printLocLogList(data,'#location_log');
            },
            error: function(xhr,status,e){
                alert("loc error");
            }
        });
    };

    // 데이터 출력을 위한 함수
    function printLocLogList(data, place){
        $(place).empty();  

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


            document.getElementsById("div")[1].remove();
        }
    }
