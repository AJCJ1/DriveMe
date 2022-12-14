class BookingsController < ApplicationController
  def index
    @booking = policy_scope(Booking)
  end

  def show
    @booking = Booking.find(params[:id])
  end

  def new
    @car = Car.find(params[:car_id])
    @booking = Booking.new
    authorize @booking
  end

  def create
    @car = Car.find(params[:car_id])
    @reservations = @car.bookings
    available = []
    dates = params[:booking]
    start_date = dates["start_date"].to_date
    end_date = dates["end_date"].to_date
    @reservations.each do |reservation|
      if (reservation.start_date..reservation.end_date).overlaps?(start_date..end_date)
        available << 1
        else nil
      end
    end
    if available.count > 0
      @booking = Booking.new
      authorize @booking
      redirect_back(fallback_location: 'something')
      flash.alert = "Dates not available"
    elsif end_date < start_date
      @booking = Booking.new
      authorize @booking
      redirect_back(fallback_location: 'something')
      flash.alert = "End date before start date"
    elsif start_date < Date.today
      @booking = Booking.new
      authorize @booking
      redirect_back(fallback_location: 'something')
      flash.alert = "You can't book a car in the past"
    else
      @car = Car.find(params[:car_id])
      @booking = Booking.new(booking_params)
      authorize @booking
      @booking.car = @car
      @booking.user = current_user
      if @booking.save
        redirect_to car_path(@car.id)
        flash.notice = "You have booked this car from the #{@booking.start_date.strftime("%a %d %B %Y")} to the #{@booking.end_date.strftime("%a %d %B %Y")}"
      else
        flash.alert = "Booking not validated"
      end
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    @car = @booking.car
    authorize @booking
    @booking.destroy
    redirect_back(fallback_location: 'something')
    flash.notice = "You have cancelled your booking"
  end

  private

  def booking_params
    params.require(:booking).permit(:car_id, :user_id, :start_date, :end_date)
  end
end
