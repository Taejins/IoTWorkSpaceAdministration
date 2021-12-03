

    


    function invokeEventAPI() {
        var API_URI = '/work?type=all';
        
        $.ajax('api' + API_URI, {
            method: 'GET',
            contentType: "application/json",
            dataType:"json",
            success: function (data, status, xhr) {
               printEventList(data,'#events');
            },
            error: function(xhr,status,e){
                alert("error");
            }
        });
    };

    // 데이터 출력을 위한 함수
    function printEventList(data, place){
        if (data.length > 0) {
            var tr = document.createElement("tr");
            tr.setAttribute("style","background-color:lightgrey");
            var th1 = document.createElement("th");
            var th2 = document.createElement("th");
            var th3 = document.createElement("th");
            var th4 = document.createElement("th");
            var th5 = document.createElement("th");
            var th6 = document.createElement("th");
            var th7 = document.createElement("th");
            
            th1.innerText = "ID";
            th2.innerText = "Title";
            th3.innerText = "Lat";
            th4.innerText = "Lon";
            th5.innerText = "Support";
            th6.innerText = "Time";
            th7.innerText = "valid";
            
            tr.append(th1);
            tr.append(th2);
            tr.append(th3);
            tr.append(th4);
            tr.append(th5);
            tr.append(th6);
            tr.append(th7);

            
            $(place).append(tr);  

             // id가 devices인 태그에 테이블 제목 행을 추가
            data.forEach(function(v){
                var tr = document.createElement("tr");
                var td1 = document.createElement("td");
                var td2 = document.createElement("td");
                var td3 = document.createElement("td");
                var td4 = document.createElement("td");
                var td5 = document.createElement("td");
                var td6 = document.createElement("td");
                var td7 = document.createElement("td");
                td1.innerText = v.id;
                td2.innerText = v.title;
                td3.innerText = v.lat;
                td4.innerText = v.lon;
                td5.innerText = v.support;
                td6.innerText = v.time;
                td7.innerText = v.valid;
                // var a = document.createElement('a');    // <a> 태그 생성
       
                // // 해당 링크 클릭시에 device id를 기반으로 태그스트림 목록 조회
                // a.setAttribute('href',`javascript:listTags('${v.id}');javascript:listEvents( '${v.id}' );`);
                // a.innerHTML = v.id;

                // td2.append(a);

                tr.appendChild(td1);
                tr.appendChild(td2);
                tr.appendChild(td3);
                tr.appendChild(td4);
                tr.appendChild(td5);
                tr.appendChild(td6);
                tr.appendChild(td7);
                $(place).append(tr); // id가 devices인 태그에 테이블 행을 추가
            })


            
        }
    }
