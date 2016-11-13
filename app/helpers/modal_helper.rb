# creates modal dialog
module ModalHelper
  def modal(&block)

'<div class="modal fade new-call" tabindex="-1" role="dialog" id="pledge-modal">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h4 class="js-title-step"></h4>
      </div>

      <div class="modal-body">'

  + capture(&block) + 

      '</div>

      <div class="modal-footer">
        <button type="button" class="btn btn-default js-btn-step pull-left" data-orientation="cancel" data-dismiss="modal"></button>
        <button type="button" class="btn btn-warning js-btn-step" data-orientation="previous"></button>
        <button type="button" class="btn btn-success js-btn-step" data-orientation="next"></button>
      </div>
    </div>
  </div>
</div>'


  end
end  
