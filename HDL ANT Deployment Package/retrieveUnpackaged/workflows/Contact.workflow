<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Contact_Approaching_Gift_Limit_100</fullName>
        <ccEmails>cmonoc@rainmaker-llc.com</ccEmails>
        <description>Contact Approaching Gift Limit-$100</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Upcoming_Gift_Limit_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Contact_Approaching_Gift_Limit_50</fullName>
        <description>Contact Approaching Gift Limit-$50</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Upcoming_Gift_Limit_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Contact_has_reached_Gift_Limit</fullName>
        <description>Contact has reached Gift Limit</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Gift_Limit_Reached_Email_Template</template>
    </alerts>
    <rules>
        <fullName>Contact Approaching Gift Limit-%24100</fullName>
        <actions>
            <name>Contact_Approaching_Gift_Limit_100</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Triggered when Contact.current year gift total &gt;=230, and Current Year Gift Amount &lt;279</description>
        <formula>AND(Current_Year_Gift_Total__c &gt;=230, Current_Year_Gift_Total__c&lt;279)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contact Approaching Gift Limit-%2450</fullName>
        <actions>
            <name>Contact_Approaching_Gift_Limit_50</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Current_Year_Gift_Total__c</field>
            <operation>greaterOrEqual</operation>
            <value>280</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Current_Year_Gift_Total__c</field>
            <operation>lessThan</operation>
            <value>330</value>
        </criteriaItems>
        <description>Triggered when Current Year Gift Amount&gt;=280, and Current Year Gift Amount&lt;330</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contact has reached Gift Limit</fullName>
        <actions>
            <name>Contact_has_reached_Gift_Limit</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Current_Year_Gift_Total__c</field>
            <operation>greaterOrEqual</operation>
            <value>330</value>
        </criteriaItems>
        <description>Triggered when Current Year Gift Amount&gt;=330</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
