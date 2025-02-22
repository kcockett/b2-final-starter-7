require "rails_helper"

RSpec.describe "discount index" do
  before :each do
    @merchant1 = Merchant.create!(name: "Josie's Hair Care")

    @customer_1 = Customer.create!(first_name: "Joey", last_name: "Smith")
    @customer_2 = Customer.create!(first_name: "Cecilia", last_name: "Jones")
    @customer_3 = Customer.create!(first_name: "Mariah", last_name: "Carrey")
    @customer_4 = Customer.create!(first_name: "Leigh Ann", last_name: "Bron")
    @customer_5 = Customer.create!(first_name: "Sylvester", last_name: "Nader")
    @customer_6 = Customer.create!(first_name: "Herber", last_name: "Kuhn")

    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2)
    @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)
    @invoice_5 = Invoice.create!(customer_id: @customer_4.id, status: 2)
    @invoice_6 = Invoice.create!(customer_id: @customer_5.id, status: 2)
    @invoice_7 = Invoice.create!(customer_id: @customer_6.id, status: 1)

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id)
    @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
    @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
    @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
    @ii_3 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_5 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_6 = InvoiceItem.create!(invoice_id: @invoice_5.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_7 = InvoiceItem.create!(invoice_id: @invoice_6.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)

    @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
    @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_3.id)
    @transaction3 = Transaction.create!(credit_card_number: 234092, result: 1, invoice_id: @invoice_4.id)
    @transaction4 = Transaction.create!(credit_card_number: 230429, result: 1, invoice_id: @invoice_5.id)
    @transaction5 = Transaction.create!(credit_card_number: 102938, result: 1, invoice_id: @invoice_6.id)
    @transaction6 = Transaction.create!(credit_card_number: 879799, result: 1, invoice_id: @invoice_7.id)
    @transaction7 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_2.id)

    @discount_1 = Discount.create!(merchant_id: @merchant1.id, percentage: "10", threshold: 10)
    @discount_2 = Discount.create!(merchant_id: @merchant1.id, percentage: "15", threshold: 15)
    @discount_3 = Discount.create!(merchant_id: @merchant1.id, percentage: "20", threshold: 20)
    @discounts = [@discount_1, @discount_2, @discount_3]

    visit merchant_discounts_path(@merchant1.id)
  end
  
  describe "Final Solo Project: " do
    describe "As a merchant, when I visit bulk discounts index page" do 
      it "US2.a Then I see a link to create a new discount.  When I click this link Then I am taken to a new page where I see a form to add a new bulk discount" do
        expect(page).to have_link("Create new bulk discount")
        click_link("Create new bulk discount")
        expect(current_path).to eq("/merchants/#{@merchant1.id}/discounts/new")
        expect(page).to have_css("#discount_create_form")
      end
      it "US2.b When I fill in the form with valid data Then I am redirected back to the bulk discount index And I see my new bulk discount listed" do
        visit new_merchant_discount_path(@merchant1.id)
        within "#discount_create_form" do
          fill_in "Percentage", with: "30"
          fill_in "Threshold", with: "100"
          click_button "Create Discount"
        end
        expect(current_path).to eq("/merchants/#{@merchant1.id}/discounts")
        expect(page).to have_content("30")
        expect(page).to have_content("100")
      end
      it "US2.b SAD PATH.1 When I fill in the form with invalid data (percentage) Then I am redirected back to the bulk discount new And I see a flash message that says 'Invalid information, please try again.'" do
        visit new_merchant_discount_path(@merchant1.id)
        within "#discount_create_form" do
          fill_in "Percentage", with: "text"
          fill_in "Threshold", with: "100"
          click_button "Create Discount"
        end
        expect(current_path).to eq("/merchants/#{@merchant1.id}/discounts")
        within "#flash_message" do
          expect(page).to have_content("Invalid information, please try again.")
        end
      end

      it "US2.b SAD PATH.2 When I fill in the form with invalid data (threshold) Then I am redirected back to the bulk discount new And I see a flash message that says 'Invalid information, please try again.'" do
        visit new_merchant_discount_path(@merchant1.id)
        within "#discount_create_form" do
          fill_in "Percentage", with: "30"
          fill_in "Threshold", with: "-100"
          click_button "Create Discount"
        end
        expect(current_path).to eq("/merchants/#{@merchant1.id}/discounts")
        within "#flash_message" do
          expect(page).to have_content("Invalid information, please try again.")
        end
      end

      it "US3.a Then next to each bulk discount I see a link to delete it" do
        within "#discount_#{@discount_1.id}" do
          expect(page).to have_button("Delete Discount")
        end
      end
      it "US3.b When I click this link Then I am redirected back to the bulk discounts index page And I no longer see the discount listed" do
        within "#discount_#{@discount_1.id}" do
          click_button("Delete Discount")
        end

        expect(current_path).to eq(merchant_discounts_path(@merchant1.id))
        expect(page).to have_content("Discount was successfully deleted.")
        expect(page).to_not have_css("#discount_#{@discount_1.id}")
        expect(page).to have_css("#discount_#{@discount_2.id}")
      end
      it "US9 I see a section with a header of 'Upcoming Holidays' In this section the name and date of the next 3 upcoming US holidays are listed." do
        expect(page).to have_content("Upcoming Holidays")
        within "#upcoming_holidays" do
          expect(page).to have_content("Labor Day")
          expect(page).to have_content("Columbus Day")
          expect(page).to have_content("Veterans Day")
        end
      end
    end
  end
end