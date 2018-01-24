var host = "http://localhost:8080";
var simulation;
$(document).ready(function(){
  $("#option_1").click(function(){
    clearInterval(simulation);
    $("#database").hide();
    $("#option_4").hide();
    $("#result").hide();
    $("#simulation_area").hide();
    $("#console_session_1").show();
  });

  $("#submit_num_emp").click(function(){
    $("#console_session_1").hide();
    $("#option_4").hide();
    $("#result").hide();
    $("#simulation_area").hide();
    $("#database").hide();
    var input_number_employee = $("#textbox").val();
    $.post(host + "/1/" + input_number_employee,{
        }, function(data){
            if (data.status == "succeed"){
              var text = "Succed processing";
              $("#result").html(text);
              $("#result").show();
              setTimeout(function() {
                $("#result").fadeOut().empty()
              }, 1500);
            }
        });

  });

  $("#option_2").click(function(){
    clearInterval(simulation);
    $("#console_session_1").hide();
    $("#option_4").hide();
    $("#database").hide();
    $("#result").hide();
    $("#simulation_area").hide();
    var text = "Database: ";
    $("#result").html(text);
    $("#result").show();

    $.get(host + "/2", function(data){
      var line = "";
            for (x in data){
        var name = data[x].split(":")[0];
        var per = data[x].split(":")[1];
        line = line + "id = " + x + " " + "; Name = " + name + "; Permission = " + per + "<br>";
      }

      $("#database").html(line);
      $("#database").show();
        });
  });

  function blinker(id) {
    $(id).fadeOut(250);
    $(id).fadeIn(250);
  }
  var blinkIcon;
  var image;
  $("#option_3").click(function(){
      simulation = setInterval(function(){
      $("#console_session_1").hide();
      $("#database").hide();
      $("#result").hide();
      $("#simulation_area").show();
      $("#waitingArea").remove();
      $("#simulation_area").append("<div id='waitingArea'></div>");
      $("#option_4").remove();
      $("#list_option").append("<button id='option_4'>Stop simulation</butoon>");

      $.get(host + "/2", function(data){
        for (x in data){
          var name = data[x].split(":")[0];
          var per = data[x].split(":")[1];

          var myObject = "<div id='" + x + "'>";
          myObject = myObject + "<img src='waitting_people.png' style='height:3%; width: 3%;'></img>";
          myObject = myObject + "<figcaption>" + x + "</figcaption></div><br>";
          $("#waitingArea").append(myObject);
        }
    });
      $.get(host+ "/3", function(data){
        console.log(data);
        clearInterval(blinkIcon);
        if (data["type"] == "stranger"){
          var myObject = "<div id='" + data["id"] + "'>" ;
          myObject = myObject + "<img src='waitting_people_stranger.png' style='height:3%; width: 3%;'>";
          myObject = myObject + "<figcaption>" + data["id"] + "</figcaption>";
          myObject = myObject + "May I get admission to the building</div><br>";
          $("#waitingArea").append(myObject);
          var myId = "#\\<0\\." + String(data["id"]).substr(3, 3) + "\\.0\\>";
          blinkIcon = setInterval(blinker, 500, myId);
          console.log(1);
        }else{
          var myId = "#\\<0\\." + String(data["id"]).substr(3, 3) + "\\.0\\>";
          blinkIcon = setInterval(blinker, 1000, myId);
          $(myId).append("May I get admission to enter to the building");
        }

        var canvas = document.getElementById("myCanvas");
        var ctx = canvas.getContext("2d");
        image = new Image();

        image.onload = function() {
          ctx.drawImage(image, 10, 10, 100, 100);
        };
        setTimeout(function(){
          if (data["server"] == "admission"){
            image.src = "admission.jpg";
          }else{
            image.src = "no_admission.jpg";
          }
        }, 1000);
      });
      $("#option_4").click(function(){
        clearInterval(simulation);
        $("#option_4").hide();
      });
    }, 3000);

  });
});
