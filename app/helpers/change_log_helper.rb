module ChangeLogHelper

  def updated_by_user(revision)
    if revision.tracked_changes[:updated_by_id].present?
      user_guid_to_email(revision.tracked_changes[:updated_by_id][:to])
    else
      "N/A"
    end
  end

  def user_guid_to_email(guid)
    if User.where(id: guid).first.present?
      User.where(id: guid).first.email
    else
      "System"
    end
  end
end
