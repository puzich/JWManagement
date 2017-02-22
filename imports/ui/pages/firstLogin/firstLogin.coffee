import { Dialogs } from '/imports/util/dialogs.coffee'

import './firstLogin.tpl.jade'

Template.firstLogin.onCreated ->

	token = FlowRouter.getQueryParam('token')

	if token? && token != ''
		@subscribe 'userByToken', token

Template.firstLogin.helpers

	user: ->
		token = FlowRouter.getQueryParam('token')
		Meteor.users.findOne 'services.password.reset.token': token

	loggingIn: -> Meteor.loggingIn() || Meteor.userId()

Template.firstLogin.events

	'submit form': (event) ->
		event.preventDefault()

		submit = $('#submit').ladda()
		submit.ladda('start')

		username = $('#username').val()
		password1 = $('#password1').val()
		password2 = $('#password2').val()
		agreeTerms = $('#agreeTerms').prop('checked')
		token = FlowRouter.getQueryParam('token')

		try
			if token
				if agreeTerms
					if username
						if Meteor.users.helpers.areValidPasswords password1, password2
							Meteor.users.methods.getters.usernameAvailable.call
								username: username
							, Dialogs.callback
								onError: -> submit.ladda('stop')
								onSuccess: ->
									Meteor.users.methods.init.call
										token: token
										username: username
										password: password1
									, Dialogs.callback
										onError: -> submit.ladda('stop')
										onSuccess: ->
											Meteor.loginWithPassword username, password1, ->
												FlowRouter.go 'home'
					else
						throw new Meteor.Error 'usernameMissing', 'error'
				else
					throw new Meteor.Error 'agreeTermsMissing', 'error'
			else
				throw new Meteor.Error 'tokenMissing', 'error'
		catch e
			submit.ladda('stop')
			Dialogs.feedback e
