! this module do nothing, just to compile fireball.x 
!+++++++++++++++++++++++++++++++++++++++++++++

module qmmm_module

  implicit none
  ! data structures
  public :: qmmm_struct
  
  
  type qmmm_structure
   !double precision, dimension(:,:), pointer :: qm_coords     !Cartesian coordinates of ALL (real+link) qm atoms [3*(nquant+nlink) long]
   !double precision, dimension(:,:), pointer :: qm_vel        !Cartesian coordinates of ALL (real+link) qm atoms [3*(nquant+nlink) long
   integer                        :: qm_mm_pairs     !Number of pairs per QM atom. - length of pair_list. 
   double precision, dimension(:,:), pointer :: dxyzcl  !Used to store the forces generated by qm_mm before adding them to the main f array.
   double precision, dimension(:,:), pointer :: qm_xcrd         !Contains imaged mm coordinates and scaled mm charges.
   !double precision, dimension(:), pointer :: qm_xcrd_dist

  end type qmmm_structure
  


end module qmmm_module

