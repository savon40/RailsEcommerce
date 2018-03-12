class Product < ActiveRecord::Base
	
	before_destroy :ensure_not_product_item
	has_many :product_items
	
	validates :title, :description, presence: true
	validates :price, numericality: {greater_than_or_equal_to: 0.01}
	
	has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" }
    validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

	#method to prevent destroy product if it is in a cart
	def ensure_not_product_item
		if product_items.empty?
			return true
		else
			errors.add(:base, 'This item is in a shopping cart')
			return false
		end
			
			
	end

end
