codeunit 71033622 "SPB DBraider Gen Automate"
{
    Access = Internal;
    TableNo = "SPB DBraider Config. Header";

#pragma warning disable AA0217

    var
        SPBDBraiderUtilities: Codeunit "SPB DBraider Utilities";
        SPBDBraiderJSONUtilities: Codeunit "SPB DBraider JSON Utilities";

    trigger OnRun()
    var
        ResultBuilder: TextBuilder;
    begin
        case Rec."Output JSON Type" of
            //Rec."Output JSON Type"::Hierarchy:
            //SPBDBraiderGenHierarchy(Rec, ResultBuilder);
            Rec."Output JSON Type"::Flat:
                SPBDBraiderGenFlat(Rec, ResultBuilder);
        end;

        DisplayResult(ResultBuilder);
    end;

    local procedure DisplayResult(ResultBuilder: TextBuilder)
    var
        SPBDBraiderLargeTextView: Page "SPB DBraider Large Text View";
        AutomateClipboardText: Text;
        AutomateInstructionsTxt: Label 'Below is the raw contents of a Power Automate set of steps that can be used to fetch the data from Data Braider.  Copy the below code (click on the code, and use keyboard shortcuts to Select All and Copy, such as Ctrl+A then Ctrl+C), then in Power Automate, create a new Step, select the Clipboard, and Paste (such as Ctrl+V).  You can then add the steps.  You will need up update the Authentication settings of the HTTP step based on your environment.';
    begin
        AutomateClipboardText := ResultBuilder.ToText();
        SPBDBraiderLargeTextView.SetTextToShow(AutomateClipboardText);
        SPBDBraiderLargeTextView.SetCaptionToShow(AutomateInstructionsTxt);
        SPBDBraiderLargeTextView.RunModal();
    end;

    local procedure SPBDBraiderGenHierarchy(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; var ResultBuilder: TextBuilder)
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfigLine2: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field";
        SPBDBraiderConfLineFlowFields: Record "SPB DBraider ConfLine Flow";
        TableNameSafe: Text;
        FieldNameSafe: Text;
        LastLineNo: Integer;
    begin
        ResultBuilder.AppendLine('{');
        ResultBuilder.AppendLine('  "id": "344fd787-2884-493c-9543-e12a86ccde25",');
        ResultBuilder.AppendLine('  "brandColor": "#8C3900",');
        ResultBuilder.AppendLine('  "connectionReferences": {},');
        ResultBuilder.AppendLine('  "connectorDisplayName": "Control",');
        ResultBuilder.AppendLine('  "icon": "data:image/",');
        ResultBuilder.AppendLine('  "isTrigger": false,');
        ResultBuilder.AppendLine('  "operationName": "Fetch_Customers_and_Ship_To_Addresses",');
        ResultBuilder.AppendLine('  "operationDefinition": {');
        ResultBuilder.AppendLine('    "type": "Scope",');
        ResultBuilder.AppendLine('    "actions": {');
        ResultBuilder.AppendLine('      "HTTP": {');
        ResultBuilder.AppendLine('        "type": "Http",');
        ResultBuilder.AppendLine('        "inputs": {');
        ResultBuilder.AppendLine('          "method": "POST",');
        ResultBuilder.AppendLine('          "uri": "https://api.businesscentral.dynamics.com/v2.0/c1d2e612-ef9e-4ba0-9a42-fda2a1aca818/Sandbox/api/sparebrained/databraider/v2.0/companies(5736fe89-41bc-ee11-907d-6045bdc8c244)/read",');
        ResultBuilder.AppendLine('          "body": {');
        ResultBuilder.AppendLine('            "code": "CUSTSHIP",');
        ResultBuilder.AppendLine('            "filterJson": ""');
        ResultBuilder.AppendLine('          },');
        ResultBuilder.AppendLine('          "authentication": {');
        ResultBuilder.AppendLine('            "type": "ActiveDirectoryOAuth",');
        ResultBuilder.AppendLine('            "tenant": "",');
        ResultBuilder.AppendLine('            "audience": "https://api.businesscentral.dynamics.com",');
        ResultBuilder.AppendLine('            "clientId": "",');
        ResultBuilder.AppendLine('            "secret": ""');
        ResultBuilder.AppendLine('          }');
        ResultBuilder.AppendLine('        },');
        ResultBuilder.AppendLine('        "runAfter": {},');
        ResultBuilder.AppendLine('        "metadata": {');
        ResultBuilder.AppendLine('          "operationMetadataId": "90180f2f-86d6-4185-b892-769f85cf1014"');
        ResultBuilder.AppendLine('        }');
        ResultBuilder.AppendLine('      },');
        ResultBuilder.AppendLine('      "Customer_JSON": {');
        ResultBuilder.AppendLine('        "type": "ParseJson",');
        ResultBuilder.AppendLine('        "inputs": {');
        ResultBuilder.AppendLine('          "content": "@body(''HTTP'')?[''jsonResult'']",');
        ResultBuilder.AppendLine('          "schema": {');
        ResultBuilder.AppendLine('            "type": "array"');
        ResultBuilder.AppendLine('          }');
        ResultBuilder.AppendLine('        },');
        ResultBuilder.AppendLine('        "runAfter": {');
        ResultBuilder.AppendLine('          "HTTP": [');
        ResultBuilder.AppendLine('            "Succeeded"');
        ResultBuilder.AppendLine('          ]');
        ResultBuilder.AppendLine('        },');
        ResultBuilder.AppendLine('        "metadata": {');
        ResultBuilder.AppendLine('          "operationMetadataId": "5aade779-1d19-4ee9-95f0-1a7b6ca9d6a1"');
        ResultBuilder.AppendLine('        }');
        ResultBuilder.AppendLine('      },');
        ResultBuilder.AppendLine('      "Define_Customer": {');
        ResultBuilder.AppendLine('        "type": "Select",');
        ResultBuilder.AppendLine('        "inputs": {');
        ResultBuilder.AppendLine('          "from": "@body(''Customer_JSON'')",');
        ResultBuilder.AppendLine('          "select": {');
        ResultBuilder.AppendLine('            "Customer.No": "@item()[''data''][''No'']",');
        ResultBuilder.AppendLine('            "Customer.Name": "@item()[''data''][''Name'']",');
        ResultBuilder.AppendLine('            "Customer.systemId": "@item()[''sourceSystemId'']",');
        ResultBuilder.AppendLine('            "children": "@if(contains(item(),''children''),item()[''children''], json(''[]'') )"');
        ResultBuilder.AppendLine('          }');
        ResultBuilder.AppendLine('        },');
        ResultBuilder.AppendLine('      "runAfter": {');
        ResultBuilder.AppendLine('        "Customer_JSON": [');
        ResultBuilder.AppendLine('          "Succeeded"');
        ResultBuilder.AppendLine('        ]');
        ResultBuilder.AppendLine('      },');
        ResultBuilder.AppendLine('      "metadata": {');
        ResultBuilder.AppendLine('        "operationMetadataId": "44b37784-3010-4f96-8983-87d98aaab2d3"');
        ResultBuilder.AppendLine('      }');
        ResultBuilder.AppendLine('    },');
        ResultBuilder.AppendLine('    "Foreach_Customer": {');
        ResultBuilder.AppendLine('      "type": "Foreach",');
        ResultBuilder.AppendLine('      "foreach": "@body(''Define_Customer'')",');
        ResultBuilder.AppendLine('      "actions": {');
        ResultBuilder.AppendLine('        "ShipToAddress_JSON": {');
        ResultBuilder.AppendLine('          "type": "ParseJson",');
        ResultBuilder.AppendLine('          "inputs": {');
        ResultBuilder.AppendLine('            "content": "@item()[''children'']",');
        ResultBuilder.AppendLine('            "schema": {');
        ResultBuilder.AppendLine('              "type": "array"');
        ResultBuilder.AppendLine('            }');
        ResultBuilder.AppendLine('          },');
        ResultBuilder.AppendLine('          "runAfter": {},');
        ResultBuilder.AppendLine('          "metadata": {');
        ResultBuilder.AppendLine('            "operationMetadataId": "d0a5a5e0-a6ef-440d-bb60-2e8cfff2a3af"');
        ResultBuilder.AppendLine('          }');
        ResultBuilder.AppendLine('        },');
        ResultBuilder.AppendLine('        "Define_ShipToAddress": {');
        ResultBuilder.AppendLine('          "type": "Select",');
        ResultBuilder.AppendLine('          "inputs": {');
        ResultBuilder.AppendLine('            "from": "@body(''ShipToAddress_JSON'')",');
        ResultBuilder.AppendLine('            "select": {');
        ResultBuilder.AppendLine('              "ShipToAddress.Code": "@item()[''data''][''Code'']",');
        ResultBuilder.AppendLine('              "ShipToAddress.Address": "@item()[''data''][''Address'']",');
        ResultBuilder.AppendLine('              "ShipToAddress.systemId": "@item()[''sourceSystemId'']"');
        ResultBuilder.AppendLine('            }');
        ResultBuilder.AppendLine('          },');
        ResultBuilder.AppendLine('          "runAfter": {');
        ResultBuilder.AppendLine('            "ShipToAddress_JSON": [');
        ResultBuilder.AppendLine('              "Succeeded"');
        ResultBuilder.AppendLine('            ]');
        ResultBuilder.AppendLine('          },');
        ResultBuilder.AppendLine('          "metadata": {');
        ResultBuilder.AppendLine('            "operationMetadataId": "20773fdf-1389-49c6-b74c-6dec7e5e3ca1"');
        ResultBuilder.AppendLine('          }');
        ResultBuilder.AppendLine('        },');
        ResultBuilder.AppendLine('        "Apply_to_each": {');
        ResultBuilder.AppendLine('          "type": "Foreach",');
        ResultBuilder.AppendLine('          "foreach": "@body(''Define_ShipToAddress'')",');
        ResultBuilder.AppendLine('          "actions": {},');
        ResultBuilder.AppendLine('          "runAfter": {');
        ResultBuilder.AppendLine('            "Define_ShipToAddress": [');
        ResultBuilder.AppendLine('              "Succeeded"');
        ResultBuilder.AppendLine('            ]');
        ResultBuilder.AppendLine('          },');
        ResultBuilder.AppendLine('          "metadata": {');
        ResultBuilder.AppendLine('            "operationMetadataId": "01549f79-8065-4742-9536-a3c5648259bb"');
        ResultBuilder.AppendLine('          }');
        ResultBuilder.AppendLine('        }');
        ResultBuilder.AppendLine('      },');
        ResultBuilder.AppendLine('      "runAfter": {');
        ResultBuilder.AppendLine('        "Define_Customer": [');
        ResultBuilder.AppendLine('          "Succeeded"');
        ResultBuilder.AppendLine('        ]');
        ResultBuilder.AppendLine('      },');
        ResultBuilder.AppendLine('      "metadata": {');
        ResultBuilder.AppendLine('        "operationMetadataId": "1ed69acb-2654-45b9-8090-507c1bf3a4f4"');
        ResultBuilder.AppendLine('      }');
        ResultBuilder.AppendLine('    },');
        ResultBuilder.AppendLine('    "runAfter": {}');
        ResultBuilder.AppendLine('  }');
        ResultBuilder.AppendLine('}');

    end;

    local procedure SPBDBraiderGenFlat(SPBDBraiderConfigHeader: Record "SPB DBraider Config. Header"; var ResultBuilder: TextBuilder)
    var
        SPBDBraiderConfigLine: Record "SPB DBraider Config. Line";
        SPBDBraiderConfigLine2: Record "SPB DBraider Config. Line";
        SPBDBraiderConfLineFields: Record "SPB DBraider ConfLine Field";
        SPBDBraiderConfLineFlowFields: Record "SPB DBraider ConfLine Flow";
        TableNameSafe: Text;
        FieldNameSafe: Text;
        LastLineNo: Integer;
    begin
        ResultBuilder.AppendLine('{');
        ResultBuilder.AppendLine('  "id": "c86e0c55-2f9a-4a13-a10a-741089eb6e90",');
        ResultBuilder.AppendLine('  "brandColor": "#8C3900",');
        ResultBuilder.AppendLine('  "connectionReferences": {},');
        ResultBuilder.AppendLine('  "connectorDisplayName": "Control",');
        ResultBuilder.AppendLine('  "icon": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzIiIGhlaWdodD0iMzIiIHZlcnNpb249IjEuMSIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPg0KIDxwYXRoIGQ9Im0wIDBoMzJ2MzJoLTMyeiIgZmlsbD0iIzhDMzkwMCIvPg0KIDxwYXRoIGQ9Im04IDEwaDE2djEyaC0xNnptMTUgMTF2LTEwaC0xNHYxMHptLTItOHY2aC0xMHYtNnptLTEgNXYtNGgtOHY0eiIgZmlsbD0iI2ZmZiIvPg0KPC9zdmc+DQo=",');
        ResultBuilder.AppendLine('  "isTrigger": false,');
        ResultBuilder.AppendLine(StrSubstNo('  "operationName": "Fetch %1",', SPBDBraiderConfigHeader.Description));
        ResultBuilder.AppendLine('  "operationDefinition": {');
        ResultBuilder.AppendLine('    "type": "Scope",');
        ResultBuilder.AppendLine('    "actions": {');
        ResultBuilder.AppendLine(StrSubstNo('      "Fetch_%1": {', SPBDBraiderConfigHeader.Code));
        ResultBuilder.AppendLine('        "type": "Http",');
        ResultBuilder.AppendLine('        "inputs": {');
        ResultBuilder.AppendLine('          "method": "POST",');
        ResultBuilder.AppendLine(StrSubstNo('          "uri": "%1",', SPBDBraiderUtilities.GetJsonEndpointUriNoId(SPBDBraiderConfigHeader)));
        ResultBuilder.AppendLine('          "body": {');
        ResultBuilder.AppendLine(StrSubstNo('            "code": "%1",', SPBDBraiderConfigHeader.Code));
        ResultBuilder.AppendLine('            "filterJson": ""');
        ResultBuilder.AppendLine('          },');
        ResultBuilder.AppendLine('          "authentication": {');
        ResultBuilder.AppendLine('            "type": "ActiveDirectoryOAuth",');
        ResultBuilder.AppendLine('            "tenant": "",');
        ResultBuilder.AppendLine('            "audience": "https://api.businesscentral.dynamics.com",');
        ResultBuilder.AppendLine('            "clientId": "",');
        ResultBuilder.AppendLine('            "secret": ""');
        ResultBuilder.AppendLine('          }');
        ResultBuilder.AppendLine('        },');
        ResultBuilder.AppendLine('        "runAfter": {},');
        ResultBuilder.AppendLine('        "metadata": {');
        ResultBuilder.AppendLine('          "operationMetadataId": "530892af-c5c6-459c-afa1-bb12273409ec"');
        ResultBuilder.AppendLine('        }');
        ResultBuilder.AppendLine('      },');
        ResultBuilder.AppendLine('      "Extract_JSON_Result": {');
        ResultBuilder.AppendLine('        "type": "Compose",');
        ResultBuilder.AppendLine(StrSubstNo('        "inputs": "@body(''Fetch_%1'')?[''jsonResult'']",', SPBDBraiderConfigHeader.Code));
        ResultBuilder.AppendLine('        "runAfter": {');
        ResultBuilder.AppendLine(StrSubstNo('          "Fetch_%1": [', SPBDBraiderConfigHeader.Code));
        ResultBuilder.AppendLine('            "Succeeded"');
        ResultBuilder.AppendLine('          ]');
        ResultBuilder.AppendLine('        }');
        ResultBuilder.AppendLine('      },');
        ResultBuilder.AppendLine('      "Extract_to_Records": {');
        ResultBuilder.AppendLine('        "type": "ParseJson",');
        ResultBuilder.AppendLine('        "inputs": {');
        ResultBuilder.AppendLine('          "content": "@outputs(''Extract_JSON_Result'')",');
        ResultBuilder.AppendLine('          "schema": {');
        ResultBuilder.AppendLine('            "type": "array",');
        ResultBuilder.AppendLine('            "items": {');
        ResultBuilder.AppendLine('              "type": "object",');
        ResultBuilder.AppendLine('              "properties": {');
        SPBDBraiderConfigLine.SetRange("Config. Code", SPBDBraiderConfigHeader.Code);
        if SPBDBraiderConfigLine.FindLast() then
            LastLineNo := SPBDBraiderConfigLine."Line No.";
        SPBDBraiderConfigLine.SetAutoCalcFields("Source Table Name");
        if SPBDBraiderConfigLine.FindSet() then
            repeat
                TableNameSafe := SPBDBraiderJSONUtilities.JsonSafeTableFieldName(SPBDBraiderConfigLine."Source Table Name");

                // Now we need to loop through the fields and add them to the schema
                SPBDBraiderConfLineFields.SetRange("Config. Code", SPBDBraiderConfigLine."Config. Code");
                SPBDBraiderConfLineFields.SetRange("Config. Line No.", SPBDBraiderConfigLine."Line No.");
                SPBDBraiderConfLineFields.SetRange(Included, true);
                SPBDBraiderConfLineFields.SetAutoCalcFields("Field Name");
                if SPBDBraiderConfLineFields.FindSet() then
                    repeat
                        FieldNameSafe := SPBDBraiderJSONUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Field Name");
                        ResultBuilder.AppendLine(StrSubstNo('                "%1.%2": {', TableNameSafe, FieldNameSafe));
                        ResultBuilder.AppendLine(StrSubstNo('                  "type": "%1"', ConvertBraiderTypeToPowerAutomateType(SPBDBraiderConfLineFields."Field Type")));
                        ResultBuilder.AppendLine('                },');
                    until SPBDBraiderConfLineFields.Next() < 1;

                // Then loop through Flow Fields of a given line from Parent Fields info
                SPBDBraiderConfLineFlowFields.SetRange("Config. Code", SPBDBraiderConfigLine."Config. Code");
                SPBDBraiderConfLineFlowFields.SetRange("Config. Line No.", SPBDBraiderConfigLine."Line No.");
                if SPBDBraiderConfLineFlowFields.FindSet() then
                    repeat
                        SPBDBraiderConfigLine2.SetRange("Config. Code", SPBDBraiderConfigHeader.Code);
                        SPBDBraiderConfigLine2.SetRange("Source Table", SPBDBraiderConfLineFlowFields."Parent Table No.");
                        if SPBDBraiderConfigLine2.FindSet() then
                            repeat
                                SPBDBraiderConfLineFields.SetRange("Config. Code", SPBDBraiderConfigLine2."Config. Code");
                                SPBDBraiderConfLineFields.SetRange("Config. Line No.", SPBDBraiderConfigLine2."Line No.");
                                SPBDBraiderConfLineFields.SetRange(Included, true);
                                SPBDBraiderConfLineFields.SetRange("Field Class", 'FlowField');
                                SPBDBraiderConfLineFields.SetAutoCalcFields("Field Name");
                                if SPBDBraiderConfLineFields.FindSet() then
                                    repeat
                                        FieldNameSafe := SPBDBraiderJSONUtilities.JsonSafeTableFieldName(SPBDBraiderConfLineFields."Field Name");
                                        ResultBuilder.AppendLine(StrSubstNo('                "%1.%2": {', TableNameSafe, FieldNameSafe));
                                        ResultBuilder.AppendLine(StrSubstNo('                  "type": "%1"', ConvertBraiderTypeToPowerAutomateType(SPBDBraiderConfLineFields."Field Type")));
                                        ResultBuilder.AppendLine('                },');
                                    until SPBDBraiderConfLineFields.Next() < 1;
                            until SPBDBraiderConfigLine2.Next() < 1;
                    until SPBDBraiderConfLineFlowFields.Next() < 1;

                ResultBuilder.AppendLine(StrSubstNo('                "%1.systemId": {', TableNameSafe));
                ResultBuilder.AppendLine('                  "type": "string"');
                ResultBuilder.AppendLine('                },');
                ResultBuilder.AppendLine(StrSubstNo('                "%1.lastModifiedAt": {', TableNameSafe));
                ResultBuilder.AppendLine('                  "type": "integer"');
                if SPBDBraiderConfigLine."Line No." <> LastLineNo then
                    ResultBuilder.AppendLine('                },')
                else
                    ResultBuilder.AppendLine('                }')
            until SPBDBraiderConfigLine.Next() < 1;

        ResultBuilder.Remove(ResultBuilder.Length - 1, 1); // Remove that last comma
        ResultBuilder.AppendLine('              }');
        ResultBuilder.AppendLine('            }');
        ResultBuilder.AppendLine('          }');
        ResultBuilder.AppendLine('        },');
        ResultBuilder.AppendLine('        "runAfter": {');
        ResultBuilder.AppendLine('          "Extract_JSON_Result": [');
        ResultBuilder.AppendLine('            "Succeeded"');
        ResultBuilder.AppendLine('          ]');
        ResultBuilder.AppendLine('        }');
        ResultBuilder.AppendLine('      }');
        ResultBuilder.AppendLine('    },');
        ResultBuilder.AppendLine('    "runAfter": {}');
        ResultBuilder.AppendLine('  }');
        ResultBuilder.AppendLine('}');
    end;

    procedure ConvertBraiderTypeToPowerAutomateType(BraiderType: Enum "SPB DBraider Field Data Type"): Text
    begin
        case BraiderType of
            BraiderType::Integer:
                exit('integer');
            BraiderType::Decimal:
                exit('number');
            BraiderType::Boolean:
                exit('boolean');
            else
                exit('string');
        end;
    end;

#pragma warning restore AA0217
}
