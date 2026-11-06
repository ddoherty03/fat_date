# coding: utf-8
# frozen_string_literal: true

RSpec.describe DateTime do
  before do
    # Pretend it is this date. Not at beg or end of year, quarter,
    # month, or week.  It is a Wednesday
    allow(DateTime).to receive_messages(now: DateTime.parse('2021-07-18T09:14:33.66'))
  end

  describe 'print as string' do
    it 'prints itself in iso form' do
      expect(DateTime.now.iso).to match(/\A2021-07-18T09:14:33.660/)
    end
  end

  [:ensure, :ensure_datetime].each do |method|
    describe ".#{method}" do
      it 'converts a Date to DateTime at midnight' do
        result = DateTime.public_send(method, Date.new(2018, 11, 12))
        expect(result).to be_an_instance_of(DateTime)
        expect(result).to eq DateTime.new(2018, 11, 12)
      end

      it 'converts a date-only string to DateTime at midnight' do
        result = DateTime.public_send(method, '2018-11-12')
        expect(result).to be_an_instance_of(DateTime)
        expect(result).to eq DateTime.new(2018, 11, 12)
      end

      it 'preserves time, fractional seconds, and offset in strings' do
        result = DateTime.public_send(method, '2018-11-12T13:14:15.125-06:00')
        expect(result).to be_an_instance_of(DateTime)
        expect(result).to eq DateTime.new(2018, 11, 12, 13, 14, Rational(121, 8), '-06:00')
        expect(result.offset).to eq Rational(-1, 4)
      end

      it 'preserves an existing DateTime' do
        datetime = DateTime.new(2018, 11, 12, 13, 14, 15, '-06:00')
        expect(DateTime.public_send(method, datetime)).to equal datetime
      end

      it 'converts Time while preserving its time and offset' do
        time = Time.new(2018, 11, 12, 13, 14, 15, '-06:00')
        result = DateTime.public_send(method, time)
        expect(result).to be_an_instance_of(DateTime)
        expect(result).to eq time.to_datetime
        expect(result.offset).to eq Rational(-1, 4)
      end

      it 'converts objects that provide a Date' do
        object = double(to_date: Date.new(2018, 11, 12))
        result = DateTime.public_send(method, object)
        expect(result).to be_an_instance_of(DateTime)
        expect(result).to eq DateTime.new(2018, 11, 12)
      end

      it 'rejects invalid strings' do
        expect { DateTime.public_send(method, '2012-mm-tu') }.to raise_error(ArgumentError, /cannot convert string/)
      end

      it 'rejects unsupported objects' do
        expect { DateTime.public_send(method, []) }.to raise_error(ArgumentError, /cannot convert class/)
      end
    end
  end
end
