/*
 * (c) Copyright 1999-2012 PaperCut Software International Pty Ltd.
 * $Id: ServerCommandProxy.cs 23395 2013-08-13 03:02:28Z geoff $
 */
using CookComputing.XmlRpc;

/// <summary>
///  This is an XML-RPC interface to expose the server's APIs.  Used by the standard ServerCommandProxy class below.
/// </summary>
#pragma warning disable 1591
public interface IServerCommandProxy : IXmlRpcProxy {

	[XmlRpcMethod("api.isUserExists")]
	bool UserExists(string authToken, string username);

	[XmlRpcMethod("api.getUserAccountBalance")]
	double GetUserAccountBalance(string authToken, string username, string accountName);

	[XmlRpcMethod("api.getUserProperty")]
	string GetUserProperty(string authToken, string username, string propertyName);

	[XmlRpcMethod("api.getUserProperties")]
	string[] GetUserProperties(string authToken, string username, string[] propertyNames);

	[XmlRpcMethod("api.setUserProperty")]
	void SetUserProperty(string authToken, string username, string propertyName, string propertyValue);
	
	[XmlRpcMethod("api.setUserProperties")]
	void SetUserProperties(string authToken, string username, string[][] propertyNamesAndValues);
	
	[XmlRpcMethod("api.adjustUserAccountBalance")]
	void AdjustUserAccountBalance(string authToken, string username, double adjustment, string comment,
		string accountName);

	[XmlRpcMethod("api.adjustUserAccountBalanceByCardNumber")]
	bool AdjustUserAccountBalanceByCardNumber(string authToken, string cardNumber, double adjustment, string comment);

	[XmlRpcMethod("api.adjustUserAccountBalanceByCardNumber")]
	bool AdjustUserAccountBalanceByCardNumber(string authToken, string cardNumber, double adjustment, string comment, string accountName);
	
	[XmlRpcMethod("api.adjustUserAccountBalanceIfAvailable")]
	bool AdjustUserAccountBalanceIfAvailable(string authToken, string username, double adjustment, string comment, string accountName);
	
	[XmlRpcMethod("api.adjustUserAccountBalanceIfAvailableLeaveRemaining")]
	bool AdjustUserAccountBalanceIfAvailableLeaveRemaining(string authToken, string username, double adjustment,
														   double leaveRemaining, string comment, string accountName);

	[XmlRpcMethod("api.adjustUserAccountBalanceByGroup")]
	void AdjustUserAccountBalanceByGroup(string authToken, string group, double adjustment, string comment, string accountName);

	[XmlRpcMethod("api.adjustUserAccountBalanceByGroupUpTo")]
	void AdjustUserAccountBalanceByGroup(string authToken, string group, double adjustment, double limit,
										 string comment, string accountName);

	[XmlRpcMethod("api.setUserAccountBalance")]
	void SetUserAccountBalance(string authToken, string username, double balance, string comment, string accountName);

	[XmlRpcMethod("api.setUserAccountBalanceByGroup")]
	void SetUserAccountBalanceByGroup(string authToken, string group, double balance, string comment, string accountName);

	[XmlRpcMethod("api.resetUserCounts")]
	void ResetUserCounts(string authToken, string username, string resetBy);
	
	[XmlRpcMethod("api.reapplyInitialUserSettings")]
	void ReapplyInitialUserSettings(string authToken, string username);
	
	[XmlRpcMethod("api.disablePrintingForUser")]
	void DisablePrintingForUser(string authToken, string username, int disableMins);

	[XmlRpcMethod("api.addNewUser")]
	void AddNewUser(string authToken, string username);

	[XmlRpcMethod("api.renameUserAccount")]
	void RenameUserAccount(string authToken, string currentUserName, string newUserName);

	[XmlRpcMethod("api.deleteExistingUser")]
	void DeleteExistingUser(string authToken, string username);

	[XmlRpcMethod("api.addNewInternalUser")]
	void AddNewInternalUser(string authToken, string username, string password, string fullName, string email, string cardId, string pin);

	[XmlRpcMethod("api.lookUpUserNameByIDNo")]
	string LookUpUserNameByIDNo(string authToken, string idNo);

	[XmlRpcMethod("api.lookUpUserNameByCardNo")]
	string LookUpUserNameByCardNo(string authToken, string cardNo);

	[XmlRpcMethod("api.addUserToGroup")]
	void AddUserToGroup(string authToken, string username, string groupName);

	[XmlRpcMethod("api.removeUserFromGroup")]
	void RemoveUserFromGroup(string authToken, string username, string groupName);

	[XmlRpcMethod("api.addAdminAccessUser")]
	void AddAdminAccessUser(string authToken, string username);

	[XmlRpcMethod("api.removeAdminAccessUser")]
	void RemoveAdminAccessUser(string authToken, string username);

	[XmlRpcMethod("api.addAdminAccessGroup")]
	void AddAdminAccessGroup(string authToken, string groupName);

	[XmlRpcMethod("api.removeAdminAccessGroup")]
	void RemoveAdminAccessGroup(string authToken, string groupName);

	[XmlRpcMethod("api.setUserAccountSelectionAutoSelectSharedAccount")]
	void SetUserAccountSelectionAutoSelectSharedAccount(string authToken, string username, string accountName, 
															bool chargeToPersonal);

	[XmlRpcMethod("api.setUserAccountSelectionAutoChargePersonal")]
	void SetUserAccountSelectionAutoChargePersonal(string authToken, string username);

	[XmlRpcMethod("api.setUserAccountSelectionStandardPopup")]
	void SetUserAccountSelectionStandardPopup(string authToken, string username, bool allowPersonal, 
											  bool allowListSelection, bool allowPinCode, 
											  bool allowPrintingAsOtherUser, 
											  bool chargeToPersonalWhenSharedSelected);

	[XmlRpcMethod("api.listUserAccounts")]
	string[] ListUserAccounts(string authToken, int offset, int limit);

	[XmlRpcMethod("api.listSharedAccounts")]
	string[] ListSharedAccounts(string authToken, int offset, int limit);
	
	[XmlRpcMethod("api.getTotalUsers")]
	int GetTotalUsers(string authToken);
	
	[XmlRpcMethod("api.listUserSharedAccounts")]
	string[] ListUserSharedAccounts(string authToken, string username, int offset, int limit, bool ignoreAccountMode);
	
	[XmlRpcMethod("api.listUserSharedAccounts")]
	string[] ListUserSharedAccounts(string authToken, string username, int offset, int limit);
    
	[XmlRpcMethod("api.isSharedAccountExists")]
	bool SharedAccountExists(string authToken, string accountName);

	[XmlRpcMethod("api.getSharedAccountAccountBalance")]
	double GetSharedAccountAccountBalance(string authToken, string sharedAccountName);

	[XmlRpcMethod("api.getSharedAccountProperty")]
	string GetSharedAccountProperty(string authToken, string sharedAccountName, string propertyName);

	[XmlRpcMethod("api.getSharedAccountProperties")]
	string[] GetSharedAccountProperties(string authToken, string sharedAccountName, string[] propertyNames);

	[XmlRpcMethod("api.setSharedAccountProperty")]
	void SetSharedAccountProperty(string authToken, string sharedAccountName, string propertyName,
								  string propertyValue);

	[XmlRpcMethod("api.setSharedAccountProperties")]
	void SetSharedAccountProperties(string authToken, string sharedAccountName, string[][] propertyNamesAndValues);
								  
	[XmlRpcMethod("api.adjustSharedAccountAccountBalance")]
	void AdjustSharedAccountAccountBalance(string authToken, string accountName, double adjustment, string comment);

	[XmlRpcMethod("api.setSharedAccountAccountBalance")]
	void SetSharedAccountAccountBalance(string authToken, string accountName, double balance, string comment);

	[XmlRpcMethod("api.addNewSharedAccount")]
	void AddNewSharedAccount(string authToken, string sharedAccountName);
	
	[XmlRpcMethod("api.renameSharedAccount")]
	void RenameSharedAccount(string authToken, string currentSharedAccountName, string newSharedAccountName);
	
	[XmlRpcMethod("api.deleteExistingSharedAccount")]
	void DeleteExistingSharedAccount(string authToken, string sharedAccountName);

	[XmlRpcMethod("api.addSharedAccountAccessUser")]
	void AddSharedAccountAccessUser(string authToken, string sharedAccountName, string username);

	[XmlRpcMethod("api.addSharedAccountAccessGroup")]
	void AddSharedAccountAccessGroup(string authToken, string sharedAccountName, string groupName);

	[XmlRpcMethod("api.removeSharedAccountAccessUser")]
	void RemoveSharedAccountAccessUser(string authToken, string sharedAccountName, string username);

	[XmlRpcMethod("api.removeSharedAccountAccessGroup")]
	void RemoveSharedAccountAccessGroup(string authToken, string sharedAccountName, string groupName);

	[XmlRpcMethod("api.getPrinterProperty")]
	string GetPrinterProperty(string authToken, string serverName, string printerName, string propertyName);

	[XmlRpcMethod("api.setPrinterProperty")]
	void SetPrinterProperty(string authToken, string serverName, string printerName, string propertyName,
							string propertyValue);

	[XmlRpcMethod("api.listPrinters")]
	string[] ListPrinters(string authToken, int offset, int limit);

	[XmlRpcMethod("api.resetPrinterCounts")]
	void ResetPrinterCounts(string authToken, string serverName, string printerName, string resetBy);

	[XmlRpcMethod("api.addPrinterGroup")]
	void AddPrinterGroup(string authToken, string serverName, string printerName, string printerGroupName);

	[XmlRpcMethod("api.setPrinterGroups")]
	void SetPrinterGroups(string authToken, string serverName, string printerName, string printerGroupNames);

	[XmlRpcMethod("api.disablePrinter")]
	void DisablePrinter(string authToken, string serverName, string printerName, int disableMins);
	
	[XmlRpcMethod("api.deletePrinter")]
	void DeletePrinter(string authToken, string serverName, string printerName);

	[XmlRpcMethod("api.renamePrinter")]
	void RenamePrinter(string authToken, string serverName, string printerName, string newServerName,
					   string newPrinterName);
					   
	[XmlRpcMethod("api.addPrinterAccessGroup")]
	void AddPrinterAccessGroup(string authToken, string serverName, string printerName, string groupName);
					   
	[XmlRpcMethod("api.removePrinterAccessGroup")]
	void RemovePrinterAccessGroup(string authToken, string serverName, string printerName, string groupName);
	
	[XmlRpcMethod("api.setPrinterCostSimple")]
	void SetPrinterCostSimple(string authToken, string serverName, string printerName, double costPerPage);

	[XmlRpcMethod("api.getPrinterCostSimple")]
	double GetPrinterCostSimple(string authToken, string serverName, string printerName);

	[XmlRpcMethod("api.addNewGroup")]
	void AddNewGroup(string authToken, string groupName);

	[XmlRpcMethod("api.syncGroup")]
	bool SyncGroup(string authToken, string groupName);

	[XmlRpcMethod("api.removeGroup")]
	void RemoveGroup(string authToken, string groupName);

	[XmlRpcMethod("api.listUserGroups")]
	string[] ListUserGroups(string authToken, int offset, int limit);

	[XmlRpcMethod("api.getUserGroups")]
	string[] GetUserGroups(string authToken, string userName);

	[XmlRpcMethod("api.isGroupExists")]
	bool GroupExists(string authToken, string groupName);

	[XmlRpcMethod("api.setGroupQuota")]
	void SetGroupQuota(string authToken, string groupName, double quotaAmount, string period,
					   double quotaMaxAccumulation);

	[XmlRpcMethod("api.getGroupQuota")]
	GetGroupQuotaResponse GetGroupQuota(string authToken, string groupName);

	[XmlRpcMethod("api.useCard")]
	string UseCard(string authToken, string username, string cardNumber);

	[XmlRpcMethod("api.performOnlineBackup")]
	void PerformOnlineBackup(string authToken);

	[XmlRpcMethod("api.performGroupSync")]
	void PerformGroupSync(string authToken);

	[XmlRpcMethod("api.performUserAndGroupSync")]
	void PerformUserAndGroupSync(string authToken);

	[XmlRpcMethod("api.performUserAndGroupSyncAdvanced")]
	void PerformUserAndGroupSyncAdvanced(string authToken, bool deleteNonExistentUsers, bool updateUserDetails);

	[XmlRpcMethod("api.addNewUsers")]
	void AddNewUsers(string authToken);

	[XmlRpcMethod("api.batchImportSharedAccounts")]
	string BatchImportSharedAccounts(string authToken, string importFile, bool test, bool deleteNonExistentAccounts);

	[XmlRpcMethod("api.batchImportUsers")]
	void BatchImportUsers(string authToken, string importFile, bool createNewUsers);

	[XmlRpcMethod("api.batchImportInternalUsers")]
	void BatchImportInternalUsers(string authToken, string importFile, bool overwriteExistingPasswords,
								  bool overwriteExistingPINs);

	[XmlRpcMethod("api.batchImportUserCardIdNumbers")]
	void BatchImportUserCardIdNumbers(string authToken, string importFile, bool overwriteExistingPINs);

	[XmlRpcMethod("api.getConfigValue")]
	string GetConfigValue(string authToken, string configName);

	[XmlRpcMethod("api.setConfigValue")]
	void SetConfigValue(string authToken, string configName, string configValue);

	[XmlRpcMethod("api.processJob")]
	void ProcessJob(string authToken, string jobDetails);

	[XmlRpcMethod("api.changeInternalAdminPassword")]
	bool ChangeInternalAdminPassword(string authToken, string newPassword);
}




/// <summary>
///  A proxy designed to wrap XML-RCP calls the Application Server's XML-RPC API commands. This class requires the .NET
///  XML-RPC Library available from http://www.xml-rpc.net/
/// </summary>
public class ServerCommandProxy {
	private readonly IServerCommandProxy _proxy;
	private readonly string _authToken;

	/// <summary>
	///  The constructor.
	/// </summary>
	///  
	/// <param name="server">
	///  The name or IP address of the server hosting the Application Server. The server should be configured
	///  to allow XML-RPC connections from the host running this proxy class. Localhost is generally accepted
	///  by default.
	/// </param>
	/// <param name="port">
	///  The port the Application Server is listening on. This is port 9191 on a default install.
	/// </param>
	/// <param name="authToken">
	///  The authentication token as a string. All RPC calls must pass through an authentication token. At the
	///  current time this is simply the built-in "admin" user's password.
	/// </param>
	public ServerCommandProxy(string server, int port, string authToken) {
		// this is the XML-RPC-v2 form:
		//_proxy = XmlRpcProxyGen.Create<IServerCommandProxy>();
		// XML-RPC-v1 uses the non-generic form... hopefully it will be around for a while
		_proxy = (IServerCommandProxy)XmlRpcProxyGen.Create(typeof(IServerCommandProxy));

		_proxy.Url = "http://" + server + ":" + port + "/rpc/api/xmlrpc";
		_authToken = authToken;
	}

	


	/// <summary>
	///  Test to see if a user associated with "username" exists in the system.
	/// </summary>
	///  
	/// <param name="username">
	///  The username to test.
	/// </param>
	/// <returns>
	///  Returns true if the user exists in the system, else returns false.
	/// </returns>
	public bool UserExists(string username) {
		return _proxy.UserExists(_authToken, username);
	}

	/// <summary>
	///  Gets a user's current account balance.
	/// </summary>
	///
	/// <param name="username">
	///  The name of the user.
	/// </param>
	/// <param name="accountName">
	///  Optional name of the user's personal account. If blank, the total balance is returned.
	/// </param>
	/// <returns>
	///  The value of the user's account.
	/// </returns>
	public double GetUserAccountBalance(string username, string accountName) {
		return _proxy.GetUserAccountBalance(_authToken, username, accountName);
	}

	/// <summary>Gets a user property.</summary>
	///
	/// <param name="username">The name of the user.</param>
	/// <param name="propertyName">
	/// The name of the property to get.  The following list of property names can also be set using
	/// <see cref="SetUserProperty" />:
	///<list type="bullet">
	/// <item><description><c>balance</c>: the user's balance, unformatted, e.g. "1234.56".</description></item>
	/// <item><description><c>card-number</c></description></item>
    /// card-number2 not valid
	/// <item><description><c>card-number2</c></description></item>
	/// <item><description><c>card-pin</c></description></item>
	/// <item><description><c>department</c></description></item>
	/// <item><description>
	///  <c>disabled-net</c>: <c>true</c> if the user's 'net access is disabled, otherwise <c>false</c>
	/// </description></item>
	/// <item><description>
	///  <c>disabled-print</c>: <c>true</c> if the user's printing is disabled, otherwise <c>false</c>
	/// </description></item>
	/// <item><description><c>email</c></description></item>
	/// <item><description><c>full-name</c></description></item>
	/// <item><description>
	///  <c>internal</c>: <c>true</c> if this is an internal user, otherwise <c>false</c>
	/// </description></item>
	/// <item><description><c>notes</c></description></item>
	/// <item><description><c>office</c></description></item>
	/// <item><description>
	///  <c>print-stats.job-count</c>: total number of print jobs from this user, unformatted, e.g. "1234"
	/// </description></item>
	/// <item><description>
	///  <c>print-stats.page-count</c>: total number of pages printed by this user, unformatted, e.g. "1234"
	/// </description></item>
	/// <item><description>
	///  <c>net-stats.data-mb</c>: total 'net MB used by this user, unformatted, e.g. "1234.56"
	/// </description></item>
	/// <item><description>
	///  <c>net-stats.time-hours</c>: total 'net hours used by this user, unformatted, e.g. "1234.56"
	/// </description></item>
	/// <item><description>
	///  <c>restricted</c>: <c>true</c> if this user's printing is restricted, <c>false</c> if they are unrestricted.
	/// </description></item>
	///</list>
	/// The following options are "read only", i.e. cannot be set using <see cref="SetUserProperty" />:
	///<list type="bullet">
	/// <item><description>
	///  <c>account-selection.mode</c>: the user's account selection mode.  One of the following:
	///  <list type="bullet">
	///   <item><description><c>AUTO_CHARGE_TO_PERSONAL_ACCOUNT</c></description></item>
	///   <item><description><c>CHARGE_TO_PERSONAL_ACCOUNT_WITH_CONFIRMATION</c></description></item>
	///   <item><description><c>AUTO_CHARGE_TO_SHARED</c></description></item>
	///   <item><description><c>SHOW_ACCOUNT_SELECTION_POPUP</c></description></item>
	///   <item><description><c>SHOW_ADVANCED_ACCOUNT_SELECTION_POPUP</c></description></item>
	///   <item><description><c>SHOW_MANAGER_MODE_POPUP</c></description></item>
	///  </list>
	/// </description></item>
	/// <item><description>
	///  <c>account-selection.can-charge-personal</c>: <c>true</c> if the user's account selection settings allow them
	///  to charge jobs to their personal account, otherwise <c>false</c>.
	/// </description></item>
	/// <item><description>
	///  <c>account-selection.can-charge-shared-from-list</c>: <c>true</c> if the user's account selection settings
	///  allow them to select a shared account to charge from a list of shared accounts, otherwise <c>false</c>.
	/// </description></item>
	/// <item><description>
	///  <c>account-selection.can-charge-shared-by-pin</c>: <c>true</c> if the user's account selection settings allow
	///  them to charge a shared account by PIN or code, otherwise <c>false</c>.
	/// </description></item>
	///</list>
	/// </param>
	/// <returns>The value of the requested property.</returns>
	///
	/// <see cref="SetUserProperty" />
	public string GetUserProperty(string username, string propertyName) {
		return _proxy.GetUserProperty(_authToken, username, propertyName);
	}

	/// <summary>
	///  Get multiple user properties at once (to save multiple calls).
	/// </summary>
	///
	/// <param name="username">
	///  The name of the user.
	/// </param>
	/// <param name="propertyNames">
	///  The names of the properties to get.  See <see cref="GetUserProperty" /> for valid property names.
	/// </param>
	/// <returns>
	///  The property values (in the same order as given in <paramref param="propertyNames" />).
	/// </returns>
	///
	/// <see cref="GetUserProperty" />
	/// <see cref="SetUserProperties" />
	public string[] GetUserProperties(string username, string[] propertyNames) {
		return _proxy.GetUserProperties(_authToken, username, propertyNames);
	}

	/// <summary>
	///  Sets a user property.
	/// </summary>
	///
	/// <param name="username">
	///  The name of the user.
	/// </param>
	/// <param name="propertyName">
	///  The name of the property to set.  Valid options include: balance, card-number, card-pin, department,
	///  disabled-net, disabled-print, email, full-name, notes, office, password, print-stats.job-count,
	///  print-stats.page-count, net-stats.data-mb, net-stats.time-hours, restricted.
	/// </param>
	/// <param name="propertyValue">
	///  The value of the property to set.
	/// </param>
	///
	/// <see cref="GetUserProperty" />
	public void SetUserProperty(string username, string propertyName, string propertyValue) {
		_proxy.SetUserProperty(_authToken, username, propertyName, propertyValue);
	}

	/// <summary>
	///  Set multiple user properties at once (to save multiple calls).
	/// </summary>
	///
	/// <param name="username">
	///  The name of the user.
	/// </param>
	/// <param name="propertyNamesAndValues">
	///  The list of property names and values to set. E.g. [["balance", "1.20"], ["office", "East Wing"]].  See
	///  <see cref="SetUserProperty" /> for valid property names.
	/// </param>
	///
	/// <see cref="GetUserProperties" />
	/// <see cref="SetUserProperty" />
	public void SetUserProperties(string username, string[][] propertyNamesAndValues) {
		_proxy.SetUserProperties(_authToken, username, propertyNamesAndValues);
	}

	/// <summary>
	///  Adjust a user's account balance by an adjustment amount. An adjustment bay be positive (add to the user's
	///  account) or negative (subtract from the account).
	/// </summary>
	///  
	/// <param name="username">
	///  The username associated with the user who's account is to be adjusted.
	/// </param>
	/// <param name="adjustment">
	///  The adjustment amount. Positive to add credit and negative to subtract.
	/// </param>
	/// <param name="comment">
	///  A user defined comment to associated with the transaction. This may be a null string.
	/// </param>
	/// <param name="accountName">
	///  Optional name of the user's personal account. If blank, the built-in default account is used.
	///      If multiple personal accounts is enabled the account name must be provided.
	/// </param>
	public void AdjustUserAccountBalance(string username, double adjustment, string comment, string accountName) {
		_proxy.AdjustUserAccountBalance(_authToken, username, adjustment, comment, accountName);
	}
	
	/// <summary>
	/// Adjust a user's account balance by an adjustment amount (if there is credit available).   This can be used
	/// to perform atomic account adjustments, without needed to check the user's balance first. An adjustment may 
	/// be positive (add to the user's account) or negative (subtract from the account).
	/// </summary>
	///  
	/// <param name="username">
	///  The username associated with the user who's account is to be adjusted.
	/// </param>
	/// <param name="adjustment">
	///  The adjustment amount. Positive to add credit and negative to subtract.
	/// </param>
	/// <param name="comment">
	///  A user defined comment to associated with the transaction. This may be a null string.
	/// </param>
	/// <param name="accountName">
	///  Optional name of the user's personal account. If blank, the built-in default account is used.
	///      If multiple personal accounts is enabled the account name must be provided.
	/// </param>
	/// <returns>
	///  True if the transaction was performed, and false if the user did not have enough balance available.
	/// </returns>
	public bool AdjustUserAccountBalanceIfAvailable(string username, double adjustment, string comment, string accountName) {
		return _proxy.AdjustUserAccountBalanceIfAvailable(_authToken, username, adjustment, comment, accountName);
	}
	
	/// <summary>
	/// Adjust a user's account balance by an adjustment amount (if there is credit available to leave the specified
	/// amount still available in the account).   This can be used to perform atomic account adjustments, without 
	/// need to check the user's balance first. An adjustment may be positive (add to the user's account) 
	/// or negative (subtract from the account).
	/// </summary>
	///  
	/// <param name="username">
	///  The username associated with the user who's account is to be adjusted.
	/// </param>
	/// <param name="adjustment">
	///  The adjustment amount. Positive to add credit and negative to subtract.
	/// </param>
	/// <param name="leaveRemaining">
	///  The amount to leave in the account when deductions are done.
	/// </param>
	/// <param name="comment">
	///  A user defined comment to associated with the transaction. This may be a null string.
	/// </param>
	/// <param name="accountName">
	///  Optional name of the user's personal account. If blank, the built-in default account is used.
	///      If multiple personal accounts is enabled the account name must be provided.
	/// </param>
	/// <returns>
	///  True if the transaction was performed, and false if the user did not have enough balance available.
	/// </returns>
	public bool AdjustUserAccountBalanceIfAvailableLeaveRemaining(string username, double adjustment, double leaveRemaining, string comment, string accountName) {
		return _proxy.AdjustUserAccountBalanceIfAvailableLeaveRemaining(_authToken, username, adjustment, leaveRemaining, comment, accountName);
	}

	/// <summary>
	/// Adjust a user's account balance.  User lookup is by card number.
	/// </summary>
	/// <param name="cardNumber">
	/// The card number associated with the user who's account is to be adjusted.
	/// </param>
	/// <param name="adjustment">
	/// The adjustment amount.  Positive to add credit and negative to subtract.
	/// </param>
	/// <param name="comment">
	/// A user defined comment to be associated with the transaction.  This may be a null string.
	/// </param>
	/// <returns>
	/// True if successful, false if not (e.g. no users found for the supplied card number).
	/// </returns>
	public bool AdjustUserAccountBalanceByCardNumber(string cardNumber, double adjustment, string comment)
	{
		return _proxy.AdjustUserAccountBalanceByCardNumber(_authToken, cardNumber, adjustment, comment);
	}

	/// <summary>
	/// Adjust a user's account balance.  User lookup is by card number.
	/// </summary>
	/// <param name="cardNumber">
	/// The card number associated with the user who's account is to be adjusted.
	/// </param>
	/// <param name="adjustment">
	/// The adjustment amount.  Positive to add credit and negative to subtract.
	/// </param>
	/// <param name="comment">
	/// A user defined comment to be associated with the transaction.  This may be a null string.
	/// </param>
	/// <param name="accountName">
	/// Optional name of the user's personal account.  If blank, the built-in default account is used.  If multiple
	/// personal accounts is enabled the account name must be provided.
	/// </param>
	/// <returns>
	/// True if successful, FALSE if not (eg. no users found for the supplied card number)
	/// </returns>
	public bool AdjustUserAccountBalanceByCardNumber(string cardNumber, double adjustment, string comment,
			string accountName)
	{
		return _proxy.AdjustUserAccountBalanceByCardNumber(_authToken, cardNumber, adjustment, comment, accountName);
	}

	/// <summary>
	///  Adjust the account balance of all users in a group by an adjustment amount. An adjustment may be positive 
	///  (add to the user's account) or negative (subtract from the account).
	/// </summary>
	///  
	/// <param name="group">
	///  The group for which all users' accounts are to be adjusted.
	/// </param>
	/// <param name="adjustment">
	///  The adjustment amount. Positive to add credit and negative to subtract.
	/// </param>
	/// <param name="comment">
	///  A user defined comment to be associated with the transaction. This may be a null string.
	/// </param>
	/// <param name="accountName">
	///  Optional name of the user's personal account. If blank, the built-in default account is used.
	///      If multiple personal accounts is enabled the account name must be provided.
	/// </param>
	public void AdjustUserAccountBalanceByGroup(string group, double adjustment, string comment, string accountName) {
		_proxy.AdjustUserAccountBalanceByGroup(_authToken, group, adjustment, comment, accountName);
	}

	/// <summary>
	///  Adjust the account balance of all users in a group by an adjustment amount. An adjustment may be positive 
	///  (add to the user's account) or negative (subtract from the account).
	/// </summary>
	///  
	/// <param name="group">
	///  The group for which all users' accounts are to be adjusted.
	/// </param>
	/// <param name="adjustment">
	///  The adjustment amount. Positive to add credit and negative to subtract.
	/// </param>
	/// <param name="limit">
	///  Only add balance up to this limit.
	/// </param>
	/// <param name="comment">
	///  A user defined comment to be associated with the transaction. This may be a null string.
	/// </param>
	/// <param name="accountName">
	///  Optional name of the user's personal account. If blank, the built-in default account is used.
	///      If multiple personal accounts is enabled the account name must be provided.
	/// </param>
	public void AdjustUserAccountBalanceByGroup(string group, double adjustment, double limit, string comment, string accountName) {
		_proxy.AdjustUserAccountBalanceByGroup(_authToken, group, adjustment, limit, comment, accountName);
	}

	/// <summary>
	///  Set the balance on a user's account to a set value. This is conducted as a transaction.
	/// </summary>
	///  
	/// <param name="username">
	///  The username associated with the user who's account is to be set.
	/// </param>
	/// <param name="balance">
	///  The balance to set the account to.
	/// </param>
	/// <param name="comment">
	///  A user defined comment to associate with the transaction. This may be a null string.
	/// </param>
	/// <param name="accountName">
	///  Optional name of the user's personal account. If blank, the built-in default account is used.
	///      If multiple personal accounts is enabled the account name must be provided.
	/// </param>
	public void SetUserAccountBalance(string username, double balance, string comment, string accountName) {
		_proxy.SetUserAccountBalance(_authToken, username, balance, comment, accountName);
	}

	/// <summary>
	///  Set the balance for each member of a group to the given value.
	/// </summary>
	///
	/// <param name="group">
	///  The group for which all users' balance is to be set.
	/// </param>
	/// <param name="balance">
	///  The value to set all users' balance to.
	/// </param>
	/// <param name="comment">
	///  A user defined comment to associate with the transaction. This may be a null string.
	/// </param>
	/// <param name="accountName">
	///  Optional name of the user's personal account. If blank, the built-in default account is used.
	///      If multiple personal accounts is enabled the account name must be provided.
	/// </param>
	public void SetUserAccountBalanceByGroup(string group, double balance, string comment, string accountName) {
		_proxy.SetUserAccountBalanceByGroup(_authToken, group, balance, comment, accountName);
	}

	/// <summary>
	///  Reset the counts (pages and job counts) associated with a user account.
	/// </summary>
	///  
	/// <param name="username">
	///  The username associated with the user who's counts are to be reset.
	/// </param>
	/// <param name="resetBy">
	///  The name of the user/script/process reseting the counts.
	/// </param>
	public void ResetUserCounts(string username, string resetBy) {
		_proxy.ResetUserCounts(_authToken, username, resetBy);
	}

	/// <summary>
	///  Re-applies initial user settings on the given user. These initial settings are based on group membership.
	/// </summary>
	///  
	/// <param name="username">
	///  The user's username
	/// </param>
	public void ReapplyInitialUserSettings(string username) {
		_proxy.ReapplyInitialUserSettings(_authToken, username);
	}

	/// <summary>
	///  Disable printing for a user for a specified period of time.
	/// </summary>
	///
	/// <param name="username">
	///  The name of the user to disable printing for.
	/// </param>
	/// <param name="disableMins">
	///  The number of minutes to disable printing for the user. If the value is -1 the printer will be disabled for all
	///  time until re-enabled.
	/// </param>
	public void DisablePrintingForUser(string username, int disableMins) {
		_proxy.DisablePrintingForUser(_authToken, username, disableMins);
	}

	/// <summary>
	///  Trigger the process of adding a new user account. Assuming the user exists in the OS/Network/Domain user
	///  directory, the account will be created with the correct initial settings as defined by the rules setup in the
	///  admin interface under the Group's section.
	///  
	///  Calling this method is equivalent to triggering the "new user" event when a new user performs printing for the
	///  first time.
	/// </summary>
	///  
	/// <param name="username">
	///  The username of the user to add.
	/// </param>
	public void AddNewUser(string username) {
		_proxy.AddNewUser(_authToken, username);
	}

	/// <summary>
	///  Rename a user account.  Useful when the user has been renamed in the domain / directory, so that usage history
	///  can be maintained for the new username.  This should be performed in conjunction with a rename of the user in
	///  the domain / user directory, as all future usage and authentication will need to use the new username.
	/// </summary>
	///
	/// <param name="currentUserName">
	///  The username of the user to rename.
	/// </param>
	/// <param name="newUserName">
	///  The user's new username.
	/// </param>
	public void RenameUserAccount(string currentUserName, string newUserName) {
		_proxy.RenameUserAccount(_authToken, currentUserName, newUserName);
	}

	/// <summary>
	/// Delete/remove an existing user from the user list. Use this method with care.  Calling this will
	/// perminantly delete the user account from the user list (print and transaction history records remain).
	/// </summary>
	///  
	/// <param name="username">
	///  The username of the user to delete/remove.
	/// </param>
	public void DeleteExistingUser(string username) {
		_proxy.DeleteExistingUser(_authToken, username);
	}

	/// <summary>
	/// Creates and sets up a new internal user account.  The (unique) username and password are required at a minimum.
	/// The other properties are optional and will be used if not blank.  Properties may also be set after creation
	/// using <see cref="SetUserProperty" /> or <see cref="SetUserProperties" />.
	/// </summary>
	///  
	/// <param name="username">
	///  (required) A unique username.  An exception is thrown if the username already exists.
	/// </param>
	/// <param name="password">
	///  (required) The user's password.
	/// </param>
	/// <param name="fullName">
	///  (optional) The full name of the user.
	/// </param>
	/// <param name="email">
	///  (optional) The email address of the user.
	/// </param>
	/// <param name="cardId">
	///  (optional) The card/identity number of the user.
	/// </param>
	/// <param name="pin">
	///  The card/id pin.
	/// </param>
	public void AddNewInternalUser(string username, string password, string fullName, string email, string cardId,
			string pin) {
		_proxy.AddNewInternalUser(_authToken, username, password, fullName, email, cardId, pin);
	}

	/// <summary>
	///  Looks up the user with the given user id number and returns their user name.  If no match was found an empty
	///  string is returned.
	/// </summary>
	///
	/// <param name="idNo">
	///  The user id number to look up.
	/// </param>
	/// <returns>
	///  The matching user name, or an empty string if there was no match.
	/// </returns>
	public string LookUpUserNameByIDNo(string idNo) {
		return _proxy.LookUpUserNameByIDNo(_authToken, idNo);
	}

	/// <summary>
	///  Looks up the user with the given user card number and returns their user name.  If no match was found an empty
	///  string is returned.
	/// </summary>
	///
	/// <param name="cardNo">
	///  The user card number to look up.
	/// </param>
	/// <returns>
	///  The matching user name, or an empty string if there was no match.
	/// </returns>
	public string LookUpUserNameByCardNo(string cardNo) {
		return _proxy.LookUpUserNameByCardNo(_authToken, cardNo);
	}

	/// <summary>
	///  Adds a user as an admin with default admin rights.
	/// </summary>
	///
	/// <param name="username">
	///  The name of the user.
	/// </param>
	public void AddAdminAccessUser(string username) {
		_proxy.AddAdminAccessUser(_authToken, username);
	}

	/// <summary>
	///  Removes an admin user from the list of admins.
	/// </summary>
	///
	/// <param name="username">
	///  The name of the user.
	/// </param>
	public void RemoveAdminAccessUser(string username) {
		_proxy.RemoveAdminAccessUser(_authToken, username);
	}

	/// <summary>
	///  Adds a group as an admin group with default admin rights.
	/// </summary>
	///
	/// <param name="groupName">
	///  The name of the group.
	/// </param>
	public void AddAdminAccessGroup(string groupName) {
		_proxy.AddAdminAccessGroup(_authToken, groupName);
	}

	/// <summary>
	///  Removes a group from the list of admin groups.
	/// </summary>
	///
	/// <param name="groupName">
	///  The name of the group.
	/// </param>
	public void RemoveAdminAccessGroup(string groupName) {
		_proxy.RemoveAdminAccessGroup(_authToken, groupName);
	}

    /// <summary>
    /// Adds a user to a group
    /// </summary>
    ///
    /// <param name="username">
    /// the name of the user
    /// </param>
    ///
    /// <param name="groupName">
    /// the name of the group
    /// </param>
    public void AddUserToGroup(string username, string groupName)
    {
        _proxy.AddUserToGroup(_authToken, username, groupName);
    }

    /// <summary>
    /// Adds a user to a group
    /// </summary>
    ///
    /// <param name="username">
    /// the name of the user
    /// </param>
    ///
    /// <param name="groupName">
    /// the name of the group
    /// </param>
    public void RemoveUserFromGroup(string username, string groupName)
    {
        _proxy.RemoveUserFromGroup(_authToken, username, groupName);
    }


	/// <summary>
	/// List all user accounts (sorted by username) starting at 'offset' and ending at 'limit'.
	/// This can be used to enumerate all user accounts in 'pages'.  When retrieving a list of all user accounts, the
	/// recommended page size / limit is 1000.  Batching in groups of 1000 ensures efficient transfer and
	/// processing.
	/// E.g.:
	///   listUserAccounts(0, 1000) - returns users 0 through 999
	///   listUserAccounts(1000, 1000) - returns users 1000 through 1999
	///   listUserAccounts(2000, 1000) - returns users 2000 through 2999
	/// </summary>
	///
	/// <param name="offset">
	///  The 0-index offset in the list of users to return.  I.e. 0 is the first user, 1 is the second, etc.
	/// </param>
	/// <param name="limit">
	///  The number of accounts to return in this batch.  Recommended: 1000.
	/// </param>
	/// <returns>
	///  An array of user names.
	/// </returns>
	public string[] ListUserAccounts(int offset, int limit) {
		return _proxy.ListUserAccounts(_authToken, offset, limit);
	}

	/// <summary>
	/// List all shared accounts (sorted by account name) starting at <code>offset</code> and ending at <code>limit</code>.
	/// This can be used to enumerate all shared accounts in 'pages'.  When retrieving a list of all shared accounts, the
	/// recommended page size / limit is <code>1000</code>.  Batching in groups of 1000 ensures efficient transfer and
	/// processing.
	/// E.g.:
	///   listSharedAccounts(0, 1000) - returns accounts 0 through 999
	///   listSharedAccounts(1000, 1000) - returns accounts 1000 through 1999
	///   listSharedAccounts(2000, 1000) - returns accounts 2000 through 2999
	/// </summary>
	///
	/// <param name="offset">
	///  The 0-index offset in the list of accounts to return.  I.e. 0 is the first account, 1 is the second, etc.
	/// </param>
	/// <param name="limit">
	///  The number of users to return in this batch.  Recommended: 1000.
	/// </param>
	/// <returns>
	///  An array of shared accounts names.
	/// </returns>
	public string[] ListSharedAccounts(int offset, int limit) {
		return _proxy.ListSharedAccounts(_authToken, offset, limit);
	}


	/// <summary>
	/// Get the count of all users in the system.
	/// </summary>
	///
	/// <returns>
	///  Numeric total of all user accounts.
	/// </returns>
	public int GetTotalUsers() {
		return _proxy.GetTotalUsers(_authToken);
	}

	/// <summary>
	/// List all shared accounts (sorted by account name) that the user has access to, starting at <code>offset</code> 
	/// and listing only <code>limit</code> accounts. This can be used to enumerate all shared accounts in 'pages'.  
	/// When retrieving a list of all shared accounts, the recommended page size / limit is <code>1000</code>.  
	/// Batching in groups of 1000 ensures efficient transfer and processing.
	/// E.g.:
	///  listUserSharedAccounts("user", 0, 1000) - returns accounts 0 through 999
	///  listUserSharedAccounts("user", 1000, 1000) - returns accounts 1000 through 1999
	///  listUserSharedAccounts("user", 2000, 1000) - returns accounts 2000 through 2999
	/// </summary>
	///
	/// <param name="username">
	///  The user's name.
	/// </param>
	/// <param name="offset">
	///  The 0-index offset in the list of accounts to return.  I.e. 0 is the first account, 1 is the second, etc.
	/// </param>
	/// <param name="limit">
	///  The number of accounts to return in this batch.  Recommended: 1000.
	/// </param>
    /// <param name="ignoreAccountMode">
    ///  If true, list accounts regardless of current shared account mode.
	/// </param>
	/// <returns>
	///  An array of shared accounts names the user has access to.
	/// </returns>
    public string[] ListUserSharedAccounts(string username, int offset, int limit, bool ignoreAccountMode) {
        return _proxy.ListUserSharedAccounts(_authToken, username, offset, limit, ignoreAccountMode);
	}
    
	public string[] ListUserSharedAccounts(string username, int offset, int limit) {
		return _proxy.ListUserSharedAccounts(_authToken, username, offset, limit, false);
	}    

	/// <summary>
	///  Test to see if a shared account exists.
	/// </summary>
	///  
	/// <param name="accountName">
	///  The name of the shared account.
	/// </param>
	/// <returns>
	///  Return true if the shared account exists, else false.
	/// </returns>
	public bool SharedAccountExists(string accountName) {
		return _proxy.SharedAccountExists(_authToken, accountName);
	}

	/// <summary>
	///  Gets a shared account's current balance.
	/// </summary>
	///
	/// <param name="sharedAccountName">
	///  The name of the shared account.
	/// </param>
	/// <returns>
	///  The value of the account's current balance.
	/// </returns>
	public double GetSharedAccountAccountBalance(string sharedAccountName) {
		return _proxy.GetSharedAccountAccountBalance(_authToken, sharedAccountName);
	}

	/// <summary>
	///  Gets a shared account property.
	/// </summary>
	///
	/// <param name="sharedAccountName">
	///  The name of the shared account.
	/// </param>
	/// <param name="propertyName">
	///  The name of the property to get.  Valid options include: access-groups, access-users, balance, comment-option,
	///  disabled, invoice-option, notes, pin, restricted.
	/// </param>
	/// <returns>
	///  The value of the requested property.
	/// </returns>
	///
	/// <see cref="SetSharedAccountProperty" />
	public string GetSharedAccountProperty(string sharedAccountName, string propertyName) {
		return _proxy.GetSharedAccountProperty(_authToken, sharedAccountName, propertyName);
	}

	/// <summary>
	///  Get multiple shared account properties at once (to save multiple calls).
	/// </summary>
	///
	/// <param name="sharedAccountName">
	///  The shared account name.
	/// </param>
	/// <param name="propertyNames">
	///  The names of the properties to get.  See <see cref="GetSharedAccountProperty" /> for valid property names.
	/// </param>
	/// <returns>
	///  The property values (in the same order as given in <paramref param="propertyNames" />.
	/// </returns>
	///
	/// <see cref="GetSharedAccountProperty" />
	/// <see cref="SetSharedAccountProperties" />
	public string[] GetSharedAccountProperties(string sharedAccountName, string[] propertyNames) {
		return _proxy.GetSharedAccountProperties(_authToken, sharedAccountName, propertyNames);
	}

	/// <summary>
	///  Sets a shared account property.
	/// </summary>
	///
	/// <param name="sharedAccountName">
	///  The name of the shared account.
	/// </param>
	/// <param name="propertyName">
	///  The name of the property to set.  See <see cref="GetSharedAccountProperty" /> for valid property names.
	/// </param>
	/// <param name="propertyValue">
	///  The value of the property to set.
	/// </param>
	///
	/// <see cref="GetSharedAccountProperty" />
	public void SetSharedAccountProperty(string sharedAccountName, string propertyName, string propertyValue) {
		_proxy.SetSharedAccountProperty(_authToken, sharedAccountName, propertyName, propertyValue);
	}

	/// <summary>
	///  Set multiple shared account properties at once (to save multiple calls).
	/// </summary>
	///
	/// <param name="sharedAccountName">
	///  The shared account name.
	/// </param>
	/// <param name="propertyNamesAndValues">
	///  The list of property names and values to set. E.g. [["balance", "1.20"], ["invoice-option", "ALWAYS_INVOICE"]].
	///  See <see cref="SetSharedAccountProperty" /> for valid property names.
	/// </param>
	///
	/// <see cref="GetSharedAccountProperties" />
	/// <see cref="SetSharedAccountProperty" />
	public void SetSharedAccountProperties(string sharedAccountName, string[][] propertyNamesAndValues) {
		_proxy.SetSharedAccountProperties(_authToken, sharedAccountName, propertyNamesAndValues);
	}

	/// <summary>
	///  Adjust a shared account's account balance by an adjustment amount. An adjustment bay be positive (add to the
	///  account) or negative (subtract from the account).
	/// </summary>
	///  
	/// <param name="accountName">
	///  The full name of the shared account to adjust.
	/// </param>
	/// <param name="adjustment">
	///  The adjustment amount. Positive to add credit and negative to subtract.
	/// </param>
	/// <param name="comment">
	///  A user defined comment to associated with the transaction. This may be a null string.
	/// </param>
	public void AdjustSharedAccountAccountBalance(string accountName, double adjustment, string comment) {
		_proxy.AdjustSharedAccountAccountBalance(_authToken, accountName, adjustment, comment);
	}

	/// <summary>
	///  Set a shared account's account balance.
	/// </summary>
	///  
	/// <param name="accountName">
	///  The name of the account to be adjusted.
	/// </param>
	/// <param name="balance">
	///  The balance to set (positive or negative).
	/// </param>
	/// <param name="comment">
	///  The comment to be associated with the transaction.
	/// </param>
	public void SetSharedAccountAccountBalance(string accountName, double balance, string comment) {
		_proxy.SetSharedAccountAccountBalance(_authToken, accountName, balance, comment);
	}

	/// <summary>
	///  Create a new shared account with the given name.
	/// </summary>
	///  
	/// <param name="sharedAccountName">
	///  The name of the shared account to create. Use a '\' to denote a subaccount, e.g.: 'parent\sub'
	/// </param>
	public void AddNewSharedAccount(string sharedAccountName) {
		_proxy.AddNewSharedAccount(_authToken, sharedAccountName);
	}

	/// <summary>
	///  Rename an existing shared account.
	/// </summary>
	///  
	/// <param name="currentSharedAccountName">
	///  The name of the shared account to rename. Use a '\' to denote a subaccount. e.g.: 'parent\sub'
	/// </param>
	/// <param name="newSharedAccountName">
	/// The new shared account name.
	/// </param>
	public void RenameSharedAccount(string currentSharedAccountName, string newSharedAccountName) {
		_proxy.RenameSharedAccount(_authToken, currentSharedAccountName, newSharedAccountName);
	}

	/// <summary>
	///  Delete a shared account from the system.  Use this method with care.  Deleting a shared account will
	///  permanently delete it from the shared account list (print history records will remain).
	/// </summary>
	///  
	/// <param name="sharedAccountName">
	///  The name of the shared account to delete.
	/// </param>
	public void DeleteExistingSharedAccount(string sharedAccountName) {
		_proxy.DeleteExistingSharedAccount(_authToken, sharedAccountName);
	}

	/// <summary>
	///  Allow the given user access to the given shared account without using a pin.
	/// </summary>
	///
	/// <param name="sharedAccountName">
	///  The name of the shared account to allow access to.
	/// </param>
	/// <param name="username">
	///  The name of the user to give access to.
	/// </param>
	public void AddSharedAccountAccessUser(string sharedAccountName, string username) {
		_proxy.AddSharedAccountAccessUser(_authToken, sharedAccountName, username);
	}

	/// <summary>
	///  Allow the given group access to the given shared account without using a pin.
	/// </summary>
	///
	/// <param name="sharedAccountName">
	///  The name of the shared account to allow access to.
	/// </param>
	/// <param name="groupName">
	///  The name of the group to give access to.
	/// </param>
	public void AddSharedAccountAccessGroup(string sharedAccountName, string groupName) {
		_proxy.AddSharedAccountAccessGroup(_authToken, sharedAccountName, groupName);
	}

	/// <summary>
	///  Revoke the given user's access to the given shared account.
	/// </summary>
	///
	/// <param name="sharedAccountName">
	///  The name of the shared account to revoke access to.
	/// </param>
	/// <param name="username">
	///  The name of the user to revoke access for.
	/// </param>
	public void RemoveSharedAccountAccessUser(string sharedAccountName, string username) {
		_proxy.RemoveSharedAccountAccessUser(_authToken, sharedAccountName, username);
	}

	/// <summary>
	///  Revoke the given group's access to the given shared account.
	/// </summary>
	///
	/// <param name="sharedAccountName">
	///  The name of the shared account to revoke access to.
	/// </param>
	/// <param name="groupName">
	///  The name of the group to revoke access for.
	/// </param>
	public void RemoveSharedAccountAccessGroup(string sharedAccountName, string groupName) {
		_proxy.RemoveSharedAccountAccessGroup(_authToken, sharedAccountName, groupName);
	}




	/// <summary>
	///  Gets a printer property.
	/// </summary>
	///
	/// <param name="serverName">
	///  The name of the server.
	/// </param>
	/// <param name="printerName">
	///  The name of the printer.
	/// </param>
	/// <param name="propertyName">
	///  The name of the property.  Valid options include: disabled, print-stats.job-count, print-stats.page-count,
	///  cost-model
	/// </param>
	/// <returns>
	///  The value of the requested property.
	/// </returns>
	public string GetPrinterProperty(string serverName, string printerName, string propertyName) {
		return _proxy.GetPrinterProperty(_authToken, serverName, printerName, propertyName);
	}

	/// <summary>
	///  Sets a printer property.
	/// </summary>
	///
	/// <param name="serverName">
	///  The name of the server.
	/// </param>
	/// <param name="printerName">
	///  The name of the printer.
	/// </param>
	/// <param name="propertyName">
	///  The name of the property.  Valid options include: disabled.
	/// </param>
	/// <param name="propertyValue">
	///  The value of the property to set.
	/// </param>
	public void SetPrinterProperty(string serverName, string printerName, string propertyName, string propertyValue) {
		_proxy.SetPrinterProperty(_authToken, serverName, printerName, propertyName, propertyValue);
	}

	/// <summary>
	/// List all printers (sorted by printer name) starting at 'offset' and ending at 'limit'.
	/// This can be used to enumerate all printers in 'pages'.  When retrieving a list of all printers, the
	/// recommended page size / limit is 1000.  Batching in groups of 1000 ensures efficient transfer and
	/// processing.
	/// E.g.:
	///   listPrinters(0, 1000) - returns users 0 through 999
	///   listPrinters(1000, 1000) - returns users 1000 through 1999
	///   listPrinters(2000, 1000) - returns users 2000 through 2999
	/// </summary>
	///
	/// <param name="offset">
	///  The 0-index offset in the list of printers to return.  I.e. 0 is the first printer, 1 is the second, etc.
	/// </param>
	/// <param name="limit">
	///  The number of printers to return in this batch.  Recommended: 1000.
	/// </param>
	/// <returns>
	///  An array of printers.
	/// </returns>
	public string[] ListPrinters(int offset, int limit) {
		return _proxy.ListPrinters(_authToken, offset, limit);
	}

	/// <summary>
	///  Reset the counts (pages and job counts) associated with a printer.
	/// </summary>
	///  
	/// <param name="serverName">
	///  The name of the server hosting the printer.
	/// </param>
	/// <param name="printerName">
	///  The printer's name.
	/// </param>
	/// <param name="resetBy">
	///  The name of the user/script/process resetting the counts.
	/// </param>
	/// 
	public void ResetPrinterCounts(string serverName, string printerName, string resetBy) {
		_proxy.ResetPrinterCounts(_authToken, serverName, printerName, resetBy);
	}

	/// <summary>
	///  Disable a printer for select period of time.
	/// </summary>
	///  
	/// <param name="serverName">
	///  The name of the server hosting the printer.
	/// </param>
	/// <param name="printerName">
	///  The printer's name.
	/// </param>
	/// <param name="disableMins">
	///  The number of minutes to disable the printer. If the value is -1 the printer will be disabled for all
	///  time until re-enabled.
	/// </param>
	public void DisablePrinter(string serverName, string printerName, int disableMins) {
		_proxy.DisablePrinter(_authToken, serverName, printerName, disableMins);
	}

	/// <summary>
	///  Delete a printer.
	/// </summary>
	///  
	/// <param name="serverName">
	///  The name of the server hosting the printer.
	/// </param>
	/// <param name="printerName">
	///  The printer's name.
	/// </param>
	public void DeletePrinter(string serverName, string printerName) {
		_proxy.DeletePrinter(_authToken, serverName, printerName);
	}

	/// <summary>
	///  Rename a printer.  This can be useful after migrating a print queue or print server (i.e. the printer retains
	///  its history and settings under the new name).  Note that in some cases case sensitivity is important, so care
	///  should be taken to enter the name exactly as it appears in the OS.
	/// </summary>
	///
	/// <param name="serverName">
	///  The existing printer's server name.
	/// </param>
	/// <param name="printerName">
	///  The existing printer's queue name.
	/// </param>
	/// <param name="newServerName">
	///  The new printer's server name.
	/// </param>
	/// <param name="newPrinterName">
	///  The new printer's queue name.
	/// </param>
	public void RenamePrinter(string serverName, string printerName, string newServerName, string newPrinterName) {
		_proxy.RenamePrinter(_authToken, serverName, printerName, newServerName, newPrinterName);
	}

	/// <summary>
	///  Add the group to the printer access group list.
	/// </summary>
	///
	/// <param name="serverName">
	///  The existing printer's server name.
	/// </param>
	/// <param name="printerName">
	///  The existing printer's queue name.
	/// </param>
	/// <param name="groupName">
	///  The name of the group that needs to be added to the printer group restrictions list
	/// </param>
	public void AddPrinterAccessGroup(string serverName, string printerName, string groupName) {
		_proxy.AddPrinterAccessGroup(_authToken, serverName, printerName, groupName);
	}

	/// <summary>
	///  Removes the group from the printer access group list.
	/// </summary>
	///
	/// <param name="serverName">
	///  The existing printer's server name.
	/// </param>
	/// <param name="printerName">
	///  The existing printer's queue name.
	/// </param>
	/// <param name="groupName">
	///  The name of the group that needs to be removed from the list of groups allowed to print to this printer.
	/// </param>
	public void RemovePrinterAccessGroup(string serverName, string printerName, string groupName) {
		_proxy.RemovePrinterAccessGroup(_authToken, serverName, printerName, groupName);
	}

	/// <summary>
	///  Method to set a simple single page cost using the Simple Charging Model.
	/// </summary>
	///  
	/// <param name="serverName">
	///  The name of the server.
	/// </param>
	/// <param name="printerName">
	///  The name of the printer.
	/// </param>
	/// <param name="costPerPage">
	///  The cost per page (simple charging model)
	/// </param>
	public void SetPrinterCostSimple(string serverName, string printerName, double costPerPage) {
		_proxy.SetPrinterCostSimple(_authToken, serverName, printerName, costPerPage);
	}

	/// <summary>
	///  Get the page cost if, and only if, the printer is using the Simple Charging Model.
	/// </summary>
	///
	/// <param name="serverName">
	///  The name of the server.
	/// </param>
	/// <param name="printerName">
	///  The name of the printer.
	/// </param>
	/// <returns>
	///  The default page cost. On failure an exception is thrown.
	/// </returns>
	public double GetPrinterCostSimple(string serverName, string printerName) {
		return _proxy.GetPrinterCostSimple(_authToken, serverName, printerName);
	}

	/// <summary>
	///  Add a new group to system's group list.  The caller is responsible for ensuring that the supplied group name is
	///  valid and exists in the linked user directory source.  The status of this method may be monitored with calls to
	///  <code>getTaskStatus()</code>.
	/// </summary>
	///
	/// <param name="groupName">
	///  The name of the new group to add. The group should already exist in the network user directory.
	/// </param>
	public void AddNewGroup(string groupName) {
		_proxy.AddNewGroup(_authToken, groupName);
	}

	/// <summary>
	///  Syncs an existing group with the configured directory server, updates the group membership.
	/// </summary>
	///
	/// <param name="groupName">
	///  The name of the new group to sync. The group should already exist in the network user directory.
	/// </param>
	/// <returns>
	///  <code>True</code> if successful.  On failure an exception is thrown.
	/// </returns>
	public bool SyncGroup(string groupName) {
		return _proxy.SyncGroup(_authToken, groupName);
	}

	/// <summary>
	///  Removes the user group.
	/// </summary>
	///
	/// <param name="groupName">
	///  The name of the group that needs to be deleted.
	/// </param>
	public void RemoveGroup(string groupName) {
		_proxy.RemoveGroup(_authToken, groupName);
	}
 
	/// <summary>
	/// List all user groups (sorted by groupname) starting at 'offset' and ending at 'limit'.
	/// This can be used to enumerate all groups in 'pages'.  When retrieving a list of all groups, the
	/// recommended page size / limit is 1000.  Batching in groups of 1000 ensures efficient transfer and
	/// processing.
	/// E.g.:
	///   listUserGroups(0, 1000) - returns users 0 through 999
	///   listUserGroups(1000, 1000) - returns users 1000 through 1999
	///   listUserGroups(2000, 1000) - returns users 2000 through 2999
	/// </summary>
	///
	/// <param name="offset">
	///  The 0-index offset in the list of groups to return.  I.e. 0 is the first group, 1 is the second, etc.
	/// </param>
	/// <param name="limit">
	///  The number of groups to return in this batch.  Recommended: 1000.
	/// </param>
	/// <returns>
	///  An array of user groups.
	/// </returns>
	public string[] ListUserGroups(int offset, int limit) {
		return _proxy.ListUserGroups(_authToken, offset, limit);
	}

	/// <summary>
	/// Retrive all groups a user is a member of.
	/// </summary>
	/// <param name="userName">The username to look up</param>
	/// <returns>An array of Group Names the user belongs to</returns>
	public string[] GetUserGroups(string userName) 
	{
		return _proxy.GetUserGroups(_authToken, userName);
	}

	/// <summary>
	///  Test to see if a group associated with groupname exists in the system.
	/// </summary>
	///  
	/// <param name="groupName">
	///  The groupname to test.
	/// </param>
	/// <returns>
	///  Returns true if the group exists in the system, else returns false.
	/// </returns>
	public bool GroupExists(string groupName) 
	{
		return _proxy.GroupExists(_authToken, groupName);
	}

	/// <summary>
	///  Set the group quota allocation settings on a given group.
	/// </summary>
	///
	/// <param name="groupName">
	///  The name of the group.
	/// </param>
	/// <param name="quotaAmount">
	///  The quota amount to set.
	/// </param>
	/// <param name="period">
	///  The schedule period (one of either NONE, DAILY, WEEKLY or MONTHLY);
	/// </param>
	/// <param name="quotaMaxAccumulation">
	///  The maximum quota accumulation.
	/// </param>
	public void SetGroupQuota(string groupName, double quotaAmount, string period, double quotaMaxAccumulation) {
		_proxy.SetGroupQuota(_authToken, groupName, quotaAmount, period, quotaMaxAccumulation);
	}

	/// <summary>
	///  Get the group quota allocation settings on a given group.
	/// </summary>
	///
	/// <param name="groupName">
	///  The name of the group.
	/// </param>
	/// <returns>
	///  A struct containing the quota amount, quota period and max accumulation amount.
	/// </returns>
	public GetGroupQuotaResponse GetGroupQuota(string groupName) {
		return _proxy.GetGroupQuota(_authToken, groupName);
	}

	/// <summary>
	///  Apply the value of a card to a user's account.
	/// </summary>
	///
	/// <param name="username">
	///  The name of the user with the account to credit.
	/// </param>
	/// <param name="cardNumber">
	///  The number of the card to use.
	/// </param>
	/// <returns>
	///  A string indicating the outcome, such as SUCCESS, UNKNOWN_USER, INVALID_CARD_NUMBER, CARD_IS_USED or
	///  CARD_HAS_EXPIRED.
	/// </returns>
	public string UseCard(string username, string cardNumber) {
		return _proxy.UseCard(_authToken, username, cardNumber);
	}




	/// <summary>
	///  Instigate an online backup. This process is equivalent to pressing the manual backup button in the web based
	///  admin interface. The data is expected into the server/data/backups directory as a timestamped, zipped XML file.
	/// </summary>
	/// 
	public void PerformOnlineBackup() {
		_proxy.PerformOnlineBackup(_authToken);
	}

	/// <summary>
	///  Start the process of synchronizing the system's group membership with the OS/Network/Domain's group membership.
	///  The call to this method will start the synchronization process. The operation will commence and complete in the
	///  background.
	/// </summary>
	/// 
	public void PerformGroupSync() {
		_proxy.PerformGroupSync(_authToken);
	}

	/// <summary>
	///  Start a full user and group synchronization. This is equivalent to pressing on the "Synchronize Now" button in
	///  the admin user interface. The behaviour of the sync process, such as deleting old users, is determined by the
	///  current system settings as defined in the admin interface. A call to this method will commence the sync process
	///  and the operation will complete in the background.
	/// </summary>
	///
	public void PerformUserAndGroupSync() {
		_proxy.PerformUserAndGroupSync(_authToken);
	}

	/// <summary>
	///  An advanced version of the user and group synchronization process providing control over the sync behaviour. A
	///  call to this method will commence the sync process and the operation will complete in the background.
	/// </summary>
	///  
	/// <param name="deleteNonExistentUsers">
	///  If set to <code>True</code>, old users will be deleted.
	/// </param>
	/// <param name="updateUserDetails">
	///  If set to <code>True</code>, user details such as full-name, email, etc. will be synced with the
	///  underlying OS/Network/Domain user directory.
	/// </param>
	/// 
	public void PerformUserAndGroupSyncAdvanced(bool deleteNonExistentUsers, bool updateUserDetails) {
		_proxy.PerformUserAndGroupSyncAdvanced(_authToken, deleteNonExistentUsers, updateUserDetails);
	}

	/// <summary>
	///  Calling this method will start a specialized user and group synchronization process optimized for tracking down
	///  adding any new users that exist in the OS/Network/Domain user directory and not in the system. Any existing user
	///  accounts will not be modified. A group synchronization will only be performed if new users are actually added to
	///  the system.
	/// </summary>
	/// 
	public void AddNewUsers() {
		_proxy.AddNewUsers(_authToken);
	}

	/// <summary>
	///  Import the shared accounts contained in the given TSV import file.
	/// </summary>
	///
	/// <param name="importFile">
	///  The import file location relative to the application server.
	/// </param>
	/// <param name="test">
	///  If true, perform a test only. The printed statistics will show what would have occurred if testing wasn't
	///  enabled. No accounts will be modified.
	/// </param>
	/// <param name="deleteNonExistentAccounts">
	///  If true, accounts that do not exist in the import file but exist in the system will be deleted.  If false, they
	///  will be ignored.
	/// </param>
	///
	public string BatchImportSharedAccounts(string importFile, bool test, bool deleteNonExistentAccounts) {
		return _proxy.BatchImportSharedAccounts(_authToken, importFile, test, deleteNonExistentAccounts);
	}

	/// <summary>
	///  Import the users contained in the given tab-delimited import file.
	/// </summary>
	///
	/// <param name="importFile">
	///  The import file location relative to the application server.
	/// </param>
	/// <param name="createNewUsers">
	///  If true, users only existing in the import file will be newly created, otherwise ignored
	/// </param>
	///
	public void BatchImportUsers(string importFile, bool createNewUsers)
	{
		_proxy.BatchImportUsers(_authToken, importFile, createNewUsers);
	}

	/// <summary>
	///  Import the internal users contained in the given tab-delimited import file.
	/// </summary>
	///
	/// <param name="importFile">
	///  The import file location relative to the application server.
	/// </param>
	/// <param name="overwriteExistingPasswords">
	///  True to overwrite existing user passwords, false to only update un-set passwords.
	/// </param>
	/// <param name="overwriteExistingPINs">
	///  True to overwrite existing user PINs, false to only update un-set PINs.
	/// </param>
	///
	public void BatchImportInternalUsers(string importFile, bool overwriteExistingPasswords,
										 bool overwriteExistingPINs) {
		_proxy.BatchImportInternalUsers(_authToken, importFile, overwriteExistingPasswords, overwriteExistingPINs);
	}

	/// <summary>
	///  Import the user card/ID numbers and PINs contained in the given tab-delimited import file.
	/// </summary>
	///
	/// <param name="importFile">
	///  The import file location relative to the application server.
	/// </param>
	/// <param name="overwriteExistingPINs">
	///  If true, users with a PIN already defined will have it overwritten by the PIN in the import file, if specified.
	///  If false, the existing PIN will not be overwritten.
	/// </param>
	///
	public void BatchImportUserCardIdNumbers(string importFile, bool overwriteExistingPINs) {
		_proxy.BatchImportUserCardIdNumbers(_authToken, importFile, overwriteExistingPINs);
	}

	/// <summary>
	///  Get the config value from the server.
	/// </summary>
	///  
	/// <param name="configName">
	///  The name of the config value to retrieve.
	/// </param>
	/// <returns>
	///  The config value.  If the config value does not exist a blank string is returned.
	/// </returns>
	/// 
	public string GetConfigValue(string configName) {
		return _proxy.GetConfigValue(_authToken, configName);
	}
	
	/// <summary>
	///  Set the config value from the server.
	///  NOTE: Take care updating config values.  You may cause serious problems which can only be fixed by 
	///        reinstallation of the application. Use the setConfigValue API at your own risk.
	/// </summary>
	///  
	/// <param name="configName">
	///  The name of the config value to set.
	/// </param>
	/// <param name="configValue">
	///  The value to set.
	/// </param>
	/// <returns>
	///  The config value.  If the config value does not exist a blank string is returned.
	/// </returns>
	/// 
	public void SetConfigValue(string configName, string configValue) {
		_proxy.SetConfigValue(_authToken, configName, configValue);
	}

	/// <summary>
	///  Takes the details of a job and logs and charges as if it were a "real" job.  Jobs processed via this method are
	///  not susceptible to filters, pop-ups, hold/release queues etc., they are simply logged.  See the user manual
	///  section "Importing Job Details" for more information and the format of jobDetails.
	/// </summary>
	///
	/// <param name="jobDetails">
	///  The job details (a comma separated list of name-value pairs with an equals sign as the name-value delimiter).
	/// </param>
	///
	public void ProcessJob(string jobDetails) {
		_proxy.ProcessJob(_authToken, jobDetails);
	}

	/// <summary>
	///  Change the internal admin password.
	/// </summary>
	///  
	/// <param name="newPassword">
	///  The new password.  Cannot be blank.
	/// </param>
	/// <returns>
	///  True if the password was successfully changed.
	/// </returns>
	/// 
	public bool ChangeInternalAdminPassword(string newPassword) {
		return _proxy.ChangeInternalAdminPassword(_authToken, newPassword);
	}

	/// <summary>
	///  Set the user to Auto Charge to Personal
	/// </summary>
	///  
	/// <param name="username">
	///  The name of the user with the account to credit.
	/// </param>
	/// 
	public void SetUserAccountSelectionAutoChargePersonal(string username) {
		_proxy.SetUserAccountSelectionAutoChargePersonal(_authToken, username);
	}

	/// <summary>
	///  Set the user to Auto Charge to a Single Shared Account
	/// </summary>
	///  
	/// <param name="username">
	///  The name of the user with the account to credit.
	/// </param>
	/// 
	/// <param name="accountName">
	///  The name of the shared account.
	/// </param>
	/// 
	/// <param name="chargeToPersonal">
	///  Transactions should be primarily charged to the user, not the account
	/// </param>
	/// 
	public void SetUserAccountSelectionAutoSelectSharedAccount(string username, string accountName, bool chargeToPersonal)
	{
		_proxy.SetUserAccountSelectionAutoSelectSharedAccount(_authToken, username, accountName, chargeToPersonal);
	}

	/// <summary>
	///  Set the user to select an acccount from the popup list of approved accounts
	/// </summary>
	/// <param name="username">
	///  The name of the user with the account to credit.
	/// </param>
	/// <param name="allowPersonal">
	///  Allows the user to allocate the transaction to their personal account
	/// </param>
	/// <param name="allowListSelection">
	///  Sets the popup behavior to present a list of approved accounts to the user
	/// </param>
	/// <param name="allowPinCode">
	///  Sets the popup behavior to allow the user to enter a PIN code to identify an account
	/// </param>
	/// <param name="allowPrintingAsOtherUser">
	///  Sets the popup behavior to allow the user to supply alternate credentials as the billable user for the job
	/// </param>
	/// <param name="chargeToPersonalWhenSharedSelected">
	///  When a shared account is selected the user should be charged for the job with a record of the transaction
	///  attributed to the account
	/// </param>
	public void SetUserAccountSelectionStandardPopup(string username, bool allowPersonal, bool allowListSelection,
			bool allowPinCode, bool allowPrintingAsOtherUser, bool chargeToPersonalWhenSharedSelected) {
		_proxy.SetUserAccountSelectionStandardPopup(_authToken, username, allowPersonal, allowListSelection,
				allowPinCode, allowPrintingAsOtherUser, chargeToPersonalWhenSharedSelected);
	}
}

/// <summary>
///  Struct representing the return type for the GetGroupQuota API.
/// </summary>
public struct GetGroupQuotaResponse {
	public double QuotaAmount;
	public string QuotaPeriod;
	public double QuotaMaxAccumulation;
}
