using System;
using System.DirectoryServices;
using System.DirectoryServices.ActiveDirectory;
using System.Management.Automation;

namespace Utilities
{
    public class Functions
    {
        public static SearchResultCollection QueryAD(string ldapPath, string ldapFilter, string searchScope, string[] ldapProperties)
        {
            try
            {
                // Creating new DirectoryEntry object
                DirectoryEntry dirEntry = new DirectoryEntry(ldapPath.ToUpper());
                // Creating new DirectorySearcher
                DirectorySearcher dirSearcher = new DirectorySearcher(ldapFilter);

                // Setting SearchRoot
                dirSearcher.SearchRoot = dirEntry;
                // Setting PageSize to 1000
                dirSearcher.PageSize = 1000;
                // Setting dirSearcher filter
                dirSearcher.Filter = ldapFilter;

                switch (searchScope)
                {
                    case "Base":
                        {
                            // Setting Searchscope to Base
                            dirSearcher.SearchScope = SearchScope.Base;
                            break;
                        }
                    case "OneLevel":
                        {
                            // Setting Searchscope to OneLevel
                            dirSearcher.SearchScope = SearchScope.OneLevel;
                            break;
                        }
                    case "Subtree":
                        {
                            // Setting Searchscope to Subtree
                            dirSearcher.SearchScope = SearchScope.Subtree;
                            break;
                        }
                } // End Switch

                if (ldapProperties != null)
                {
                    // Load properties into the query
                    foreach (string AdProperty in ldapProperties)
                    {
                        // Loading property
                        dirSearcher.PropertiesToLoad.Add(AdProperty);
                    }
                }
                dirEntry.Dispose();
                SearchResultCollection queryResult;
                queryResult = dirSearcher.FindAll();
                return queryResult;
            }
            catch (Exception e)
            {
                throw e;
            }
            finally
            {
            }
        }
    }
}