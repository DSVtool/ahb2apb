// File name: 			AHB_Master_Driver.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB VIP module master driver
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB_MASTER_DRV
`define AHB_MASTER_DRV

`define AHB_IF vif.mst_cb				

class ahb_master_drv #(parameter AHB_DW = 32, AHB_AW = 32) extends uvm_driver #(ahb_tr #(AHB_DW,AHB_AW));

	virtual ahb_vif #(AHB_DW,AHB_AW)  vif;

	`uvm_component_param_utils(ahb_master_drv #(AHB_DW,AHB_AW)) 

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

	if(!uvm_config_db#(virtual ahb_vif #(AHB_DW,AHB_AW))::get(this, "", "vif", vif))
		begin
			`uvm_fatal("ahb_master_drv - build_phase", "vif not set!");
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
		@(`AHB_IF);

		fork
			begin
				fork
					begin
						seq_item_port.get_next_item(req);
						drive();
						seq_item_port.item_done();
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
	
	`AHB_IF.haddr     = 31'b0;
	`AHB_IF.hwdata    = 31'b0;
	`AHB_IF.hrdata    = 31'b0;
	`AHB_IF.hburst    = 3'b0;
	`AHB_IF.hsize     = 3'b0;																	
	`AHB_IF.hwrite    = 1'b0;
	
endfunction

task ahb_master_drv::drive();

	int i;
	bit ready_flag;
	int wrap_max, wrap_min, undefburst_lenght_local;
	
	repeat(req.tr_delay)
		@(`AHB_IF);  

	if(!req.hsel)
		break;

	`AHB_IF.hburst = req.hburst;	
	
	@(posedge vif.clk);
	
	case(req.hburst) 																	
		3'b000	:	begin
						`AHB_IF.haddr  = req.haddr;												/*single burst transfer*/
						`AHB_IF.hsize  = req.hsize;
						`AHB_IF.hwrite = req.hwrite;
						`AHB_IF.htrans = 2'b10;
						
						if(req.hwrite)															/*write transfer*/
							begin
								while (!ready_flag)												//Wait for ready signal
									begin
										@(posedge vif.clk);
										if(`AHB_IF.hready)
											ready_flag = 1;
									end
								`AHB_IF.hwdata = req.hwdata[0];					
							end			
						else																	/*read transfer*/
							begin
								while (!ready_flag)												//Wait for ready signal
									begin
										@(posedge vif.clk);
										if(`AHB_IF.hready)
											ready_flag = 1;
									end			
								`AHB_IF.hrdata = req.hrdata;
							end
					end
											
		3'b001	:	begin
						`AHB_IF.hsize  = req.hsize;												/*incr burst of undefined lenght*/	
						`AHB_IF.haddr  = req.haddr;
						`AHB_IF.hwrite = req.hwrite;
						undefburst_lenght_local = req.undefburst_lenght;
						i = 0;
						
						while (undefburst_lenght_local > 0)	
							begin
								if(i == 0)
									`AHB_IF.htrans = 2'b10;
								else
									`AHB_IF.htrans = 2'b11;
								if(req.hwrite)													/*write transfer*/
									begin
										while (!ready_flag)										//Wait for ready signal
											begin
												@(posedge vif.clk);
												if(`AHB_IF.hready)
													ready_flag = 1;
												else
													`AHB_IF.htrans = 2'b01;
											end
										`AHB_IF.hwdata = req.hwdata[i];					
										`AHB_IF.haddr += 2**`AHB_IF.hsize;						//Set next cycles address
										i++;
									end			
								else															/*read transfer*/
									begin
										while (!ready_flag)										//Wait for ready signal
											begin
												@(posedge vif.clk);
												if(`AHB_IF.hready)
													ready_flag = 1;
												else
													`AHB_IF.htrans = 2'b01;	
											end			
										`AHB_IF.hrdata = req.hrdata;
										`AHB_IF.haddr += 2**`AHB_IF.hsize;						//Set next cycles address
									end	
								undefburst_lenght_local--;
							end
					end		

		3'b010, 3'b100, 3'b110:		begin
										`AHB_IF.hsize = req.hsize;									/*4/8/16 beat wrapping burst*/
										`AHB_IF.haddr = req.haddr;
										`AHB_IF.hwrite = req.hwrite;									
			    /*postoji li INT()*/	wrap_min = (/*?INT?*/(`AHB_IF.haddr/(2**`AHB_IF.hsize*req.blenght)))*(2**`AHB_IF.hsize*req.blenght);
										wrap_max = wrap_min + (2**`AHB_IF.hsize*req.blenght);
										
										if(req.hwrite)												/*write transfers*/
											begin
												for(i=0;i<req.blenght;i++)
													begin
														if(i == 0)										//set state
															`AHB_IF.htrans = 2'b10;
														else
															`AHB_IF.htrans = 2'b11;												
														while (!ready_flag)								//Wait for ready signal
															begin
																@(posedge vif.clk);
																if(`AHB_IF.hready)
																	ready_flag = 1;
																else
																	`AHB_IF.htrans = 2'b01;	
															end		
														`AHB_IF.hwdata = req.hwdata[i];																		
														if(`AHB_IF.haddr == wrap_max)					//Set next cycles address
															`AHB_IF.haddr = wrap_min;		
														else
															`AHB_IF.haddr += 2**`AHB_IF.hsize;
													end
											end	
										else
											begin													/*read transfers*/
												for(i=0;i<req.blenght;i++)
													begin
														if(i == 0)										//set state
															`AHB_IF.htrans = 2'b10;
														else
															`AHB_IF.htrans = 2'b11;																
														while (!ready_flag)								//Wait for ready signal
															begin
																@(posedge vif.clk);
																if(`AHB_IF.hready)
																	ready_flag = 1;
																else
																	`AHB_IF.htrans = 2'b01;	
															end			
														`AHB_IF.hrdata = req.hrdata;	
														if(`AHB_IF.haddr == wrap_max)					//Set next cycles address
															`AHB_IF.haddr = wrap_min;		
														else
															`AHB_IF.haddr += 2**`AHB_IF.hsize;
													end	
											end		
									end			
			
		3'b011, 3'b101 ,3'b111:		begin
										`AHB_IF.hsize = req.hsize;									/*4/8/16 beat incrementing burst*/
										`AHB_IF.haddr = req.haddr;
										`AHB_IF.hwrite = req.hwrite;
												
										if(req.hwrite)												/*write transfers*/
											begin
												for(i=0;i<req.blenght;i++)
													begin
														if(i == 0)											//set state
															`AHB_IF.htrans = 2'b10;
														else
															`AHB_IF.htrans = 2'b11;													
														begin
															while (!ready_flag)								//Wait for ready signal
																begin
																	@(posedge vif.clk);
																	if(`AHB_IF.hready)
																		ready_flag = 1;
																	else
																		`AHB_IF.htrans = 2'b01;	
																end	
															`AHB_IF.hwdata = req.hwdata[i];																		
															`AHB_IF.haddr += 2**`AHB_IF.hsize;				//Set next cycles address
														end	
													end
											end		
										else														/*read transfers*/
											begin
												for(i=0;i<req.blenght;i++)
													begin
														if(i == 0)										//set state
															`AHB_IF.htrans = 2'b10;
														else
															`AHB_IF.htrans = 2'b11;														
														while (!ready_flag)								//Wait for ready signal
															begin
																@(posedge vif.clk);
																if(`AHB_IF.hready)
																	ready_flag = 1;
																else
																	`AHB_IF.htrans = 2'b01;				//Busy state
															end			
														`AHB_IF.hrdata = req.hrdata;	
														`AHB_IF.haddr += 2**`AHB_IF.hsize;				//Set next cycles address
													end
											end			
									end			
	endcase
	`AHB_IF.htrans = 2'b00;
endtask

`endif //AHB_MASTER_DRV