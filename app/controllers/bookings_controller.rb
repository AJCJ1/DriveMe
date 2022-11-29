class BookingsController < ApplicationController
  def index
    @booking = policy_scope(Booking)
  end

  def new
    @car = Car.find(params[:car_id])
    @booking = Booking.new
    authorize @booking
  end

  def create
    @reservations = Booking.all
    available = []
    dates = params[:booking]
    #start_date = Date.new dates["start_date(1i)"].to_i, dates["start_date(2i)"].to_i, dates["start_date(3i)"].to_i
    #end_date = Date.new dates["end_date(1i)"].to_i, dates["end_date(2i)"].to_i, dates["end_date(3i)"].to_i
    start_date = dates["start_date"].to_date
    end_date = dates["end_date"].to_date
    @reservations.each do |reservation|
      if reservation.start_date < start_date && reservation.end_date > start_date
        available << 1
      else nil
      end
    end
    @reservations.each do |reservation|
      if reservation.end_date > end_date && reservation.start_date < end_date
        available << 2
      else nil
      end
    end
    if available.count > 0
      @car = Car.find(params[:car_id])
      @booking = Booking.new
      authorize @booking
      flash.alert = "Dates not available"
      @booking.start_date = @booking.start_date
      @booking.end_date = @booking.end_date
      render :new, status: :unprocessable_entity
    else
      @car = Car.find(params[:car_id])
      @booking = Booking.new(booking_params)
      authorize @booking
      @booking.car = @car
      @booking.user = current_user
      if @booking.save
        redirect_to car_path(@car.id)
      else
        @booking.start_date = @booking.start_date
        @booking.end_date = @booking.end_date
        render :new
      end
    end
  end

##  def edit
##    @booking = Booking.find(params[:id])
##  end
##
##  def update
##    @booking = Booking.find(params[:id])
##    if @booking.update(booking_params)
##      redirect_to car_path(@car.id)
##    else
##      render :edit
##    end
##  end

  def destroy
    @booking = Booking.find(params[:id])
    authorize @booking
    @booking.destroy
    redirect_to cars_path
  end

  private

  def booking_params
    params.require(:booking).permit(:car_id, :user_id, :start_date, :end_date)
  end
end
