// File name: 			AHB_Master_Driver.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB VIP module master driver
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB_MASTER_DRV
`define AHB_MASTER_DRV

`define AHB_IF vif.mst_cb				

class ahb_master_drv #(parameter AHB_BUS_W = 32, AHB_ADDR_W = 32) extends uvm_driver #(ahb_tr #(AHB_BUS_W,AHB_ADDR_W));

	virtual ahb_vif #(AHB_BUS_W,AHB_ADDR_W) vif;

	`uvm_component_param_utils(ahb_master_drv #(AHB_BUS_W,AHB_ADDR_W)) 

	extern function new(string name = "ahb_master_drv", uvm_component parent);
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	extern virtual task run_phase(uvm_phase phase);
	extern virtual function init();
	extern virtual task drive();

endclass

function ahb_master_drv::new(string name = "ahb_master_drv", uvm_component parent);
	super.new(name, parent);
endfunction

function void ahb_master_drv::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db#(virtual ahb_vif #(AHB_BUS_W,AHB_ADDR_W))::get(this, "", "ahb_vif", vif))
		begin
			`uvm_fatal("ahb_master_drv - build_phase", "ahb_vif not set!");
		end

endfunction

function void ahb_master_drv::connect_phase(uvm_phase phase);
	super.build_phase(phase);		
endfunction

task ahb_master_drv::run_phase(uvm_phase phase);
	super.run_phase(phase);

	@(posedge vif.clk);
	init();	

	forever begin
		//@(`AHB_IF);

		fork
			begin
				fork
					begin
						seq_item_port.get_next_item(req);
						`uvm_info("ahb_master_driver - build_phase", $psprintf("Item received"), UVM_NONE);
						req.print();
						drive();
						seq_item_port.item_done();
						`uvm_info("ahb_master_driver - build_phase", $psprintf("Item done"), UVM_NONE);
					end
					
					begin
						@(negedge vif.reset_n);
						init();
					end
				join_any
				disable fork;
			end
		join
	end
endtask

function ahb_master_drv::init();
	`AHB_IF.haddr     <= 32'b0;
	`AHB_IF.hwdata    <= 32'b0;
	`AHB_IF.hburst    <= 3'b0;
	`AHB_IF.hsize     <= 3'b0;																	
	`AHB_IF.hwrite    <= 1'b0;
endfunction

task ahb_master_drv::drive();

	int i;
	bit ready_flag;
	int wrap_max, wrap_min, undefburst_lenght_local, haddr_temp;

	`uvm_phase_info("ahb driver", "hello-5", UVM_LOW)
	repeat(req.tr_delay)
		@(posedge vif.clk);  
	`uvm_info("ahb driver", "hello-4", UVM_LOW)
	if(req.hsel)
		begin
			`uvm_info("ahb driver", "hello-3", UVM_LOW)	
			`AHB_IF.hburst <= req.hburst;
			@(posedge vif.clk);
			case(req.hburst) 																	
				3'b000	:	begin
					            `uvm_info("ahb driver", "hello-2", UVM_LOW)
								`AHB_IF.haddr  <= req.haddr;												/*single burst transfer*/
								`AHB_IF.hsize  <= req.hsize;
								`AHB_IF.hwrite <= req.hwrite;
								`AHB_IF.htrans <= 2'b10;
								`uvm_info("ahb driver", "hello-1", UVM_LOW)	
								if(req.hwrite)															/*write transfer*/
									begin
										while (!ready_flag)												//Wait for ready signal
											begin
												`uvm_info("ahb driver", "hello", UVM_LOW)
												@(posedge vif.clk);
												if(/*`AHB_IF.hready*/ 1)
													ready_flag = 1;
											end
										`uvm_info("ahb driver", "hello2", UVM_LOW)
										`AHB_IF.hwdata <= req.hwdata[0];					
									end			
								else																	/*read transfer*/
									begin
										`uvm_info("ahb driver", "hello0", UVM_LOW)
										while (!ready_flag)												//Wait for ready signal
											begin
												`uvm_info("ahb driver", "hello", UVM_LOW)
												@(posedge vif.clk);
												if(/*`AHB_IF.hready*/ 1)
													ready_flag = 1;
												`uvm_info("ahb driver", "hello2", UVM_LOW)
											end			
									end
							end
													
				3'b001	:	begin
								`AHB_IF.hsize  <= req.hsize;												/*incr burst of undefined lenght*/	
								`AHB_IF.haddr  <= req.haddr;
								`AHB_IF.hwrite <= req.hwrite;
								undefburst_lenght_local = req.undefburst_lenght;
								i = 0;
								
								while (undefburst_lenght_local > 0)	
									begin
										if(i == 0)
											`AHB_IF.htrans <= 2'b10;
										else
											`AHB_IF.htrans <= 2'b11;
										if(req.hwrite)													/*write transfer*/
											begin
												while (!ready_flag)										//Wait for ready signal
													begin
														@(posedge vif.clk);
														if(/*`AHB_IF.hready*/ 1)
															ready_flag = 1;
														else
															`AHB_IF.htrans <= 2'b01;
													end
												`AHB_IF.hwdata <= req.hwdata[i];
												haddr_temp = haddr_temp + 2**req.hsize; 					
												`AHB_IF.haddr <= haddr_temp;							//Set next cycles address
												i++;
											end			
										else															/*read transfer*/
											begin
												while (!ready_flag)										//Wait for ready signal
													begin
														@(posedge vif.clk);
														if(/*`AHB_IF.hready*/ 1)
															ready_flag = 1;
														else
															`AHB_IF.htrans <= 2'b01;	
													end			
												haddr_temp = haddr_temp + 2**req.hsize; 					
												`AHB_IF.haddr <= haddr_temp;							//Set next cycles address
											end	
										undefburst_lenght_local--;
									end
							end		

				3'b010, 3'b100, 3'b110:		begin
												`AHB_IF.hsize <= req.hsize;									/*4/8/16 beat wrapping burst*/
												`AHB_IF.haddr <= req.haddr;
												`AHB_IF.hwrite <= req.hwrite;	
												haddr_temp = req.haddr;								
					    /*postoji li INT()*/	wrap_min = (/*?INT?*/haddr_temp/(2**req.hsize*req.blenght))*(2**req.hsize*req.blenght);
												wrap_max = wrap_min + (2**req.hsize*req.blenght);
												
												if(req.hwrite)												/*write transfers*/
													begin
														for(i=0;i<req.blenght;i++)
															begin
																if(i == 0)										//set state
																	`AHB_IF.htrans <= 2'b10;
																else
																	`AHB_IF.htrans <= 2'b11;												
																while (!ready_flag)								//Wait for ready signal
																	begin
																		@(posedge vif.clk);
																		if(/*`AHB_IF.hready*/ 1)
																			ready_flag = 1;
																		else
																			`AHB_IF.htrans <= 2'b01;	
																	end		
																`AHB_IF.hwdata <= req.hwdata[i];																		
																if(haddr_temp == wrap_max)					//Set next cycles address
																	`AHB_IF.haddr <= wrap_min;		
																else
																	begin
																		haddr_temp = haddr_temp + 2**req.hsize; 					
																		`AHB_IF.haddr <= haddr_temp;
																	end
															end
													end	
												else
													begin													/*read transfers*/
														for(i=0;i<req.blenght;i++)
															begin
																if(i == 0)										//set state
																	`AHB_IF.htrans <= 2'b10;
																else
																	`AHB_IF.htrans <= 2'b11;																
																while (!ready_flag)								//Wait for ready signal
																	begin
																		@(posedge vif.clk);
																		if(/*`AHB_IF.hready*/ 1)
																			ready_flag = 1;
																		else
																			`AHB_IF.htrans <= 2'b01;	
																	end			
																if(haddr_temp == wrap_max)					//Set next cycles address
																	`AHB_IF.haddr <= wrap_min;		
																else
																	begin
																		haddr_temp = haddr_temp + 2**req.hsize;; 					
																		`AHB_IF.haddr <= haddr_temp;
																	end
															end	
													end		
											end			
					
				3'b011, 3'b101 ,3'b111:		begin
												`AHB_IF.hsize <= req.hsize;									/*4/8/16 beat incrementing burst*/
												`AHB_IF.haddr <= req.haddr;
												`AHB_IF.hwrite <= req.hwrite;
														
												if(req.hwrite)												/*write transfers*/
													begin
														for(i=0;i<req.blenght;i++)
															begin
																if(i == 0)											//set state
																	`AHB_IF.htrans <= 2'b10;
																else
																	`AHB_IF.htrans <= 2'b11;													
																begin
																	while (!ready_flag)								//Wait for ready signal
																		begin
																			@(posedge vif.clk);
																			if(/*`AHB_IF.hready*/ 1)
																				ready_flag = 1;
																			else
																				`AHB_IF.htrans <= 2'b01;	
																		end	
																	`AHB_IF.hwdata <= req.hwdata[i];																		
																	haddr_temp = haddr_temp + 2**req.hsize;;  					
																	`AHB_IF.haddr <= haddr_temp;					//Set next cycles address
																end	
															end
													end		
												else														/*read transfers*/
													begin
														for(i=0;i<req.blenght;i++)
															begin
																if(i == 0)										//set state
																	`AHB_IF.htrans <= 2'b10;
																else
																	`AHB_IF.htrans <= 2'b11;														
																while (!ready_flag)								//Wait for ready signal
																	begin
																		@(posedge vif.clk);
																		if(/*`AHB_IF.hready*/ 1)
																			ready_flag = 1;
																		else
																			`AHB_IF.htrans <= 2'b01;				//Busy state
																	end			
																haddr_temp = haddr_temp + 2**req.hsize;; 				
																`AHB_IF.haddr <= haddr_temp;
															end
													end			
											end			
			endcase
			`AHB_IF.htrans <= 2'b00;
		end	
endtask


`endif //AHB_MASTER_DRV