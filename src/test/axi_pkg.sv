package axi_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh";

	`include "axi_trans.sv";

	`include "axi_mseq.sv";
	`include "axi_magent_config.sv";
	`include "axi_mseqr.sv";
	`include "axi_mdrv.sv";
	`include "axi_mmon.sv";
	`include "axi_magent.sv";
	`include "axi_magent_top.sv";
	
	`include "axi_sseq.sv";
	`include "axi_sagent_config.sv";
	`include "axi_sseqr.sv";
	`include "axi_sdrv.sv";
	`include "axi_smon.sv";
	`include "axi_sagent.sv";
	`include "axi_sagent_top.sv";

	`include "axi_env_config.sv";
	`include "axi_sb.sv";
	`include "axi_env.sv";
	`include "axi_test.sv";

endpackage

/*
package axi_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh";

	`include "axi_trans.sv";
	`include "axi_seq.sv";

	`include "axi_magent_config.sv";
	`include "axi_mseqr.sv";
	`include "axi_mdrv.sv";
	`include "axi_mmon.sv";
	`include "axi_magent.sv";
	`include "axi_magent_top.sv";

	`include "axi_sagent_config.sv";
	`include "axi_sseqr.sv";
	`include "axi_sdrv.sv";
	`include "axi_smon.sv";
	`include "axi_sagent.sv";
	`include "axi_sagent_top.sv";

	`include "axi_env_config.sv";
	`include "axi_sb.sv";
	`include "axi_env.sv";
	`include "axi_test.sv";

endpackage
*/

/*
package axi_pkg;

	import uvm_pkg::*;

	`include "uvm_macros.svh";

	`include "axi_mtrans.sv";
	`include "axi_mseq.sv";
	`include "axi_magent_config.sv";
	`include "axi_mseqr.sv";
	`include "axi_mdrv.sv";
	`include "axi_mmon.sv";
	`include "axi_magent.sv";
	`include "axi_magent_top.sv";

	`include "axi_strans.sv";
	`include "axi_sseq.sv";
	`include "axi_sagent_config.sv";
	`include "axi_sseqr.sv";
	`include "axi_sdrv.sv";
	`include "axi_smon.sv";
	`include "axi_sagent.sv";
	`include "axi_sagent_top.sv";

	`include "axi_env_config.sv";
	`include "axi_sb.sv";
	`include "axi_env.sv";
	`include "axi_test.sv";

endpackage
*/
