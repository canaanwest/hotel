require_relative './spec_helper'
require_relative '../lib/reservations'

describe "#RESERVATIONS" do
  before do
    @room = [Room.new(1, 200)]
    @new_reservation = Reservation.new("January 16, 2018", "January 18, 2018", @room)

    @new_reservation1 = Reservation.new("15-05-2018", "22-05-2018", @room)
  end

  describe "single-room reservations" do

    it "An Administrator can initialize an instance of Reservation for a room" do
      @new_reservation.must_be_instance_of Reservation
      @new_reservation.nights.must_be_instance_of Nights
      @new_reservation.nights.check_in.must_be_instance_of Date
      @new_reservation.nights.check_out.must_be_instance_of Date
      @new_reservation.room_numbers.first.must_equal 1
      @new_reservation.must_respond_to :reservation_id

    end

    it "Raises an Argument error for invalid input" do
      proc {Reservation.new("yesterday", "tomorrow", @room)}.must_raise ArgumentError
      proc {Reservation.new("tomorrow", "today", @room)}.must_raise ArgumentError
      proc {Reservation.new("January 4, 2018", "hey", @room)}.must_raise ArgumentError
      proc{Reservation.new("today", "tomorrow", @room)}.must_raise ArgumentError
      proc{Reservation.new("01-18-2018", "01-18-2018", @room)}.must_raise ArgumentError
    end

    it "can calculate the cost for a reservation" do
      @new_reservation.bill.must_equal 400
      @new_reservation1.bill.must_equal 1400
    end

  end

  describe "#BLOCKS" do
    before do
      @my_hotel = Hotel.new
      @my_hotel.make_block("January 10, 2018", "January 15, 2018", [@my_hotel.rooms.first, @my_hotel.rooms.last], 0.8)
    end

    it 'Can create a new instance of block store a block' do
      @my_hotel.blocks.first.must_be_instance_of Block;
    end

    it 'Can find a block by ID' do
      @my_hotel.find_block(@my_hotel.blocks.first.id).must_be_instance_of Block;
    end

    it 'Can reserve a room from a block' do
      @my_hotel.reserve_from_block(@my_hotel.blocks.first.id, [1, 20]).must_be_instance_of Reservation
      @my_hotel.reservations.length.must_equal 1
    end

    it 'Cannot make a block if a room in the block is unavailable' do
      proc {@my_hotel.make_block("January 13, 2018", "January 18, 2018", [@my_hotel.rooms.first, @my_hotel.rooms[1]], 0.8)}.must_raise ArgumentError

    end

    it 'Cannot make a reservation for a room set aside in a block for that date range' do
      proc {@my_hotel.make_reservation("January 10, 2018", "January 11, 2018", [@my_hotel.rooms.first])}.must_raise ArgumentError

    end

    it "Can make a reservation containing more than one room" do
      @block_reserve = {check_in: "January 20, 2018", check_out: "January 25, 2018", rooms: [Room.new(25, 200), Room.new(26, 150), Room.new(27, 250)]}

      @my_block_reserve = Reservation.new(@block_reserve[:check_in], @block_reserve[:check_out], @block_reserve[:rooms])

      @my_block_reserve.must_be_instance_of Reservation
    end

    it "Will accept a discount argument" do
      @block_reserve = {check_in: "January 20, 2018", check_out: "January 25, 2018", rooms: [Room.new(25, 200), Room.new(26, 150), Room.new(27, 250)]}

      @my_block_reserve = Reservation.new(@block_reserve[:check_in], @block_reserve[:check_out], @block_reserve[:rooms], 0.8)

      @my_block_reserve.bill.must_equal 3000*0.8
    end

    it "Will not reserve a block with more than 5 rooms." do
      @block2 = {check_in: "January 20, 2018", check_out: "January 25, 2018", rooms: [Room.new(25, 200), Room.new(26, 150), Room.new(27, 250), Room.new(28, 100), Room.new(29, 300), Room.new(30, 140)]}

      proc{Reservation.new(@block2[:check_in], @block2[:check_out], @block2[:rooms])}.must_raise ArgumentError
    end

    it "will not double-book a room in a block reservation" do
      block_reserve = {check_in: "January 20, 2018", check_out: "January 25, 2018", rooms: [Room.new(25, 200), Room.new(25, 200), Room.new(27, 250)]}


      proc {Reservation.new(block_reserve[:check_in], block_reserve[:check_out], block_reserve[:rooms], 0.8)}.must_raise ArgumentError
    end
  end
end
