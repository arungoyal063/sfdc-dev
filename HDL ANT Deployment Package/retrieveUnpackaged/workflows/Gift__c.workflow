<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Monetary_Value_Custom</fullName>
        <field>Monetary_Value__c</field>
        <formula>Custom_Monetary_Value__c</formula>
        <name>Update Monetary Value-Custom</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Monetary_Value_Standard</fullName>
        <field>Monetary_Value__c</field>
        <formula>Gift__r.Monetary_Value__c</formula>
        <name>Update Monetary Value-Standard</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Monetary Value-Custom</fullName>
        <actions>
            <name>Update_Monetary_Value_Custom</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Gift__c.Custom_Monetary_Value__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Gift__c.Custom_Monetary_Value__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When Custom Monetary Value &lt;&gt; 0 or NULL</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Monetary Value-Standard</fullName>
        <actions>
            <name>Update_Monetary_Value_Standard</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Gift__c.Custom_Monetary_Value__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Gift__c.Custom_Monetary_Value__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>When Custom Monetary Value = 0 or NULL</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
