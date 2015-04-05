class ChangePortfolioItemPositionDefault < ActiveRecord::Migration
  def change
    change_column_null :refinery_portfolio_items, :position, false, default: 0
  end
end

