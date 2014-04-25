# Makefile for magnon (MG)

include ../../make.sys

# location of needed modules
MODFLAGS= $(MOD_FLAG)../../iotk/src $(MOD_FLAG)../../Modules \
          $(MOD_FLAG)../../PW/src $(MOD_FLAG).

MAGOBJS = \
acfdtest.o \
add_dkmds.o \
add_for_charges.o \
addcore.o \
adddvepsi_us.o \
adddvscf.o \
addnlcc.o \
addusdbec.o \
addusdbec_nc.o \
addusddens.o \
addusddense.o \
addusldos.o \
allocate_part.o \
allocate_pert.o \
allocate_phq.o \
apply_dpot.o \
bcast_ph_input.o \
cch_psi_all.o \
cg_psi.o \
ccg_psi.o \
cgsolve_all.o \
cgsolve_all_imfreq.o \
ch_psi_all.o \
check_initial_status.o \
check_q_points_sym.o \
check_restart_recover.o \
clean_pw_ph.o \
clinear.o \
close_phq.o \
commutator_Hx_psi.o \
compute_becalp.o \
compute_becsum_ph.o \
compute_drhous.o \
compute_drhous_nc.o \
compute_dvloc.o \
compute_nldyn.o \
compute_vsgga.o \
compute_weight.o \
deallocate_part.o \
deallocate_phq.o \
davcio_drho.o \
dfile_autoname.o \
dfile_star.o \
dgradcorr.o \
dielec.o \
drho.o \
drhodv.o \
drhodvloc.o \
drhodvnl.o \
drhodvus.o \
dv_of_drho.o \
dvkb3.o \
dvpsi_e.o \
dvqpsi_mag_us.o \
ef_shift.o \
generate_dynamical_matrix_c.o \
generate_effective_charges_c.o \
gmressolve_all.o \
h_psiq.o \
incdrhoscf.o \
incdrhoscf_nc.o \
incdrhous.o \
incdrhous_nc.o \
initialize_ph.o \
io_dyn_mat.o \
io_dyn_mat_old.o \
io_pattern.o \
localdos.o \
mix_pot.o \
mode_group.o \
newdq.o \
openfilq.o \
orthogonalize.o \
phcom.o \
phescf.o \
phq_init.o \
phq_readin.o \
phq_recover.o \
phq_setup.o \
phq_summary.o \
phqscf.o \
ph_restart.o \
polariz.o \
print_clock_ph.o \
prepare_q.o \
prepare_sym_analysis.o \
psidspsi.o \
psymdvscf.o \
psyme.o \
psym_dmag.o \
psym_dmage.o \
punch_plot_e.o \
q_points.o \
q2qstar_ph.o \
qdipol_cryst.o \
random_matrix.o \
read_wfc_rspace_and_fwfft.o \
rotate_dvscf_star.o \
rotate_and_add_dyn.o \
run_pwscf.o \
save_ph_input.o \
set_defaults_pw.o \
set_drhoc.o \
set_small_group_of_q.o \
setlocq.o \
setqmod.o \
setup_dgc.o \
sgam_ph.o \
smallgq.o \
solve_e.o \
solve_e_fpol.o \
solve_linter.o \
star_q.o \
stop_ph.o \
summarize.o \
sym_def.o \
sym_dmag.o \
sym_dmage.o \
symdvscf.o \
syme.o \
symm.o \
tra_write_matrix.o \
trntnsc.o \
write_matrix.o \
write_modes.o \
write_rec.o 

RAMANOBJS =    \
cft_wave.o \
psyme2.o   \
chi_test.o \
dielec_test.o \
dvpsi_e2.o \
el_opt.o   \
hdiag.o    \
pcgreen.o  \
ramanm.o   \
syme2.o    \
solve_e2.o \
solve_e_nscf.o \
d2mxc.o    \
raman_mat.o\
raman.o    \
dhdrhopsi.o\
set_dvscf.o

PHAUXOBJS = \
rigid.o \
write_eigenvectors.o

PWOBJS = ../../PW/src/libpw.a
QEMODS = ../../Modules/libqemod.a


LIBOBJS	= ../../flib/ptools.a ../../flib/flib.a ../../clib/clib.a ../../iotk/src/libiotk.a

TLDEPS= bindir mods libs pw

all : tldeps libs-ph ph.x

libs-ph : libph.a libphaux.a

ph.x : magnon.o libph.a $(PWOBJS) $(LIBOBJS)
	$(LD) $(LDFLAGS) -o $@ magnon.o libph.a \
		 $(PWOBJS) $(QEMODS) $(LIBOBJS) $(LIBS)
	- ( cd ../../bin ; ln -fs ../PHonon/PH/ph.x . )

fqha.x : fqha.o $(PWOBJS) $(QEMODS) $(LIBOBJS)
	$(LD) $(LDFLAGS) -o $@ fqha.o \
                 $(PWOBJS) $(QEMODS) $(LIBOBJS) $(LIBS)
	- ( cd ../../bin ; ln -fs ../PHonon/PH/$@ . )

tldeps:
	test -n "$(TLDEPS)" && ( cd ../.. ; $(MAKE) $(MFLAGS) $(TLDEPS) || exit 1) || :

libph.a : $(MAGOBJS) $(RAMANOBJS)
	$(AR) $(ARFLAGS) $@ $?
	$(RANLIB) $@

libphaux.a : $(PHAUXOBJS)
	$(AR) $(ARFLAGS) $@ $?
	$(RANLIB) $@
	
clean :
	- /bin/rm -f *.x *.o *.a *~ *.F90 *.d *.mod *.i *.L
	- /bin/rm -rf ../../bin/ph.x ../../bin/dynmat.x ../../bin/matdyn.x 

include make.depend
# DO NOT DELETE
