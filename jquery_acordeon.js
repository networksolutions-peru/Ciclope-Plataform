// JavaScript Document
						/*
						 * Desarrolador: Jonathan Lamas Sulca
						 * Fecha: 26/04/2013
						 * Web: www.atixweb.com
						 */

						$(document).ready(function(){

					
							/**/$(".refClick").ready(function(index){
									//alert("jsajonjsadljkds");
									var szIndex= $(this).attr('data');
									$(".cascada li .casc_blick").each(function(index){
										
										/**/if ($(this).attr('data')!='true'){

											$(this).slideUp(300);
											$(this).attr('data','');

										}
									});
								});

								$(".refClick").click(function(index){

										var szIndex= $(this).attr('data');


									$(".cascada li .casc_blick").each(function(index){
										
								
										$(".cascada li .casc_blick").each(function(index){

												if(szIndex==index){
													$(this).attr('data','true');
												}
												if (szIndex!=index){

													$(this).slideUp(300);
													$(this).attr('data','');

												}
										});


										if ($(this).attr('data')=='true' && index==szIndex ){
											
											$(this).slideToggle(300);// xD!! cambiar por sliderDown para solo abrir

											$(".cascada li .casc_blick").each(function(index){
							

												if(szIndex != index){
													$(this).attr('data','');
												}

											});

											return false;

										};

									});

								});/**/

							});