    PROGRAM splpak_test

    USE spline, wp => spline_wp
    USE iso_fortran_env

    implicit none

    integer,parameter :: ndim = 1    !! 1d problem
    integer,parameter :: nxdata = 20 !! number of points in x
    integer,parameter :: nxdata_est = 100 !! number of points for estimate plot

    real(wp),dimension(nxdata) :: xdata
    real(wp),dimension(nxdata) :: ydata
    real(wp),dimension(nxdata) :: wdata !! weights
    real(wp),dimension(nxdata_est) :: xdata_est, ydata_est, ydata_est2
    real(wp),dimension(ndim)   :: x

    integer :: ierror, istat
    integer :: i !! counter
    real(wp) :: xtrap
    real(wp) :: tru, err, errmax, f
    integer,dimension(:),allocatable :: iseed
    real(wp) :: r !! random number
    integer :: isize !! for `random_seed`
    character(len=10) :: nodes_str !! string version of `nodes`
    type(spline_fitter) :: solver
    integer,dimension(2),parameter :: figsize = [20,10] !! figure size for plot

    integer :: nodes

    !If there is a command line parameter read it as the number of nodes, otherwise set to 10
    if (command_argument_count() > 0) then
        call get_command_argument(1, nodes_str)
        read(nodes_str,*) nodes
    else
        nodes = 10
    end if

    !Use a fixed random number seed. Remove this to get a different random number each time.
    call random_seed(size=isize)
    allocate(iseed(isize)); iseed = 42
    call random_seed(put=iseed)
    deallocate(iseed)

    xtrap = 1.0_wp
    do i=1,nxdata
        call random_number(r)
        r = (r - 0.5_wp)/ 10.0_wp   ! some random noise
        wdata(i) = 1.0_wp - abs(r) ! Use weighted interpolation
        xdata(i) = real(i-1,wp)/real(nxdata-1,wp) !X data
        ydata(i) = f1(xdata(i)) !+ r !Y data including random scatter
    end do

    ! initialize:
    call solver%fit(xdata,ydata,nodes,ierror=ierror)
    if (ierror /= 0) error stop 'error calling fit'

    ! compute max error at interpolation points
    errmax = 0.0_wp
    do i=1,nxdata_est
        xdata_est(i) = real(i-1,wp)/nxdata_est
        x(1) = xdata_est(i)
        f = solver%evaluate(xdata_est(i))
        ydata_est(i) = f
        f = solver%evaluate_deriv(xdata_est(i),1)
        ydata_est2(i) = f
        if (ierror /= 0) error stop 'error calling evaluate'
        tru    = f1(xdata_est(i))
        err    = abs(tru-ydata_est(i))
        errmax = max(err,errmax)
    end do


    if (abs(errmax)>1.0e-1_wp) error stop 'errmax too large'

    do i = 1, max(nxdata_est,nxdata)
        if (i <= nxdata) then
            write(*,*) xdata(i),",",ydata(i),",",xdata_est(i),",",ydata_est(i),",",ydata_est2(i)
        else
            write(*,*) ",,",xdata_est(i),",",ydata_est(i),",",ydata_est2(i)
        end if
    end do

    contains

        real(wp) function f1(x) !! 1d test function
        implicit none
        real(wp) :: x
        f1 = 0.5_wp * (x*exp(-x) + sin(x) )
        end function f1

    end program splpak_test
