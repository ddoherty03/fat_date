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
end
