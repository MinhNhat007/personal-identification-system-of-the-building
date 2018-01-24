<script>
			var host = "http://localhost:8080";
			$(document).ready(function(){
				$("#option_1").click(function(){
					$("#database").hide();
					$("#result").hide();
					$("#simulation_area").hide();
					$("#console_session_1").show(); 
				});

				$("#submit_num_emp").click(function(){
					$("#console_session_1").hide();
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
								}, 3000
							);
						}
        			});		
				});

				$("#option_2").click(function(){
					$("#console_session_1").hide();
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
				
				$("#option_3").click(function(){
					$("#console_session_1").hide();
					$("#database").hide();
					$("#result").hide();
					$("#simulation_area").show();
				});
			});
		</script>
