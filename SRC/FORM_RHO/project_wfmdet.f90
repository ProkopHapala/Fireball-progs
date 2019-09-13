! copyright info:
!
!                             @Copyright 2001
!                           Fireball Committee
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

 
! project_eh.f90
! Program Description
! ===========================================================================
!       This routine calculates the fermi energy.
!
! ===========================================================================
! Code written by:
!
! ===========================================================================
!
! Program Declaration
! ===========================================================================
        subroutine project_wfmdet ()

        use dimensions
        use constants_fireball
        use kpoints
        use charges
        use scf  
        use configuration
        use MD
        use density
      
        use interactions
        use neighbor_map
        
use nonadiabatic ! vlada
        implicit none
 
! Argument Declaration and Description
! ===========================================================================
! Input
     
! Output
  !   integer, intent(inout), dimension (norbitals, nkpoints) :: ioccupy_k  
  !   real, intent(inout), dimension (norbitals, nkpoints) :: foccupy
  !   integer, intent (in) :: ikpoint
 
! Local Parameters
! ===========================================================================

 
! Local Variable Declaration and Description
! ===========================================================================
        integer iband
        integer imu
        integer inu
        integer ielec
        integer itime_step
        integer ikpoint
real, dimension (norbitals, norbitals) :: blowre_p
real, dimension (norbitals, norbitals) :: AAA
real, dimension (norbitals, norbitals) :: BBB
real test
real pmax
real savep
real deltaE
real n1
real n2
real deltaE1
real deltaE2
real del
! Procedure
! ===========================================================================
! project electron and hole on actual wf

itime_step = itime_step_g
blowre_p(:,:)=0.0d0

!if (itime_step .eq. 19 .and. Kscf .eq. 1 ) Qin(:,:)=Qneutral(:,:) 

if ( itime_step .gt. 1  ) then
!if ( itime_step .eq. 19 .and. Kscf .gt. 30 ) then
! change the sign of WF
    !do imu=1,norbitals           
    !     if (blowre(1,imu,1) .lt. 0.0d0 .and. blowre_o(1,imu,1) .gt. 0.0d0 ) then             
    !          blowre(:,imu,1) = -1*blowre(:,imu,1)            
    !     end if
    !end do      
    AAA(:,:)=0.0d0
    BBB(:,:)=0.0d0
    AAA(:,:)=blowre_o(:,:,1)
    BBB(:,:)=blowre(:,:,1)
 
 !      write(55555,*) "AAA" ,itime_step, Kscf ,scf_achieved 
 !      do imu = 1, norbitals         
 !        write(55555,'(<norbitals>f12.6)')   (AAA(inu,imu), inu = 1, norbitals)
 !      end do   
 !      write(66666,*) "BBB", itime_step , Kscf,scf_achieved 
 !      do imu = 1, norbitals         
 !        write(66666,'(<norbitals>f12.6)')   (BBB(inu,imu), inu = 1, norbitals)
 !      end do
! calc projection, actually the overlap matrix of blowre in different time steps
blowre_p(:,:)=0.0d0
     do iband = 1, norbitals
      do imu= 1, norbitals
       do inu = 1, norbitals         
           test = test + BBB(inu,iband)*AAA(inu,imu)
       end do 
          blowre_p(iband,imu)=test
          test=0.0d0   
       end do   
      end do    
 !  call  dgemm ('N' , 'T' , 55 , 55 , 55 , 1.0d0 , AAA , 55 , BBB , 55 , 0.0d0 , blowre_p , 55)
   !    write(4444,*) itime_step, Kscf ,scf_achieved  
   !    do imu = 1, norbitals         
   !      write(4444,'(<norbitals>f6.2)')   ((blowre_p(inu,imu)), inu = 1, norbitals)
   !    end do   

write(2222,*) " map_ks map_proj ", Kscf, itime_step 
   do ielec =1, nele
     pmax = 0.0d0
      do imu = 1, norbitals
       if (abs(blowre_p(imu,map_ks(ielec))) .gt. pmax) then  
          pmax = abs(blowre_p(imu,map_ks(ielec))) 
          map_proj(ielec)=imu
       end if   
      end do 
       write(2222,'(i4,f6.1,i4,f6.1)') map_ks(ielec),foccupy_na(map_ks(ielec),1), map_proj(ielec) ,foccupy_na(map_proj(ielec),1)
   end do ! ielec 
! change occupancy (map_ks foccupy_na, ioccupy_na ) of orbital according to projection    

      write (123,*) Kscf, itime_step
      !write (123,'(<norbitals>f6.2)') (foccupy_na(inu,1), inu = 1, norbitals)
      do inu = 1, norbitals
         write (123,'(f6.1)',advance='no') foccupy_na(inu,1)
      end do
      write (123,*)

      write (124,*) Kscf, itime_step
      !write (124,'(<norbitals>i6.2)') (ioccupy_na(inu,1), inu = 1, norbitals)
      do inu = 1, norbitals
          write (124,'(i6.1)',advance='no') ioccupy_na(inu,1)
      end do
      write (124,*)

  do ielec = 1, nele
     if (map_ks(ielec) .ne. map_proj(ielec)) then          


    !     foccupy_na(map_ks(ielec),1)=foccupy_na(map_ks(ielec),1)-0.5d0 
    !     foccupy_na(map_proj(ielec),1)=foccupy_na(map_proj(ielec),1)+0.5d0 
    !     ioccupy_na(map_ks(ielec),1)=ioccupy_na(map_ks(ielec),1)-1.0d0 
    !     ioccupy_na(map_proj(ielec),1)=ioccupy_na(map_proj(ielec),1)+1.0d0 

         savep=foccupy_na(map_ks(ielec),1) 
         foccupy_na(map_ks(ielec),1)=foccupy_na(map_proj(ielec),1) 
         foccupy_na(map_proj(ielec),1)=savep 
         ioccupy_na(map_ks(ielec),1)=ioccupy_na(map_ks(ielec),1)-1.0d0 
         ioccupy_na(map_proj(ielec),1)=ioccupy_na(map_proj(ielec),1)+1.0d0 
         savep=0 

         map_ks(ielec) = map_proj(ielec)
     end if
   end do
end if !( itime_step .gt. 2000  )


      write (1233,*) Kscf, itime_step
      !write (1233,'(<norbitals>f6.1)') (foccupy_na(inu,1), inu = 1, norbitals)
      do inu = 1, norbitals
         write (1233,'(f6.1)',advance='no') foccupy_na(inu,1)
      end do
      write (1233,*)

      write (1244,*) Kscf, itime_step
      !write (1244,'(<norbitals>i6.1)') (ioccupy_na(inu,1), inu = 1, norbitals)
      do inu = 1, norbitals
          write (1244,'(i6.1)',advance='no') ioccupy_na(inu,1)
      end do
      write (1244,*)

 !     write (12444,*) Kscf, itime_step
 !     write (12444,'(<norbitals>i6.1)') (ioccupy_na_TS(inu,1), inu = 1, norbitals)

if (Kscf .eq. 200) then
blowre(:,:,1)=blowre_o(:,:,1)
!write(2222,*) " map_ks map_proj ", Kscf, itime_step
!   do ielec =1, nele
!       write(2222,*) map_ks(ielec), map_proj(ielec) 
!   end do ! ielec 
end if

200     format (' Band n = ', i4, ' k-points: ioccupy = ', i2)
201     format (' Band n = ', i4, ' foccupy = ', f6.3)

  end subroutine project_wfmdet
