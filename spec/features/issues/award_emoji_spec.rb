require 'rails_helper'

describe 'Awards Emoji', feature: true do
  include WaitForAjax

  let!(:project)   { create(:project, :public) }
  let!(:user)      { create(:user) }
  let(:issue) do
    create(:issue,
           assignee: @user,
           project: project)
  end

  context 'authorized user' do
    before do
      project.team << [user, :master]
      login_as(user)
    end

    describe 'Click award emoji from issue#show' do
      let!(:note) {  create(:note_on_issue, noteable: issue, project: issue.project, note: "Hello world") }

      before do
        visit namespace_project_issue_path(project.namespace, project, issue)
      end

      it 'increments the thumbsdown emoji', js: true do
        find('[data-emoji="thumbsdown"]').click
        wait_for_ajax
        expect(thumbsdown_emoji).to have_text("1")
      end

      context 'click the thumbsup emoji' do
        it 'increments the thumbsup emoji', js: true do
          find('[data-emoji="thumbsup"]').click
          wait_for_ajax
          expect(thumbsup_emoji).to have_text("1")
        end

        it 'decrements the thumbsdown emoji', js: true do
          expect(thumbsdown_emoji).to have_text("0")
        end
      end

      context 'click the thumbsdown emoji' do
        it 'increments the thumbsdown emoji', js: true do
          find('[data-emoji="thumbsdown"]').click
          wait_for_ajax
          expect(thumbsdown_emoji).to have_text("1")
        end

        it 'decrements the thumbsup emoji', js: true do
          expect(thumbsup_emoji).to have_text("0")
        end
      end

      it 'toggles the smiley emoji on a note', js: true do
        toggle_smiley_emoji(true)

        within('.note-awards') do
          expect(find(emoji_counter)).to have_text("1")
        end

        toggle_smiley_emoji(false)

        within('.note-awards') do
          expect(page).not_to have_selector(emoji_counter)
        end
      end
    end
  end

  context 'unauthorized user', js: true do
    before do
      visit namespace_project_issue_path(project.namespace, project, issue)
    end

    it 'has disabled emoji button' do
      expect(first('.award-control')[:disabled]).to be(true)
    end
  end

  def thumbsup_emoji
    page.all(emoji_counter).first
  end

  def thumbsdown_emoji
    page.all(emoji_counter).last
  end

  def emoji_counter
    'span.js-counter'
  end

  def toggle_smiley_emoji(status)
    within('.note') do
      find('.note-emoji-button').click
    end

    unless status
      first('[data-emoji="smiley"]').click
    else
      find('[data-emoji="smiley"]').click
    end

    wait_for_ajax
  end
end
