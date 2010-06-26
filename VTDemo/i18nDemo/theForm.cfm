<!---
	
	Copyright 2009, Bob Silverberg
	
	Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in 
	compliance with the License.  You may obtain a copy of the License at 
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software distributed under the License is 
	distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
	implied.  See the License for the specific language governing permissions and limitations under the 
	License.
	
--->
<cfparam name="SuccessMessage" default="" />

<cfif Form.Context EQ "Profile">
	<cfset PageHeading = "Editing an existing User" />
	<cfset Form.UserId = 1 />
<cfelse>
	<cfset PageHeading = "Registering a new User" />
</cfif>

<!--- We need a User record --->
<cfset UserTO = application.Reactor.createRecord("User").load(userId=Form.UserId) />

<!--- Default the validation failures to an empty struct --->
<cfset UniFormErrors = {} />
<!--- Are we processing the form? --->
<cfif StructKeyExists(Form,"Processing")>
	<!--- Populate the object from the form scope --->
	<cfloop collection="#form#" item="fld">
		<cfif StructKeyExists(UserTO,"set" & fld)>
			<cfinvoke component="#UserTO#" method="set#fld#">
				<cfinvokeargument name="#fld#" value="#form[fld]#" />
			</cfinvoke>
		</cfif>
	</cfloop>
	<!--- Validate the object using ValidateThis --->
	<cfset Result = application.ValidateThis.validate(objectType="User",theObject=UserTO,Context=Form.Context) />
	<cfset UniFormErrors = Result.getFailuresForUniForm(locale=Form.Locale) />
	<!--- If validations passed, save the record --->
	<cfif Result.getIsSuccess()>
		<cfset UserTO.save() />
		<cfset SuccessMessage = "The User has been saved!" />
	<cfelse>
		<cfset SuccessMessage = "" />
	</cfif>
</cfif>
<cfset UserGroupId = UserTO.getUserGroup().getUserGroupId() />

<!--- Get the list of required fields to use to dynamically add asterisks in front of each field --->
<cfset RequiredFields = application.ValidateThis.getRequiredFields(objectType="User",Context=Form.Context) />

<!--- If we want JS validations turned on, get the Script blocks to initialize the libraries and for the validations themselves, and include them in the <head> --->
<cfif NOT Form.NoJS>
	<cfset ValInit = application.ValidateThis.getInitializationScript(locale=Form.Locale) />
	<cfhtmlhead text="#ValInit#" />
	<!--- Some formatting rules specific to this form --->
	<cfsavecontent variable="headJS">
		<script type="text/javascript">
		jQuery(document).ready(function($) {
			jQuery.validator.setDefaults({ 
				errorClass: 'errorField', 
				errorElement: 'p', 
				errorPlacement: function(error, element) { 
					error.prependTo( element.parents('div.ctrlHolder') ) 
				}, 
				highlight: function() {}
			});
		});
		</script>
	</cfsavecontent>	
	<cfhtmlhead text="#headJS#" />
	<cfset ValidationScript = application.ValidateThis.getValidationScript(objectType="User",Context=Form.Context,locale=Form.Locale) />
	<cfhtmlhead text="#ValidationScript#" />
</cfif>

<cfoutput>
<h1>ValidateThis i18n Demo</h1>
<h3>#PageHeading# (JavaScript Validations are <cfif Form.NoJS>OFF<cfelse>ON</cfif>, Language is <cfif Form.Locale EQ "en_US">English<cfelse>French</cfif>)</h3>
<cfif Len(SuccessMessage)><h3>#SuccessMessage#</h3></cfif>
<div class="formContainer">
<form action="index.cfm" id="frmMain" method="post" name="frmMain" class="uniForm">
	<input type="hidden" name="Context" id="Context" value="#Form.Context#" />
	<input type="hidden" name="NoJS" id="NoJS" value="#Form.NoJS#" />
	<input type="hidden" name="Locale" id="Locale" value="#Form.Locale#" />
	<input type="hidden" name="Processing" id="Processing" value="true" />
	<fieldset class="inlineLabels">	
		<legend>Access Information</legend>
		<div class="ctrlHolder">
			#isErrorMsg("UserName")#
			<label for="UserName">#isRequired("UserName")#Email Address</label>
			<input name="UserName" id="UserName" value="#UserTO.getUserName()#" size="35" maxlength="50" type="text" class="textInput" />
			<p class="formHint">Validations: Required, Must be a valid Email Address.</p>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("Nickname")#
			<label for="Nickname">#isRequired("Nickname")#Nickname</label>
			<input name="Nickname" id="Nickname" value="#UserTO.getNickname()#" size="35" maxlength="50" type="text" class="textInput" />
			<p class="formHint">Validations: Custom - must be unique. Try 'BobRules'.</p>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("UserPass")#
			<label for="UserPass">#isRequired("UserPass")#Password</label>
			<input name="UserPass" id="UserPass" value="" size="35" maxlength="50" type="password" class="textInput" />
			<p class="formHint">Validations: Required, Must be between 5 and 10 characters, Must be the same as the Verify password field.</p>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("VerifyPassword")#
			<label for="VerifyPassword">#isRequired("VerifyPassword")#Verify Password</label>
			<input name="VerifyPassword" id="VerifyPassword" value="" size="35" maxlength="50" type="password" class="textInput" />
			<p class="formHint">Validations: Required.</p>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("UserGroupId")#
			<label for="UserGroupId">#isRequired("UserGroupId")#User Group</label>
			<select name="UserGroupId" id="UserGroupId" class="selectInput">
				<option value=""<cfif UserGroupId EQ ""> selected="selected"</cfif>>Select one...</option>
				<option value="1"<cfif UserGroupId EQ 1> selected="selected"</cfif>>Member</option>
				<option value="2"<cfif UserGroupId EQ 2> selected="selected"</cfif>>Administrator</option>
			</select>
			<p class="formHint">Validations: Required.</p>
		</div>
	</fieldset>

	<fieldset class="inlineLabels">
		<legend>User Information</legend>
		<div class="ctrlHolder">
			#isErrorMsg("Salutation")#
			<label for="Salutation">#isRequired("Salutation")#Salutation</label>
			<input name="Salutation" id="Salutation" value="#UserTO.getSalutation()#" size="35" maxlength="50" type="text" class="textInput" />
			<p class="formHint">Validations: A regex ensures that only Dr, Prof, Mr, Mrs, Ms, or Miss (with or without a period) are allowed.</p>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("FirstName")#
			<label for="FirstName">#isRequired("FirstName")#First Name</label>
			<input name="FirstName" id="FirstName" value="#UserTO.getFirstName()#" size="35" maxlength="50" type="text" class="textInput" />
			<p class="formHint">Validations: Required on Update.</p>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("LastName")#
			<label for="LastName">#isRequired("LastName")#Last Name</label>
			<input name="LastName" id="LastName" value="#UserTO.getLastName()#" size="35" maxlength="50" type="text" class="textInput" />
			<p class="formHint">Validations: Required on Update OR if a First Name has been specified during Register.</p>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("LikeCheese")#
			<p class="label">#isRequired("LikeCheese")#Do you like Cheese?</p>
			<label for="LikeCheese-1" class="inlineLabel"><input name="LikeCheese" id="LikeCheese-1" value="1" type="radio" class=""<cfif UserTO.getLikeCheese() EQ 1> checked="checked"</cfif> />&nbsp;Yes</label>
			<label for="LikeCheese-2" class="inlineLabel"><input name="LikeCheese" id="LikeCheese-2" value="0" type="radio" class=""<cfif UserTO.getLikeCheese() EQ 0> checked="checked"</cfif> />&nbsp;No</label>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("LikeChocolate")#
			<p class="label">#isRequired("LikeChocolate")#Do you like Chocolate?</p>
			<label for="LikeChocolate-1" class="inlineLabel"><input name="LikeChocolate" id="LikeChocolate-1" value="1" type="radio" class=""<cfif UserTO.getLikeChocolate() EQ 1> checked="checked"</cfif> />&nbsp;Yes</label>
			<label for="LikeChocolate-2" class="inlineLabel"><input name="LikeChocolate" id="LikeChocolate-2" value="0" type="radio" class=""<cfif UserTO.getLikeChocolate() EQ 0> checked="checked"</cfif> />&nbsp;No</label>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("LikeOther")#
			<label for="LikeOther">#isRequired("LikeOther")#What do you like?</label>
			<input name="LikeOther" id="LikeOther" value="#UserTO.getLikeOther()#" size="35" maxlength="50" type="text" class="textInput" />
			<p class="formHint">Validations: Required if neither Do you like Cheese? nor Do you like Chocolate? are true.</p>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("HowMuch")#
			<label for="HowMuch">#isRequired("HowMuch")#How much money would you like?</label>
			<input name="HowMuch" id="HowMuch" value="#UserTO.getHowMuch()#" size="35" maxlength="50" type="text" class="textInput" />
			<p class="formHint">Validations: Numeric - notice that an invalid value is redisplayed upon server side validation failure.</p>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("AllowCommunication")#
			<p class="label">#isRequired("AllowCommunication")#Allow Communication</p>
			<label for="AllowCommunication-1" class="inlineLabel"><input name="AllowCommunication" id="AllowCommunication-1" value="1" type="radio" class=""<cfif UserTO.getAllowCommunication() EQ 1> checked="checked"</cfif> />&nbsp;Yes</label>
			<label for="AllowCommunication-2" class="inlineLabel"><input name="AllowCommunication" id="AllowCommunication-2" value="0" type="radio" class=""<cfif UserTO.getAllowCommunication() EQ 0> checked="checked"</cfif> />&nbsp;No</label>
		</div>
		<div class="ctrlHolder">
			#isErrorMsg("CommunicationMethod")#
			<label for="CommunicationMethod">#isRequired("CommunicationMethod")#Communication Method</label>
			<select name="CommunicationMethod" id="CommunicationMethod" class="selectInput">
				<option value=""<cfif UserTO.getCommunicationMethod() EQ ""> selected="selected"</cfif>>Select one...</option>
				<option value="Email"<cfif UserTO.getCommunicationMethod() EQ "Email"> selected="selected"</cfif>>Email</option>
				<option value="Phone"<cfif UserTO.getCommunicationMethod() EQ "Phone"> selected="selected"</cfif>>Phone</option>
				<option value="Pony Express"<cfif UserTO.getCommunicationMethod() EQ "Pony Express"> selected="selected"</cfif>>Pony Express</option>
			</select>
			<p class="formHint">Validations: Required if Allow Communication? is true.</p>
		</div>
	</fieldset>

	<div class="buttonHolder">
		<button type="submit" class="submitButton"> Submit </button>
	</div>
</form> 

</div>
</cfoutput>

<!--- These UDFs are only required to make the demo look pretty --->
<cffunction name="isRequired" returntype="any" output="false" hint="I am used to display an asterisk for required fields.  I only exist for this demo page - there are much better ways of doing this!">
	<cfargument name="fieldName" type="any" required="yes" />
	<cfif StructKeyExists(RequiredFields,arguments.fieldName)>
		<cfreturn "<em>*</em> " />
	<cfelse>
		<cfreturn "" />
	</cfif>
</cffunction>

<cffunction name="isErrorMsg" returntype="any" output="false" hint="I am used to display error messages for a field.  I only exist for this demo page - there are much better ways of doing this!">
	<cfargument name="fieldName" type="any" required="yes" />
	<cfif StructKeyExists(UniFormErrors,arguments.fieldName)>
		<cfreturn '<p id="error-UserName" class="errorField bold">#UniFormErrors[arguments.fieldName]#</p>' />
	<cfelse>
		<cfreturn "" />
	</cfif>
</cffunction>
