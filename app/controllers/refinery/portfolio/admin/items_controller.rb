module Refinery
  module Portfolio
    module Admin
      class ItemsController < ::Refinery::AdminController
        include Refinery::Portfolio

        crudify :'refinery/portfolio/item',
                :order => 'position ASC',
                :xhr_paging => true

        before_filter :find_gallery, :only => [:index, :new, :new_multiple, :create_multiple, :multiply_description]

        def index
          if params[:orphaned]
            @items = Item.orphaned.order('position ASC')
          elsif params[:gallery_id]
            @items = @gallery.items.order('position ASC')
          else
            redirect_to refinery.portfolio_admin_galleries_path and return
          end

          @items = @items.page(params[:page])
        end

        def new
          @item = Item.new(:gallery_id => find_gallery.try(:id))
        end

        def new_multiple
          search_all_images if searching?
          find_all_images if @images.nil?

          if request.xhr?
            render :text => render_to_string(:partial => 'refinery/portfolio/admin/items/images/records', :layout => false).html_safe,
                   :layout => 'refinery/flash' and return false
          end
        end

        def create_multiple
          images = Refinery::Image.where(id: params[:image_ids])
          if images.present?
            if @gallery.items.create(images.map{|image| { title: '', image_id: image.id }})
              redirect_to refinery.portfolio_admin_gallery_items_path(@gallery), notice: t('success', scope: 'refinery.portfolio.admin.items.create_multiple')
            else
              redirect_to refinery.new_multiple_portfolio_admin_gallery_items_path(@gallery), alert: t('failure', scope: 'refinery.portfolio.admin.items.create_multiple')
            end
          else
            redirect_to refinery.new_multiple_portfolio_admin_gallery_items_path(@gallery), alert: t('failure', scope: 'refinery.portfolio.admin.items.create_multiple')
          end
        end

        def multiply_description
          description = @gallery.items.where('caption IS NOT NULL').first.try(:caption)
          if description.present?
            @gallery.items.each do |item|
              if item.caption.blank?
                item.caption = description
                item.save
              end
            end
          end
          redirect_to refinery.portfolio_admin_gallery_items_path(@gallery), notice: t('success', scope: 'refinery.portfolio.admin.items.multiply_description')
        end

        private
          def find_gallery
            @gallery = Gallery.find(params[:gallery_id]) if params[:gallery_id]
          end
          def find_all_images(conditions = {})
            @images = Refinery::Image.order('created_at DESC')
          end
          def search_all_images
            # First find normal results.
            find_all_images

            # Now get weighted results by running the query against the results already found.
            @images = @images.with_query(params[:search])
          end
      end
    end
  end
end
