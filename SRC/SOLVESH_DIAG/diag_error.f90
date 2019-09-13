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


! diag_error.f90
! Program Description
! ===========================================================================
!       This is called if and only if there is an error in the cheev
! diagonalization routine of kspace.  It bombs the job.
!
! ===========================================================================
! Code written by:
! Kurt R. Glaesemann
! Henry Eyring Center for Theoretical Chemistry
! Department of Chemistry
! University of Utah
! 315 S. 1400 E.
! Salt Lake City, UT 84112-0850
! FAX 801-581-4353
! Office telephone 801-585-1078
! ===========================================================================
!
! Program Declaration
! ===========================================================================
        subroutine diag_error (info, istyle)
        implicit none

! Argument Declaration and Description
! ===========================================================================
! Input
        integer, intent (in) :: info
        integer, intent (in) :: istyle

! Local Parameters and Data Declaration
! ===========================================================================

! Local Variable Declaration and Description
! ===========================================================================

! Procedure
! ===========================================================================
        write (*,*) '  '
        write (*,*) ' Diagonalization not successful, info = ', info
        if (info .lt. 0) then
         write (*,*) ' The ', info, '-th argument had an illegal '
         write (*,*) ' value. '
        else if(istyle .eq. 0)then
! LAPACK style errors
         write (*,*) ' It failed to converge.'
         write (*,*) info, ' off-diagonal elements of an intermediate'
         write (*,*) ' tridiagonal form did not converge to zero. '
! SCALAPACK style errors
        else if (mod(info,2) .ne. 0) then
         write (*,*) ' one or more eigenvectors failed to converge.'
         write (*,*) ' This should not have occured.  Send e-mail to'
         write (*,*) ' scalapack@cs.utk.edu if you feel like it'
        else if (mod(info/2,2) .ne. 0) then
         write (*,*) ' DARNGER Will Robinson.  Mr. Smith is in the house. '
         write (*,*) ' eigenvectors corresponding to one or more clusters '
         write (*,*) ' of eigenvalues could not be reorthogonalized'
         write (*,*) ' because of insufficient workspace.'
         write (*,*) ' We will blindly go on and hope for the best. '
         return
        else if (mod(info/4,2) .ne. 0) then
         write (*,*) ' space limit prevented computing all of the eigenvectors '
        else if (mod(info/8,2) .ne. 0) then
         write (*,*) ' PCSTEBZ failed to compute eigenvalues '
         write (*,*) ' This is very strange indeed.  It should not happen'
         write (*,*) ' Send e-mail to scalapack@cs.utk.edu if you feel like it'
        end if

! Format Statements
! ===========================================================================
        stop
        end
