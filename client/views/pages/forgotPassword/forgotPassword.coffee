multipleUsernames = new Tracker.Dependency
usernameList = []

Template.forgotPassword.helpers

	multipleUsernames: ->
		multipleUsernames.depend()
		usernameList

	isChecked: (index) -> if index == 0 then 'checked'

Template.forgotPassword.events

	'change #email': (e) ->
		usernameList = []
		multipleUsernames.changed()

	'submit form': (e) ->
		e.preventDefault()

		email = $('#email').val()

		if email != ''
			submit = $('#submit').ladda()
			submit.ladda 'start'

			username = $('[name="username"]:checked').val()
			obj = email: email

			if username? && username != ''
				obj['username'] = username

			Meteor.call 'sendResetPassword', obj, (err, res) ->
				if err
					if err.error == 404
						swal TAPi18n.__('forgotPassword.noUserForThisEmail'), '', 'error'
						submit.ladda 'stop'
					else if err.error == 420
						swal TAPi18n.__('forgotPassword.multipleAccountsForThisEmail'), '', 'warning'

						Meteor.call 'getUsernamesForEmail', email, (err, res) ->
							if err
								handleError(err)
								submit.ladda 'stop'
							else
								usernameList = res
								multipleUsernames.changed()
								submit.ladda 'stop'
					else
						handleError(err)
						submit.ladda 'stop'
				else
					swal TAPi18n.__('forgotPassword.mailSent'), '', 'success'
					submit.ladda 'stop'
		else
			swal TAPi18n.__('forgotPassword.emailMissing'), '', 'error'
