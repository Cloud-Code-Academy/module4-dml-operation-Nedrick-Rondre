/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Nedrick Rondre' Durham
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account newAccount = new Account();
        // Set some fields on the Account
        newAccount.Name = 'Test Account ' +  Datetime.now().getTime(); // Adding timestamp to ensure uniqueness
        newAccount.Industry = 'Test Industry';
        // Insert the Account into the database
        insert newAccount;
        // Return the Id of the newly created Account
        return newAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account newAcc = new Account(Name = name, Industry = industry);
        // Insert the Account
        insert newAcc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact();
        // Set some fields on the Contact
        newContact.FirstName = 'Test';
        newContact.LastName = 'Contact';
        newContact.Email = 'test@example.com';

        // Set the AccountId field to the given accountId
        newContact.AccountId = accountId;
        // Insert the Contact into the database
        insert newContact;
        // Return the Id of the newly created Contact
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        Contact contact = [SELECT Id FROM Contact WHERE Id = :contactId];
        // Update the Contact's last name
        contact.LastName = newLastName;
        // Update the Contact in the database
        update contact;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId];
        // Update the Opportunity's stage
        opp.StageName = newStage;
        // Update the Opportunity in the database
        update opp;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
            Account acc = [SELECT Id FROM Account WHERE Id = :accountId];
        // Update the Account with the given Id with the new name and industry
        acc.Name = newName;
        acc.Industry = newIndustry;
        update acc;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for (Opportunity opp : opportunities) {
            // Set the Opportunity's Stage to Qualification
            opp.StageName = 'Qualification';
            // Set the Opportunity's Close Date to 3 months from today
            opp.CloseDate = Date.today().addMonths(3);
            // Set the Opportunity's Amount to 50000
            opp.Amount = 50000;
        }
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
public static void upsertOpportunities(String accountName, List<String> oppNames) {
    if (String.isBlank(accountName) || oppNames == null || oppNames.isEmpty()) {
        return;
    }
    //Create or update the Account First
    Account acc = upsertAccount(accountName);

    // Remove duplicates opportunity names
    oppNames = new List<String>(new Set<String>(oppNames));
    Set<String> uniqueOppNames = new Set<String>(oppNames);

    // Query existing Opportunities for this Account by name
    Map<String, Opportunity> existingOppsByName = new Map<String, Opportunity>();
    for (Opportunity opp : [
        SELECT Id, Name
        FROM Opportunity
        WHERE AccountId = :acc.Id
        AND Name IN :uniqueOppNames
    ]) {
        existingOppsByName.put(opp.Name, opp);
    }

    List<Opportunity> opportunities = new List<Opportunity>();

    for (String oppName : uniqueOppNames) {
        Opportunity opp;

        if (existingOppsByName.containsKey(oppName)) {
            opp = existingOppsByName.get(oppName); // update existing
        } else {
            opp = new Opportunity();
            opp.Name = oppName;
            opp.AccountId = acc.Id;
        }

        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today().addMonths(3);
        opp.Amount = 40000;

        opportunities.add(opp);
    }

    upsert opportunities;
}
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        Account acc;

		// if the Account exists, update the description
        if (!accounts.isEmpty()) {
            acc = accounts[0];
            acc.Description = 'Updated Account';     
        }
		// otherwise, create a new Account and set the description
        else {
            acc = new Account();
            acc.Name = accountName;
            acc.Description = 'New Account';
        }
		// Upsert the Account
        upsert acc;
        // Return the upserted Account
		return acc;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
        List<Contact> contactsToUpdate = new List<Contact>();
		// Loop through each Contact
        for (Contact c : contactsToUpsert) {
            // Extract the Account Name from Contact's LastName
            String accountName = c.LastName;
            // Get the account based on the name or create one if it doesn't exist
            Account acc = upsertAccount(accountName);
            // Link the Contact to its Account using the Account Id
            c.AccountId = acc.Id;
            // Add the Contact to the list of contacts to update
            contactsToUpdate.add(c);
        }
        // Upsert the Contacts
        upsert contactsToUpdate;		
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) { 
        List<Lead> leadsToInsert = new List<Lead>();

        // Loop through each Lead name
        for (String name : leadNames) {
            Lead lead = new Lead();
            lead.LastName = name;
            lead.Company = 'Test Company';
            leadsToInsert.add(lead);
        }

        // Insert the Leads
        insert leadsToInsert;

        // Delete the Leads
        delete leadsToInsert;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> casesToInsert = new List<Case>();
        for (Integer i = 0; i < numOfCases; i++) {
            Case c = new Case();
            c.AccountId = accountId;
            c.Subject = 'Test Case ' + i;
            c.Status = 'New';
            c.Origin = 'Phone';

            casesToInsert.add(c);
        }
        // Insert the cases
        insert casesToInsert;

        // Delete the cases
        delete casesToInsert;
    }
}