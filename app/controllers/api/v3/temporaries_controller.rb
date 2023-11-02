# frozen_string_literal: true

module Api
  module V3
    # Endpoints that act as the backend to Typeahead fields in the React UI (making calls to the local MySQL DB)
    class TemporariesController < BaseApiController
      # POST api/v3/simulations
      def simulations
        dmp_id = tmp_params[:dmp_id] if tmp_params[:dmp_id].include?('10.')
        draft = Draft.find_by(draft_id: tmp_params[:dmp_id]) if dmp_id.nil?
        dmp_id = draft&.dmp_id if dmp_id.nil?
        flash[:alert] = 'Draft DMP has not yet been registered! You can only do this for registered DMPs' if dmp_id.nil?
        redirect_to plans_path and return if dmp_id.nil?

        dmp = DmpIdService.fetch_dmp_id(dmp_id: dmp_id.gsub(%r{https?://}, ''))
        flash[:alert] = 'DMP ID could not be found!' if dmp.nil?
        redirect_to plans_path and return if dmp.nil?

        funder_id = dmp['dmp'].fetch('project', []).first&.fetch('funding', []).first&.fetch('funder_id', {})
        funder_ror = funder_id.present? ? funder_id['identifier'] : nil
        include_grant = %w[1 true on].include?(tmp_params[:grant]&.to_s&.downcase) && funder_ror.present?

        if ExternalApis::DmphubService.simulate_works(dmp_id: dmp_id, works_count: tmp_params[:nbr_works],
                                                      funder_ror: include_grant ? funder_ror : nil)
          flash[:notice] = "#{tmp_params[:nbr_works]} related work have been 'discovered' for #{dmp_id}. /
                            Please visit the new React dashboard to see the changes."
        else
          flash[:alert] = 'Something went wrong and we were unable to "discover" related works for your DMP ID.'
        end
        redirect_to plans_path
      end

      private

      def tmp_params
        params.require(:plan).permit(:dmp_id, :nbr_works)
      end
    end
  end
end
