class OrdersController < ApplicationController
  
  include CurrentCart
  before_action :set_cart, only: [:new, :create]
  before_action :set_order, only: [:show, :edit, :destroy]
  
	def index
	  @orders = Order.all 
	end
	
	def new
		if @cart.product_items.empty?
			redirect_to shop_url, notice: 'Your Cart is Empty'
			return
		end
		@order = Order.new
		@client_token = Braintree::ClientToken.generate
		
		#@client_token = @gateway.client_token.generate
	end
	
	def create
		@order = Order.new(order_params)
		@order.add_product_items_from_cart(@cart)
		if @order.save
			charge 
			if @result.success?
				Cart.destroy(session[:cart_id]) #no longer need cart with these products if order placed
				session[:cart_id] = nil
				OrderNotifier.received(@order).deliver 
				redirect_to root_url, notice: 'Thank You for Your Order!'
			else 
				flash[:error] = 'There was an error with payment'
				redirect_to root_url, alert: @result.message
				@order.destroy
			end
		else
		  @client_token = Braintree::ClientToken.generate
		  #@client_token = @gateway.client_token.generate
		  render :new
		end
	end
	
	def show
	end
	
	def destroy
		@order.destroy
		redirect_to root_url, notice: 'Order deleted'
	end
	
	private
	
	def set_order
		@order = Order.find(params[:id])
	end
	
	def order_params
		params.require(:order).permit(:name, :email, :address, :city, :state, :country)
	end
	
	def charge
		#test braintree transaction
		@result = Braintree::Transaction.sale(
		  amount: @cart.total_price,
		  payment_method_nonce: params[:payment_method_nonce] )
	end
  	
end