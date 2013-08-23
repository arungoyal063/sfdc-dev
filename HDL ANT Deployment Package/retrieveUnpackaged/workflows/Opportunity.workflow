<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Sales_Support_and_Opp_Owner_of_Closed_Opp</fullName>
        <ccEmails>salessupport@hdlabinc.com</ccEmails>
        <description>Email Sales Support and Opp Owner of Closed Opp</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Closed_Opportunity</template>
    </alerts>
    <rules>
        <fullName>Closed Opportunity</fullName>
        <actions>
            <name>Email_Sales_Support_and_Opp_Owner_of_Closed_Opp</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Signed Contract</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Alert_IT_to_set_up_Account</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Alert IT to set up Account</subject>
    </tasks>
</Workflow>
