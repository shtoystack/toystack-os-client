--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations
-- under the License.
--

-- Create default user "toystackadmin" with password "toystackadmin"
INSERT INTO [guacamole_entity] ([name], [type]) VALUES ('toystackadmin', 'USER');
INSERT INTO [guacamole_user] (
    [entity_id],
    [password_hash],
    [password_salt],
    [password_date]
)
SELECT
    [entity_id],
    5a23b2ee97032a7f0e1bc724653cbb188329dce94d8cc455f78a2a2dc76f4d58,
    c9de5ea6b93b56a8c6cf8ab5c1326113589d6ce0bd4901daf2415909ae5a1d7e,
    getdate()
FROM [guacamole_entity] WHERE [name] = 'toystackadmin';

-- Grant this user all system permissions
INSERT INTO [guacamole_system_permission]
SELECT
    [entity_id],
    [permission]
FROM (
          SELECT 'toystackadmin', 'CREATE_CONNECTION'
    UNION SELECT 'toystackadmin', 'CREATE_CONNECTION_GROUP'
    UNION SELECT 'toystackadmin', 'CREATE_SHARING_PROFILE'
    UNION SELECT 'toystackadmin', 'CREATE_USER'
    UNION SELECT 'toystackadmin', 'CREATE_USER_GROUP'
    UNION SELECT 'toystackadmin', 'ADMINISTER'
) [permissions] ([username], [permission])
JOIN [guacamole_entity] ON [permissions].[username] = [guacamole_entity].[name] AND [guacamole_entity].[type] = 'USER';

INSERT INTO [guacamole_user_permission]
SELECT
    [guacamole_entity].[entity_id],
    [guacamole_user].[user_id],
    [permission]
FROM (
          SELECT 'toystackadmin', 'toystackadmin', 'READ'
    UNION SELECT 'toystackadmin', 'toystackadmin', 'UPDATE'
    UNION SELECT 'toystackadmin', 'toystackadmin', 'ADMINISTER'
) [permissions] ([username], [affected_username], [permission])
JOIN [guacamole_entity]            ON [permissions].[username] = [guacamole_entity].[name] AND [guacamole_entity].[type] = 'USER'
JOIN [guacamole_entity] [affected] ON [permissions].[affected_username] = [affected].[name] AND [guacamole_entity].[type] = 'USER'
JOIN [guacamole_user]              ON [guacamole_user].[entity_id] = [affected].[entity_id];
GO
