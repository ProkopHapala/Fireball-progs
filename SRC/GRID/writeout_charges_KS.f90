! copyright info:
!
!                             @Copyright 2001
!                            Fireball Committee
! Brigham Young University - James P. Lewis, Chair
! Arizona State University - Otto F. Sankey
! University of Regensburg - Juergen Fritsch
! Universidad de Madrid - Jose Ortega

! Other contributors, past and present:
! Auburn University - Jian Jun Dong
! Arizona State University - Gary B. Adams
! Arizona State University - Kevin Schmidt
! Arizona State University - John Tomfohr
! Lawrence Livermore National Laboratory - Kurt Glaesemann
! Motorola, Physical Sciences Research Labs - Alex Demkov
! Motorola, Physical Sciences Research Labs - Jun Wang
! Ohio University - Dave Drabold

!
! fireball-qmd is a free (GPLv3) open project.

! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <http://www.gnu.org/licenses/>.

 
! writeout_chargesG.f90
! Program Description
! ===========================================================================
!       Write out the charges for restart capabilities. Adapted to grid calc.
!
! ===========================================================================
! Code written by:
! James P. Lewis
! Department of Physics and Astronomy
! Brigham Young University
! N233 ESC P.O. Box 24658
! Provo, UT 84602-4658
! FAX (801) 422-2265
! Office Telephone (801) 422-7444
!
! (modified by P.Jelinek; May 2005)
! ===========================================================================
!
! Program Declaration
! ===========================================================================
 subroutine writeout_charges_KS (natoms, ifixcharge, iqout, iwrtcharges, &
     &                               iwrtdensity, basisfile, symbol)
   use charges
   use density
   use interactions
   use neighbor_map
   implicit none
 
! Argument Declaration and Description
! ===========================================================================
! Input
   integer, intent (in) :: natoms
   integer, intent (in) :: ifixcharge
   integer, intent (in) :: iqout
   integer, intent (in) :: iwrtcharges
   integer, intent (in) :: iwrtdensity

   character (len=40) basisfile
   character (len=2), dimension (natoms) :: symbol
   
 
! Local Parameters and Data Declaration
! ===========================================================================
 
! Local Variable Declaration and Description
! ===========================================================================
   integer iatom
   integer imu
   integer in1, in2
   integer ineigh
   integer inu
   integer issh
   integer jatom
 
! Allocate Arrays
! ===========================================================================
 
! Procedure
! ===========================================================================
! ****************************************************************************
!
! W R I T E    O U T    D E N S I T Y  
! ****************************************************************************

! write density matrix into file
! NOTE: we need the density matrix for restart in KS-scheme         
   open (unit = 20, file = 'denmat.dat', status = 'unknown')
! loop over atoms
   do iatom = 1, natoms
    in1 = imass(iatom)
    write (20,700) iatom,neighn(iatom),num_orb(in1)
! loop over neighbors
    do ineigh = 1, neighn(iatom)
     jatom = neigh_j(ineigh,iatom)
     in2 = imass(jatom)
     write (20,701) ineigh, jatom, num_orb(in2)
     do imu = 1, num_orb(in1)
       do inu = 1, num_orb(in2)
         write (20,702) rho(imu,inu,ineigh,iatom)
       end do ! do inu
     end do ! do imu
    end do ! do ineigh
   end do ! do iatom
! close file         
   close (20)

! Write out the density for the first atom.
   if (iwrtdensity .eq. 1) then
      do iatom = 1, natoms
         write (*,*) '  '
         write (*,*) ' Write out the density matrix for iatom = ', iatom
         write (*,*) ' Number of neighbors = ', neighn(iatom)
         in1 = imass(iatom)
         write (*,*) ' Number of orbitals on iatom, num_orb(in1) = ',       &
     &     num_orb(in1)
         do ineigh = 1, neighn(iatom)
            jatom = neigh_j(ineigh,iatom)
            in2 = imass(jatom)
            write (*,*) '  '
            write (*,*) ' iatom, ineigh = ', iatom, ineigh
            write (*,*) ' Number of orbitals on jatom, num_orb(in2) = ',      &
     &      num_orb(in2)
            write (*,*) ' --------------------------------------------------- '
            do imu = 1, num_orb(in1)
               write (*,400) (rho(imu,inu,ineigh,iatom), inu = 1, num_orb(in2))
            end do
         end do
      end do
   end if


   
   if (iwrtcharges .eq. 1) then
! ****************************************************************************
!
! W R I T E    O U T    L O W D I N    C H A R G E S
! ****************************************************************************
      if (iqout .eq. 1) then
         write (*,*) '  '
         write (*,*) '  '
         write (*,*) ' LOWDIN CHARGES (by shell): '
         write (*,500)
         write (*,501)
         write (*,500)
         do iatom = 1, natoms
            in1 = imass(iatom)
            write (*,502) iatom, symbol(iatom), nssh(in1),                   &
     &                   (Qout(imu,iatom), imu = 1, num_orb(in1))
         end do

         write (*,500)
         write (*,*) '  '
         write (*,*) '  '
         write (*,*) ' Total Lowdin charges for each atom: '
         write (*,500)
         do iatom = 1, natoms
            write (*,503) iatom, symbol(iatom), QLowdin_TOT(iatom)
         end do
         write (*,500)
         write (*,*) '  '
         write (*,*) '  '
      end if


! ****************************************************************************
!
! W R I T E    O U T    M U L L I K E N    C H A R G E S
! ****************************************************************************
      if (iqout .eq. 2) then
         write (*,*) '  '
         write (*,*) '  '
         write (*,*) ' MULLIKEN CHARGES (by shell): '
         write (*,500)
         write (*,501)
         write (*,500)
         do iatom = 1, natoms
            in1 = imass(iatom)
            write (*,502) iatom, symbol(iatom), nssh(in1),                   &
     &                   (Qout(imu,iatom), imu = 1, num_orb(in1))
         end do

         write (*,500)
         write (*,*) '  '
         write (*,*) '  '
         write (*,*) ' Total Mulliken charges for each atom: '
         write (*,500)
         do iatom = 1, natoms
            write (*,503) iatom, symbol(iatom), QMulliken_TOT(iatom)
         end do
         write (*,500)
         write (*,*) '  '
         write (*,*) '  '
      end if
      
      write (*,500)
      write (*,*) '  '
   end if


! ****************************************************************************
!
! W R I T E    O U T    C H A R G E S    F I L E
! ****************************************************************************
! Open the file CHARGES which contain the Lowdin charges for restart purposes.
   if (ifixcharge .eq. 0 .and. wrtout) then
      open (unit = 21, file = 'CHARGES', status = 'unknown')
      write (21,600) natoms, basisfile, iqout
      
! Write the output charges to the CHARGES file.
      do iatom = 1, natoms
         in1 = imass(iatom)
         write (21,601) (Qout(imu,iatom), imu = 1, num_orb(in1))
      end do
      close (unit = 21)
   end if
 
! Deallocate Arrays
! ===========================================================================
 
! Format Statements
! ===========================================================================
400     format (9f9.4)
500     format (70('='))
501     format (2x, ' Atom # ', 2x, ' Type ', 2x, ' Shells ', 1x,' Charges ')
502     format (3x, i5, 7x, a2, 5x, i2, 4x, 8(1x, f5.2))
503     format (3x, i5, 7x, a2, 4x, f10.4)
600     format (2x, i5, 2x, a40, 2x, i2)
601     format (2x, 18f14.8)
700     format (2x, 3i5)
701     format (3x, 3i5)
702     format (f16.8)
 
 
        return
      end subroutine writeout_charges_KS
