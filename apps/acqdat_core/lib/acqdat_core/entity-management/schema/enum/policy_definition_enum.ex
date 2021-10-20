import EctoEnum

# creates a policy definition enum. The schema enum
# contains the name of the module which will define the module
# contianing all the key definitions for a alert policy.
defenum(EntityPolicyDefinitionModuleEnum,
  "Elixir.AcqdatCore.EntityManagement.Policies.RangeBased": 0,
  "Elixir.AcqdatCore.EntityManagement.Policies.UpperThreshold": 1,
  "Elixir.AcqdatCore.EntityManagement.Policies.LowerThreshold": 2
)

defenum(EntityEnum,
  SensorType: 0,
  Sensor: 1
)

# Creates an enum for different policy definitions.
defenum(EntityPolicyDefinitionEnum,
  "Alert when data is outside a bounded range": 0,
  "Alert when data is greater then an upper threshold": 1,
  "Alert when data is lesser then a lower threshold": 2
)
