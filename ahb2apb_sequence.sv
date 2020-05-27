// File name: 			AHB2APB_Sequence.sv
// Creator name: 		Dimitrije Selken
// Current version: 	0.1
// File description:    AHB2APB bridge module virtual sequence and base sequences
// File history: 		0.1  - Dimitrije S. - Inital version.

`ifndef AHB2APB_SQC
`define AHB2APB_SQC

class base_sequence extends uvm_sequence #(uvm_sequence_item);
	`uvm_object_utils(base_sequence)
	`uvm_declare_p_sequencer(virtual_sequencer)
endclass

class ahb_seq extends base_sequence;

ahb_tr hseq;

	`uvm_object_utils(ahb_seq)

	virtual task body();
		`uvm_do_on(hseq, p_sequencer.ahb_sqr);
	endtask

endclass

class apb_seq extends base_sequence ;

ahb_tr pseq;

	`uvm_object_utils(apb_seq)

	virtual task body();
		`uvm_do_on(pseq, p_sequencer.apb_sqr);
	endtask

endclass

class virtual_sequence extends base_sequence;	

	`uvm_object_utils(virtual_sequence)

	ahb_seq hseq;
	apb_seq pseq;

	virtual task body();

		fork 
			begin
				`uvm_do(hseq);
			end

			begin
				`uvm_do(pseq);
			end
		join	
	endtask

endclass

`endif //AHB2APB_SQC0