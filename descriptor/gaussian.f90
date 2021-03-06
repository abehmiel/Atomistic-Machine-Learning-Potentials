!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
       subroutine calculate_g2(neighbornumbers, neighborpositions, &
       g_number, g_eta, rc, cutofffn, ri, num_neighbors, ridge)
               
              implicit none
              integer, dimension(num_neighbors):: neighbornumbers
              integer, dimension(1):: g_number
              double precision, dimension(num_neighbors, 3):: &
              neighborpositions
              double precision, dimension(3):: ri
              integer:: num_neighbors
              double precision::  g_eta, rc
              character:: cutofffn
              double precision:: ridge
!f2py         intent(in):: neighbornumbers, neighborpositions, g_number
!f2py         intent(in):: g_eta, rc, ri
!f2py         intent(hide):: num_neighbors
!f2py         intent(out):: ridge
              integer:: j, match, xyz
              double precision, dimension(3):: Rij_vector
              double precision:: Rij, term

              ridge = 0.0d0
              do j = 1, num_neighbors
                  match = compare(neighbornumbers(j), g_number(1))
                  if (match == 1) then
                    do xyz = 1, 3
                      Rij_vector(xyz) = &
                      neighborpositions(j, xyz) - ri(xyz)
                    end do
                    Rij = sqrt(dot_product(Rij_vector, Rij_vector))
                    term = exp(-g_eta*(Rij**2.0d0) / (rc ** 2.0d0))
                    term = term * cutoff_fxn(Rij, rc)
                    ridge = ridge + term
                  end if
              end do

      CONTAINS

      function compare(try, val) result(match)
!     Returns 1 if try is the same set as val, 0 if not.
              implicit none
              integer, intent(in):: try, val
              integer:: match
              if (try == val) then
                      match = 1
              else
                      match = 0
              end if
      end function compare

      function cutoff_fxn(r, rc)
              double precision:: r, rc, cutoff_fxn, pi
              if (r > rc) then
                      cutoff_fxn = 0.0d0
              else
                      pi = 4.0d0 * datan(1.0d0)
                      cutoff_fxn = 0.5d0 * (cos(pi*r/rc) + 1.0d0)
              end if
      end function
      
      end subroutine calculate_g2
      
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
       
      subroutine calculate_g4(neighbornumbers, neighborpositions, &
      g_numbers, g_gamma, g_zeta, g_eta, rc, cutofffn, ri, &
      num_neighbors, ridge)
               
              implicit none
              integer, dimension(num_neighbors):: neighbornumbers
              integer, dimension(2):: g_numbers
              double precision, dimension(num_neighbors, 3):: &
              neighborpositions
              double precision, dimension(3):: ri
              integer:: num_neighbors
              double precision:: g_gamma, g_zeta, g_eta, rc
              character:: cutofffn
              double precision:: ridge
!f2py         intent(in):: neighbornumbers, neighborpositions
!f2py         intent(in):: g_numbers, g_gamma, g_zeta
!f2py         intent(in):: g_eta, rc, ri
!f2py         intent(hide):: num_neighbors
!f2py         intent(out):: ridge
              integer:: j, k, match, xyz
              double precision, dimension(3):: Rij_vector, Rik_vector
              double precision, dimension(3):: Rjk_vector
              double precision:: Rij, Rik, Rjk, costheta, term

              ridge = 0.0d0
              do j = 1, num_neighbors
                do k = (j + 1), num_neighbors
                  match = compare(neighbornumbers(j), &
                  neighbornumbers(k), g_numbers(1), g_numbers(2))
                  if (match == 1) then
                    do xyz = 1, 3
                      Rij_vector(xyz) = &
                      neighborpositions(j, xyz) - ri(xyz)
                      Rik_vector(xyz) = &
                      neighborpositions(k, xyz) - ri(xyz)
                      Rjk_vector(xyz) = &
                      neighborpositions(k, xyz) - &
                      neighborpositions(j, xyz)
                    end do
                    Rij = sqrt(dot_product(Rij_vector, Rij_vector))
                    Rik = sqrt(dot_product(Rik_vector, Rik_vector))
                    Rjk = sqrt(dot_product(Rjk_vector, Rjk_vector))
                    costheta = &
                    dot_product(Rij_vector, Rik_vector) / Rij / Rik
                    term = (1.0d0 + g_gamma * costheta)**g_zeta
                    term = term*&
                    exp(-g_eta*(Rij**2 + Rik**2 + Rjk**2)&
                    /(rc ** 2.0d0))
                    term = term*cutoff_fxn(Rij, rc)
                    term = term*cutoff_fxn(Rik, rc)
                    term = term*cutoff_fxn(Rjk, rc)
                    ridge = ridge + term
                  end if
                end do
              end do
              ridge = ridge * 2.0d0**(1.0d0 - g_zeta)


      CONTAINS

      function compare(try1, try2, val1, val2) result(match)
!     Returns 1 if (try1, try2) is the same set as (val1, val2), 0 if not.
              implicit none
              integer, intent(in):: try1, try2, val1, val2
              integer:: match
              integer:: ntry1, ntry2, nval1, nval2
              ! First sort to avoid endless logical loops.
              if (try1 < try2) then
                      ntry1 = try1
                      ntry2 = try2
              else
                      ntry1 = try2
                      ntry2 = try1
              end if
              if (val1 < val2) then
                      nval1 = val1
                      nval2 = val2
              else
                      nval1 = val2
                      nval2 = val1
              end if
              if (ntry1 == nval1 .AND. ntry2 == nval2) then
                      match = 1
              else
                      match = 0
              end if
      end function compare

      function cutoff_fxn(r, rc)
              double precision:: r, rc, cutoff_fxn, pi
              if (r > rc) then
                      cutoff_fxn = 0.0d0
              else
                      pi = 4.0d0 * datan(1.0d0)
                      cutoff_fxn = 0.5d0 * (cos(pi*r/rc) + 1.0d0)
              end if
      end function
      
      end subroutine calculate_g4
      
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
          
       subroutine calculate_g2_prime(neighborindices, neighbornumbers, &
       neighborpositions, g_number, g_eta, rc, cutofffn, i, ri, m, l, &
       num_neighbors, ridge)
               
              implicit none
              integer, dimension(num_neighbors):: neighborindices
              integer, dimension(num_neighbors):: neighbornumbers
              integer, dimension(1):: g_number
              double precision, dimension(num_neighbors, 3):: &
              neighborpositions
              double precision, dimension(3):: ri, Rj
              integer:: num_neighbors, m, l, i
              double precision::  g_eta, rc
              character:: cutofffn
              double precision:: ridge
!f2py         intent(in):: neighborindices, neighbornumbers
!f2py         intent(in):: neighborpositions, g_number
!f2py         intent(in):: g_eta, rc, i, ri, m, l
!f2py         intent(hide):: num_neighbors
!f2py         intent(out):: ridge
              integer:: j, match, xyz
              double precision, dimension(3):: Rij_vector
              double precision:: Rij, term1, dRijdRml

              ridge = 0.0d0
              do j = 1, num_neighbors
                  match = compare(neighbornumbers(j), g_number(1))
                  if (match == 1) then
                    do xyz = 1, 3
                      Rj(xyz) = neighborpositions(j, xyz)
                      Rij_vector(xyz) = Rj(xyz) - ri(xyz)
                    end do
                    dRijdRml = &
                     dRij_dRml(i, neighborindices(j), ri, Rj, m, l)
                    if (dRijdRml /= 0.0d0) then
					  Rij = sqrt(dot_product(Rij_vector, Rij_vector))
                      term1 = - 2.0d0 * g_eta * Rij * & 
                      cutoff_fxn(Rij, rc) / (rc ** 2.0d0) + &
                      cutoff_fxn_prime(Rij, rc)
                      ridge = ridge + exp(- g_eta * (Rij**2.0d0) / &
                      (rc ** 2.0d0)) * term1 * dRijdRml
                    end if
                  end if
              end do

      CONTAINS

      function compare(try, val) result(match)
!     Returns 1 if try is the same set as val, 0 if not.
              implicit none
              integer, intent(in):: try, val
              integer:: match
              if (try == val) then
                      match = 1
              else
                      match = 0
              end if
      end function compare
      
      function cutoff_fxn(r, rc)
              double precision:: r, rc, cutoff_fxn, pi
              if (r > rc) then
                      cutoff_fxn = 0.0d0
              else
                      pi = 4.0d0 * datan(1.0d0)
                      cutoff_fxn = 0.5d0 * (cos(pi*r/rc) + 1.0d0)
              end if
      end function
      
      function cutoff_fxn_prime(r, rc)
              double precision:: r, rc, cutoff_fxn_prime, pi
              if (r > rc) then
                      cutoff_fxn_prime = 0.0d0
              else
                      pi = 4.0d0 * datan(1.0d0)
                      cutoff_fxn_prime = -0.5d0 * pi * sin(pi*r/rc) &
                       / rc
              end if
      end function
      
      function dRij_dRml(i, j, Ri, Rj, m, l)
              integer i, j, m, l
              double precision, dimension(3):: Ri, Rj, Rij_vector
              double precision:: dRij_dRml, Rij
              do xyz = 1, 3
                      Rij_vector(xyz) = Rj(xyz) - Ri(xyz)
              end do
              Rij = sqrt(dot_product(Rij_vector, Rij_vector))
              if ((m == i) .AND. (i /= j)) then
                      dRij_dRml = - (Rj(l + 1) - Ri(l + 1)) / Rij
              else if ((m == j) .AND. (i /= j)) then
                      dRij_dRml = (Rj(l + 1) - Ri(l + 1)) / Rij
              else
                      dRij_dRml = 0.0d0
              end if
      end function
      
      end subroutine calculate_g2_prime
      
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
      subroutine calculate_g4_prime(neighborindices, neighbornumbers, &
      neighborpositions, g_numbers, g_gamma, g_zeta, g_eta, rc, &
      cutofffn, i, ri, m, l, num_neighbors, ridge)
               
              implicit none
              integer, dimension(num_neighbors):: neighborindices
              integer, dimension(num_neighbors):: neighbornumbers
              integer, dimension(2):: g_numbers
              double precision, dimension(num_neighbors, 3):: &
              neighborpositions
              double precision, dimension(3):: ri, Rj, Rk
              integer:: num_neighbors, i, m, l
              double precision:: g_gamma, g_zeta, g_eta, rc
              character:: cutofffn
              double precision:: ridge
!f2py         intent(in):: neighbornumbers, neighborpositions
!f2py         intent(in):: g_numbers, g_gamma, g_zeta
!f2py         intent(in):: g_eta, rc, ri, neighborindices , i, m, l
!f2py         intent(hide):: num_neighbors
!f2py         intent(out):: ridge
              integer:: j, k, match, xyz
              double precision, dimension(3):: Rij_vector, Rik_vector
              double precision, dimension(3):: Rjk_vector
              double precision:: Rij, Rik, Rjk, costheta
              double precision:: c1, fcRij, fcRik, fcRjk
              double precision:: fcRijfcRikfcRjk, dCosthetadRml
              double precision:: dRijdRml, dRikdRml, dRjkdRml
              double precision:: term1, term2, term3, term4, term5
              double precision:: term6

              ridge = 0.0d0
              do j = 1, num_neighbors
                do k = (j + 1), num_neighbors
                  match = compare(neighbornumbers(j), &
                  neighbornumbers(k), g_numbers(1), g_numbers(2))
                  if (match == 1) then
                    do xyz = 1, 3
                      Rj(xyz) = neighborpositions(j, xyz)
                      Rk(xyz) = neighborpositions(k, xyz)
                      Rij_vector(xyz) = Rj(xyz) - ri(xyz)
                      Rik_vector(xyz) = Rk(xyz) - ri(xyz)
                      Rjk_vector(xyz) = Rk(xyz) - Rj(xyz)
                    end do
                    Rij = sqrt(dot_product(Rij_vector, Rij_vector))
                    Rik = sqrt(dot_product(Rik_vector, Rik_vector))
                    Rjk = sqrt(dot_product(Rjk_vector, Rjk_vector))
                    costheta = &
                    dot_product(Rij_vector, Rik_vector) / Rij / Rik
                    c1 = (1.0d0 + g_gamma * costheta)
                    fcRij = cutoff_fxn(Rij, rc)
                    fcRik = cutoff_fxn(Rik, rc)
                    fcRjk = cutoff_fxn(Rjk, rc)
                    if (g_zeta == 1.0d0) then
                        term1 = exp(-g_eta*(Rij**2 + Rik**2 + Rjk**2)&
                        / (rc ** 2.0d0))
                    else
                        term1 = (c1**(g_zeta - 1.0d0)) &
                             * exp(-g_eta*(Rij**2 + Rik**2 + Rjk**2)&
                             / (rc ** 2.0d0))
                    end if
                    term2 = 0.d0
                    fcRijfcRikfcRjk = fcRij * fcRik * fcRjk
                    dCosthetadRml = &
                    dCos_ijk_dR_ml(i, neighborindices(j), &
                    neighborindices(k), ri, Rj, Rk, m, l)
                    if (dCosthetadRml /= 0.d0) then
                      term2 = term2 + g_gamma * g_zeta * dCosthetadRml
                    end if
                    dRijdRml = &
                    dRij_dRml(i, neighborindices(j), ri, Rj, m, l)
                    if (dRijdRml /= 0.0d0) then
                        term2 = &
                        term2 - 2.0d0 * c1 * g_eta * Rij * dRijdRml &
                        / (rc ** 2.0d0)
                    end if
                    dRikdRml = &
                    dRij_dRml(i, neighborindices(k), ri, Rk, m, l)
                    if (dRikdRml /= 0.0d0) then
                        term2 = &
                        term2 - 2.0d0 * c1 * g_eta * Rik * dRikdRml &
                        / (rc ** 2.0d0)
                    end if
                    dRjkdRml =  &
                    dRij_dRml(neighborindices(j), neighborindices(k), &
                    Rj, Rk, m, l)
                    if (dRjkdRml /= 0.0d0) then
                        term2 = &
                        term2 - 2.0d0 * c1 * g_eta * Rjk * dRjkdRml &
                        / (rc ** 2.0d0)
                    end if
                    term3 = fcRijfcRikfcRjk * term2
                    term4 = &
                    cutoff_fxn_prime(Rij, rc) * dRijdRml * fcRik * fcRjk
                    term5 = &
                    fcRij * cutoff_fxn_prime(Rik, rc) * dRikdRml * fcRjk
                    term6 = &
                    fcRij * fcRik * cutoff_fxn_prime(Rjk, rc) * dRjkdRml
                    ridge = ridge + &
                    term1 * (term3 + c1 * (term4 + term5 + term6))
                  end if
                end do
              end do
              ridge = ridge * (2.0d0**(1.0d0 - g_zeta))

      CONTAINS

      function compare(try1, try2, val1, val2) result(match)
!     Returns 1 if (try1, try2) is the same set as (val1, val2), 0 if not.
              implicit none
              integer, intent(in):: try1, try2, val1, val2
              integer:: match
              integer:: ntry1, ntry2, nval1, nval2
              ! First sort to avoid endless logical loops.
              if (try1 < try2) then
                      ntry1 = try1
                      ntry2 = try2
              else
                      ntry1 = try2
                      ntry2 = try1
              end if
              if (val1 < val2) then
                      nval1 = val1
                      nval2 = val2
              else
                      nval1 = val2
                      nval2 = val1
              end if
              if (ntry1 == nval1 .AND. ntry2 == nval2) then
                      match = 1
              else
                      match = 0
              end if
      end function compare

      function cutoff_fxn(r, rc)
              double precision:: r, rc, cutoff_fxn, pi
              if (r > rc) then
                      cutoff_fxn = 0.0d0
              else
                      pi = 4.0d0 * datan(1.0d0)
                      cutoff_fxn = 0.5d0 * (cos(pi*r/rc) + 1.0d0)
              end if
      end function
      
      function cutoff_fxn_prime(r, rc)
              double precision:: r, rc, cutoff_fxn_prime, pi
              if (r > rc) then
                      cutoff_fxn_prime = 0.0d0
              else
                      pi = 4.0d0 * datan(1.0d0)
                      cutoff_fxn_prime = -0.5d0 * pi * sin(pi*r/rc) &
                       / rc
              end if
      end function
      
      function dRij_dRml(i, j, Ri, Rj, m, l)
              integer i, j, m, l
              double precision, dimension(3):: Ri, Rj, Rij_vector
              double precision:: dRij_dRml, Rij
              do xyz = 1, 3
                      Rij_vector(xyz) = Rj(xyz) - Ri(xyz)
              end do
              Rij = sqrt(dot_product(Rij_vector, Rij_vector))
              if ((m == i) .AND. (i /= j)) then
                      dRij_dRml = - (Rj(l + 1) - Ri(l + 1)) / Rij
              else if ((m == j) .AND. (i /= j)) then
                      dRij_dRml = (Rj(l + 1) - Ri(l + 1)) / Rij
              else
                      dRij_dRml = 0.0d0
              end if
      end function
      
      function dCos_ijk_dR_ml(i, j, k, ri, Rj, Rk, m, l)
      implicit none
      integer:: i, j, k, m, l
      double precision:: dCos_ijk_dR_ml
      double precision, dimension(3):: ri, Rj, Rk
      integer, dimension(3):: dRijdRml, dRikdRml
      double precision:: dRijdRml_, dRikdRml_
      
      do xyz = 1, 3
            Rij_vector(xyz) = Rj(xyz) - ri(xyz)
            Rik_vector(xyz) = Rk(xyz) - ri(xyz) 
      end do
      Rij = sqrt(dot_product(Rij_vector, Rij_vector))
      Rik = sqrt(dot_product(Rik_vector, Rik_vector))
      dCos_ijk_dR_ml = 0.0d0

      dRijdRml = dRij_dRml_vector(i, j, m, l)
      if ((dRijdRml(1) /= 0) .OR. (dRijdRml(2) /= 0) .OR. &
      (dRijdRml(3) /= 0)) then
        dCos_ijk_dR_ml = dCos_ijk_dR_ml + 1.0d0 / (Rij * Rik) * &
        dot_product(dRijdRml, Rik_vector)
      end if

      dRikdRml = dRij_dRml_vector(i, k, m, l)
      if ((dRikdRml(1) /= 0) .OR. (dRikdRml(2) /= 0) .OR. &
      (dRikdRml(3) /= 0)) then
        dCos_ijk_dR_ml =  dCos_ijk_dR_ml + 1.0d0 / (Rij * Rik) * &
        dot_product(dRikdRml, Rij_vector)
      end if

      dRijdRml_ = dRij_dRml(i, j, ri, Rj, m, l)
      if (dRijdRml_ /= 0.0d0) then
        dCos_ijk_dR_ml =  dCos_ijk_dR_ml - 1.0d0 / (Rij * Rij * Rik) * &
        dot_product(Rij_vector, Rik_vector) * dRijdRml_
      end if

      dRikdRml_ = dRij_dRml(i, k, ri, Rk, m, l)
      if (dRikdRml_ /= 0.0d0) then
        dCos_ijk_dR_ml =  dCos_ijk_dR_ml - 1.0d0 / (Rij * Rik * Rik) * &
        dot_product(Rij_vector, Rik_vector) * dRikdRml_
      end if
     
      end function

      function dRij_dRml_vector(i, j, m, l)
      implicit none
      integer:: i, j, m, l, c1
      integer, dimension(3):: dRij_dRml_vector
      
      if ((m /= i) .AND. (m /= j)) then
          dRij_dRml_vector(1) = 0
          dRij_dRml_vector(2) = 0
          dRij_dRml_vector(3) = 0
      else
          c1 = Kronecker(m, j) - Kronecker(m, i)
          dRij_dRml_vector(1) = c1 * Kronecker(0, l)
          dRij_dRml_vector(2) = c1 * Kronecker(1, l)
          dRij_dRml_vector(3) = c1 * Kronecker(2, l)
      end if

      end function
       
      function Kronecker(i, j)
      implicit none
      integer:: i, j
      integer:: Kronecker
      
      if (i == j) then
        Kronecker = 1
      else
        Kronecker = 0
      end if
    
      end function

      end subroutine calculate_g4_prime
      
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
