! This file is copied and modified from QUANTUM ESPRESSO
! Kun Cao, Henry Lambert, Feliciano Giustino
 
!
! Copyright (C) 2009 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!-----------------------------------------------------------------------
SUBROUTINE initialize_ph()
  !-----------------------------------------------------------------------
  !
  ! This is a driver to the phonon initialization routines.
  !
  USE klist,  ONLY : nks
  USE qpoint, ONLY : nksq, ikks, ikqs
  USE control_ph, ONLY : lgamma
  USE ph_restart, ONLY : ph_writefile
  !
  IMPLICIT NONE
  INTEGER :: ik
  !
  ! ... nksq is the number of k-points, NOT including k+q points
  !
  IF ( lgamma ) THEN
     !
     nksq = nks
     ALLOCATE(ikks(nksq), ikqs(nksq))
     DO ik=1,nksq
        ikks(ik) = ik
        ikqs(ik) = ik
     ENDDO
     !
  ELSE
     !
     nksq = nks / 2
     ALLOCATE(ikks(nksq), ikqs(nksq))
     DO ik=1,nksq
        ikks(ik) = 2 * ik - 1
        ikqs(ik) = 2 * ik
     ENDDO
     !
  END IF
  !
  !  Save again the status of the run because now the bands have been
  !  calculated
  !
  CALL ph_writefile('init',0)
  !
  !  Allocate the phonon variables
  !
  CALL allocate_phq()
  !
  !  Set the main control variable of the phonon code
  !
  CALL phq_setup()
  !
  !  Recover the status if available
  !
  !  CALL phq_recover()
  !
  !  Output summary of the main variables of the phonon code
  !
    CALL phq_summary()
  !
  !  Open the files of the phonon code
  !
  CALL openfilq()
  !
  !  Initialize all quantities which do not depend on the
  !  linear response to the perturbation
  !
  CALL phq_init()
  !
  CALL print_clock( 'MAGNON' )
  !
  RETURN

END SUBROUTINE initialize_ph
