! This file is copied and modified from QUANTUM ESPRESSO
! Kun Cao, Henry Lambert, Feliciano Giustino
 
!
! Copyright (C) 2001-2008 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!-----------------------------------------------------------------------
subroutine sgam_ph_new (at, bg, nsym, s, irt, tau, rtau, nat)
  !-----------------------------------------------------------------------
  !
  !     This routine computes the vector rtau which contains for each
  !     atom and each rotation the vector S\tau_a - \tau_b, where
  !     b is the rotated a atom, given by the array irt. These rtau are
  !     non zero only if fractional translations are present.
  !
  USE kinds, ONLY : DP
  USE io_global,       ONLY : stdout

  implicit none
  !
  !     first the dummy variables
  !
  integer, intent(in) :: nsym, s (3, 3, 48), nat, irt (48, nat)
  ! nsym: number of symmetries of the point group
  ! s:    matrices of symmetry operations
  ! nat : number of atoms in the unit cell
  ! irt(n,m) = transformed of atom m for symmetry n
  real(DP), intent(in) :: at (3, 3), bg (3, 3), tau (3, nat)
  ! at: direct lattice vectors
  ! bg: reciprocal lattice vectors
  ! tau: coordinates of the atoms
  real(DP), intent(out):: rtau (3, 48, nat)
  ! rtau: the direct translations
  !
  !    here the local variables
  !
  integer :: na, nb, isym, ipol
  ! counters on: atoms, symmetry operations, polarization
  real(DP) , allocatable :: xau (:,:)
  real(DP) :: ft (3)
  !
  allocate (xau(3,nat))
  !
  !   compute the atomic coordinates in crystal axis, xau
  !
  do na = 1, nat
     do ipol = 1, 3
        xau (ipol, na) = bg (1, ipol) * tau (1, na) + &
                         bg (2, ipol) * tau (2, na) + &
                         bg (3, ipol) * tau (3, na)
     enddo
  enddo
  !
  !    for each symmetry operation, compute the atomic coordinates
  !    of the rotated atom, ft, and calculate rtau = Stau'-tau
  !
  rtau(:,:,:) = 0.0_dp
  do isym = 1, nsym
     do na = 1, nat
        nb = irt (isym, na)
        do ipol = 1, 3
           ft (ipol) = s (1, ipol, isym) * xau (1, na) + &
                       s (2, ipol, isym) * xau (2, na) + &
                       s (3, ipol, isym) * xau (3, na) - xau (ipol, nb)
        enddo
        do ipol = 1, 3
           rtau (ipol, isym, na) = at (ipol, 1) * ft (1) + &
                                   at (ipol, 2) * ft (2) + &
                                   at (ipol, 3) * ft (3)
        enddo
     enddo
  enddo
  !
  !    deallocate workspace
  !
  deallocate(xau)
  return
end subroutine sgam_ph_new
!
!-----------------------------------------------------------------------
subroutine smallg_q (xq, modenum, at, bg, nrot, s, ftau, sym, minus_q)
  !-----------------------------------------------------------------------
  !
  ! This routine selects, among the symmetry matrices of the point group
  ! of a crystal, the symmetry operations which leave q unchanged.
  ! Furthermore it checks if one of the above matrices send q --> -q+G.
  ! In this case minus_q is set true.
  !
  !  input-output variables
  !
  USE kinds, ONLY : DP
  USE control_ph, only: dbext, do_elec, symoff
  USE io_global,       ONLY : stdout
  USE symm_base, only: sname, t_rev
  implicit none

  real(DP), parameter :: accep = 1.e-5_dp

  real(DP), intent(in) :: bg (3, 3), at (3, 3), xq (3)
  ! input: the reciprocal lattice vectors
  ! input: the direct lattice vectors
  ! input: the q point of the crystal

  integer, intent(in) :: s (3, 3, 48), nrot, ftau (3, 48), modenum
  ! input: the symmetry matrices
  ! input: number of symmetry operations
  ! input: fft grid dimension (units for ftau)
  ! input: fractionary translation of each symmetr
  ! input: main switch of the program, used for
  !        q<>0 to restrict the small group of q
  !        to operation such that Sq=q (exactly,
  !        without G vectors) when iswitch = -3.
  logical, intent(inout) :: sym (48), minus_q
  ! input-output: .true. if symm. op. S q = q + G
  ! output: .true. if there is an op. sym.: S q = - q + G
  !
  !  local variables
  !

  real(DP) :: aq (3), raq (3), zero (3), aBext(3), raBext(3), bplus(3),bminus(3)
  ! q vector in crystal basis
  ! the rotated of the q vector
  ! the zero vector

  integer :: irot, ipol, jpol
  ! counter on symmetry op.
  ! counter on polarizations
  ! counter on polarizations

  logical :: eqvect
  ! logical function, check if two vectors are equa
  !
  ! return immediately (with minus_q=.true.) if xq=(0,0,0)
  !
!  minus_q = .true.
!  if ( (xq (1) == 0.d0) .and. (xq (2) == 0.d0) .and. (xq (3) == 0.d0) ) &
!       return
  !
  !   Set to zero some variables
  !
  minus_q = .false.
  zero(:) = 0.d0
  !
  !   Transform xq to the crystal basis
  !
  aq = xq
  abext(:)= real(dbext(:))

  call cryst_to_cart (1, aq, at, -1)
  call cryst_to_cart (1, abext, at, -1)
  !KC: for test 
  write(stdout,'("5x, aq, abext in crystal basis", 6f10.5)')aq, abext
  !
  !   Test all symmetries to see if this operation send Sq in q+G or in -q+G
  !

  do irot = 1, nrot
     if (.not.sym (irot) ) goto 100
     if (t_rev(irot)==1) then
     sym (irot)= .false.
     goto 100
     end if
     raq(:) = 0.d0
     rabext(:)=0.d0
     do ipol = 1, 3
        do jpol = 1, 3
           raq(ipol) = raq(ipol) + DBLE( s(ipol,jpol,irot) ) * aq( jpol)
           rabext(ipol)=rabext(ipol)+ DBLE( s(ipol,jpol,irot) )*abext(jpol)
        enddo
     enddo
!     sym (irot) = eqvect (raq, aq, zero, accep)
!    if (sname(irot)(1:3)=='inv') rabext=-rabext
!     IF(t_rev(irot)==1) THEN
!        raq(:)=-raq(:)
!        rabext(:) = -rabext(:)
!        IF(sname(irot)(1:3)=='inv')rabext(:) = -rabext(:)
!     ENDIF
 
     

!     if(.not. do_elec) then
     sym(irot) = .true.

     DO ipol=1, 3
       sym(irot)=sym(irot) .and. (abs(raq(ipol)-aq(ipol))<1.0d-5)
     ENDDO

!     IF(t_rev(irot)==1) THEN
!       Do ipol = 1, 3 
!       sym(irot)=sym(irot) .and. (abs(rabext(ipol)-abext(ipol))<1.0d-5)
!       ENDDO
!     ENDIF
!       do ipol=1, 3
!          sym(irot)= (abs(raq(ipol)-aq(ipol))<1.0d-5)
!       end do
   
!         bplus(:)= rabext(:)+abext(:)
!         bminus(:) = rabext(:)-abext(:)
!         sym(irot) = sym(irot) .and. (norm2(bplus)< 1.0d-5 .or. norm2(bminus)< 1.0d-5)
!     end if 
     !
     !  if "iswitch.le.-3" (modenum.ne.0) S must be such that Sq=q exactly !
     !
 !    if (modenum.ne.0 .and. sym(irot) ) then
 !      do ipol = 1, 3
 !    if( sym(irot) .and. All(abs(raq(:)-aq(:)) < 1.0d-5)) 
 !       enddo
 !    endif
!     if (.not.minus_q) then
!     if (sym(irot).and..not.minus_q) then
!        raq = - raq
!        minus_q = eqvect (raq, aq, zero, accep)
!     endif
100  continue
  enddo

  !
  !  if "iswitch.le.-3" (modenum.ne.0) time reversal symmetry is not included !
  !
!  if (modenum.ne.0) minus_q = .false.
!     minus_q = .false.
  !
  return
end subroutine smallg_q

