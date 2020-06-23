if {![info exists standalone] || $standalone} {
  # Read lef
  read_lef $::env(TECH_LEF)
  read_lef $::env(SC_LEF)
  if {[info exist ::env(ADDITIONAL_LEFS)]} {
    foreach lef $::env(ADDITIONAL_LEFS) {
      read_lef $lef
    }
  }

  # Read liberty files
  foreach libFile $::env(LIB_FILES) {
    read_liberty $libFile
  }

  # Read def and sdc
  read_def $::env(RESULTS_DIR)/5_route.def
  read_sdc $::env(RESULTS_DIR)/5_route.sdc
}

# Set res and cap
if {[info exists ::env(WIRE_RC_RES)] && [info exists ::env(WIRE_RC_CAP)]} {
  set_wire_rc -res $::env(WIRE_RC_RES) -cap $::env(WIRE_RC_CAP)
} else {
  set_wire_rc -layer $::env(WIRE_RC_LAYER)
}

set_propagated_clock [all_clocks]

log_begin $::env(REPORTS_DIR)/6_final_report.rpt

puts "\n=========================================================================="
puts "report_checks -path_delay min"
puts "--------------------------------------------------------------------------"
report_checks -path_delay min -fields {slew cap input}

puts "\n=========================================================================="
puts "report_checks -path_delay max"
puts "--------------------------------------------------------------------------"
report_checks -path_delay max -fields {slew cap input}

puts "\n=========================================================================="
puts "report_checks -unconstrained"
puts "--------------------------------------------------------------------------"
report_checks -unconstrained

puts "\n=========================================================================="
puts "report_tns"
puts "--------------------------------------------------------------------------"
report_tns

puts "\n=========================================================================="
puts "report_wns"
puts "--------------------------------------------------------------------------"
report_wns

puts "\n=========================================================================="
puts "report_check_types -max_slew -max_capacitance -max_fanout -violators"
puts "--------------------------------------------------------------------------"
report_check_types -max_slew -max_capacitance -max_fanout -violators

puts "\n=========================================================================="
puts "report_clock_skew"
puts "--------------------------------------------------------------------------"
report_clock_skew

puts "\n=========================================================================="
puts "report_power"
puts "--------------------------------------------------------------------------"
report_power

puts "\n=========================================================================="
puts "report_design_area"
puts "--------------------------------------------------------------------------"
report_design_area

puts "\n=========================================================================="
puts "instance_count"
puts "--------------------------------------------------------------------------"
puts "[sta::network_leaf_instance_count]"

puts "\n=========================================================================="
puts "pin_count"
puts "--------------------------------------------------------------------------"
puts "[sta::network_leaf_pin_count]"


puts "final_slew_vio: [llength [string trim [psn::transition_violations]]]"
puts "final_cap_vio: [llength [string trim [psn::capacitance_violations]]]"
puts "final_inst_count: [sta::network_leaf_instance_count]"
puts "final_pin_count: [sta::network_leaf_pin_count]"
log_end

# Delete routing obstructions for final DEF
source scripts/deleteRoutingObstructions.tcl
deleteRoutingObstructions

if {![info exists standalone] || $standalone} {
  write_def $::env(RESULTS_DIR)/6_final.def
  write_verilog $::env(RESULTS_DIR)/6_final.v
  exit
}
